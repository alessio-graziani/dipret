clc;
clear;
close all;

%% ==== Fixed-Point Configuration ==== %%
% ---- samples ---- %
FXP.sampWL = 18;  
FXP.sampFL = 16; 

% ---- filters coefficients ---- %
FXP.coeffWL = 20; 
FXP.coeffFL = 19;  

% ---- NCO ---- %
FXP.NCOphaseAccWL   = 16;  
FXP.NCOlutAddressWL = 14;

%% ==== System Parameters ==== %%
sysParams.numChan = 4;  
sysParams.numElem = 4;
sysParams.FPGAClkRate = 245.76e6; % [Hz] 
sysParams.FPGAClkPeriod = 1/sysParams.FPGAClkRate; % [s]
sysParams.fineMixer_NCOfreq = 1250e6; % [Hz]

%% ==== Channels Configuration ==== %%
%  ----------------  %
% | channel state: | %    
% |  1 -> on       | %
% |  0 -> off      | %
%  ----------------  %
chanConfig.state = [1, 1, 1, 1];

%  ------------------------------------------------  %
% | channel modes:                                 | %
% | CW -- OFDM -- SC-QPSK -- SC-16APSK -- SC-16QAM | %
%  ------------------------------------------------  %
chanConfig.mode = ["CW", "OFDM", "OFDM", "SC-16QAM"];

% carriers location
chanConfig.freqLoc.IF = [1062.5, 1187.5, 1312.5, 1437.5]; % [MHz] 
%chanConfig.freqLoc.IF = [1250, 1100, 1400, 1400];
chanConfig.freqLoc.BB = chanConfig.freqLoc.IF*1e6 - sysParams.fineMixer_NCOfreq; % [Hz]

% carriers power level
chanConfig.pwrLevel_dBm = [-8, -8, -8, -8]; % [dBm]

chanConfig.amplitude = pwr2IQamp(chanConfig.pwrLevel_dBm, FXP, chanConfig);
chanConfig.amplitude_fxp = fi(chanConfig.amplitude, 1, FXP.sampWL, FXP.sampFL);

%% ==== OFDM Modulation Parameters ==== %%
%  -----------------------------------  %
% | subcarriers modulation schemes    | %
% | QPSK -- 16APSK -- 16QAM -- 64APSK | %
%  -----------------------------------  %
OFDM.modType = ["64APSK", "64APSK", "64APSK", "64APSK"];

OFDM.ifftSize = 64;
OFDM.numSc = 12;
OFDM.numLgSc = ceil((OFDM.ifftSize - OFDM.numSc)/2);
OFDM.numRgSc = floor((OFDM.ifftSize - OFDM.numSc)/2);
OFDM.CpLength = 16;
OFDM.WindowLength = 8;
OFDM.ScSpacing = sysParams.FPGAClkRate/OFDM.ifftSize; % [Hz]
OFDM.BW = (OFDM.numSc + 1)*OFDM.ScSpacing; % [Hz]

%% ==== Single-Carrier Modulation Parameters ==== %%
% raised-cosine pulse shaping tx filter
SC.RRC.sampPerSym = 8;  % oversampling
SC.RRC.alpha = 0.35;    % rolloff 
SC.RRC.span = 6;        % filter span in symbols
SC.RRC.taps = rcosdesign(SC.RRC.alpha, SC.RRC.span, SC.RRC.sampPerSym, 'sqrt');

SC.firInterpFactor = 6;
SC.symRate = sysParams.FPGAClkRate/(SC.RRC.sampPerSym*SC.firInterpFactor);
SC.BW = SC.symRate*(1 + SC.RRC.alpha); % null-to-null bandwidth

SC.firTaps = SCfirInterp(sysParams.FPGAClkRate/SC.firInterpFactor, SC.firInterpFactor, SC.BW);

%% ==== Random Data LUT Generation ==== %%
lutAddrWidth = 10;                       
% lutSize = 2^lutAddrWidth;               
% txData = randi([0, 2^6 - 1], lutSize, sysParams.numChan);
% txData = fi(txData, 0, 6, 0);
% save("data.mat","txData");
load("data.mat");
% fid = fopen('data.txt','w');
% fprintf(fid,'%d',txData);
% fclose(fid);

%% ==== APSK Mappers LUT Generation ==== %%
[const_16APSK, const_64APSK] = apskConst();
const_16APSK = fi(const_16APSK, 1, FXP.sampWL, FXP.sampFL);
const_64APSK = fi(const_64APSK, 1, FXP.sampWL, FXP.sampFL);

%% ==== Interpolation Chain ==== %%
iChain.interpFactor = 8;
iChain.FsOut = sysParams.FPGAClkRate*iChain.interpFactor; % [Hz]
[iChain.hbTaps, iChain.firTaps] = interpChain(sysParams.FPGAClkRate, ...
    iChain.interpFactor, OFDM.BW, SC.BW);

%% ==== NCO ==== %%
tuningWord = chanConfig.freqLoc.BB./iChain.FsOut.*2.^FXP.NCOphaseAccWL;
tuningWord = fi(tuningWord, 1, FXP.NCOphaseAccWL, 0);

%% ==== Beamforming ==== %%
% beamforming coefficients matrix
bfCoeffs = complex(ones(sysParams.numElem, sysParams.numChan));

% apply phase shifts (in degrees) to channel 1
phaseCompDeg = [0, -10, -12.3, -13];
phaseBfDeg = [0, -30, -60, -90]; 
phaseTotDeg = phaseCompDeg + phaseBfDeg; 
bfCoeffs(:,1) = exp(1j*deg2rad(phaseTotDeg(:)));

bfCoeffs_fxp = fi(bfCoeffs, 1, FXP.sampWL, FXP.sampFL);

%% ==== Mux Control Signals ==== %%
%  ============================ 
% | modSel:      0 -> OFDM     |
% |              1 -> SC       |
%  ----------------------------
% | SCmodType:   0 -> QPSK     |
% |              1 -> 16APSK   |
% |              2 -> 16QAM    |
%  ----------------------------
% | modEnable:   0 -> CW       |
% |              1 -> MOD      |
%  ----------------------------
% | OFDMmodType: 0 -> QPSK     |
% |              1 -> 16QAM    |
% |              2 -> 16APSK   |
% |              3 -> 64APSK   |
%  ============================
modSel      = ones(1, sysParams.numChan);
modEnable   = ones(1, sysParams.numChan);
OFDMmodType = zeros(1, sysParams.numChan);
SCmodType   = zeros(1, sysParams.numChan);

modEnable(chanConfig.mode == "CW") = 0;
modSel(chanConfig.mode == "OFDM")  = 0;

SCmodType(chanConfig.mode == "SC-16APSK") = 1;
SCmodType(chanConfig.mode == "SC-16QAM")  = 2;

OFDMmodType(chanConfig.mode == "OFDM" & OFDM.modType == "16QAM")  = 1;
OFDMmodType(chanConfig.mode == "OFDM" & OFDM.modType == "16APSK") = 2;
OFDMmodType(chanConfig.mode == "OFDM" & OFDM.modType == "64APSK") = 3;

% type casting 
modSel      = boolean(modSel);
modEnable   = boolean(modEnable);
OFDMmodType = fi(OFDMmodType, 0, 2, 0);
SCmodType   = fi(SCmodType, 0, 2, 0);

