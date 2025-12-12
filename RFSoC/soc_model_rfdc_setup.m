%% Instantiate object and basic settings
IPAddr = '192.168.1.101';
rfobj = soc.RFDataConverter('ZU48DR',IPAddr);

rfobj.MTSConfigure = true;

PLLSrc = 'Internal';
ReferenceClock = 245.76; % MHz 
ADCSamplingRate = 3932.16; % MHz 
DACSamplingRate = 3932.16; % MHz 
DecimationFactor = 2;
InterpolationFactor = 2;
adcFineMixMode = true; % if set to false use coarse mixer 
dacFineMixMode = true; % if set to false use coarse mixer 


%% User FPGA-logic settings
rfobj.FPGASamplesPerClock = 4;
rfobj.ConverterClockRatio = 0.5;

% Check if FPGA clock-rate exceeds timing used during synthesis
FPGAClockRate = ADCSamplingRate/DecimationFactor/rfobj.FPGASamplesPerClock;
if FPGAClockRate > 245.76
    warning(['Selected FPGA rate %3.3f MHz exceeds the timing that was used ' ...
        'during synthesis (%3.3f MHz) for this design! Timing failures may ' ...
        'occur which can lead to unexpected behavior. Re-synthesizing your ' ...
        'design may be required to achieve faster rates.'],...
        FPGAClockRate, 245.76);
end

%% Establish TCP/IP connection
setup(rfobj);

%% Set External Clocking Options
% Set required clocks for MTS
rfobj.LMKClkSelect = 'SYSREF';
rfobj.configureLMXPLL(ReferenceClock);

%% Setup ADC/DAC Tile sampling and PLL rates
for TileId = 0:(rfobj.TotalADCTiles-1)
	rfobj.configureADCTile(TileId,PLLSrc,ReferenceClock,ADCSamplingRate);
    for ChId = 0:(rfobj.ADCChannelsPerTile-1)
		rfobj.configureADCChannel(TileId,ChId,DecimationFactor);
    end
end

for TileId = 0:(rfobj.TotalDACTiles-1)
    rfobj.configureDACTile(TileId,PLLSrc,ReferenceClock,DACSamplingRate);
    for ChId = 0:(rfobj.DACChannelsPerTile-1)        
		rfobj.configureDACChannel(TileId,ChId,InterpolationFactor,'DUCMode','FullNyquistDUC');        
    end
end

%% ADC IQ mode settings 
ADC_DDC_LO = [-1250 -1250 -1250 -1250 -1250 -1250 -1250 -1250]; 
ADC_MixingScale = '1';
ADC_MixerPhase = [0 0 0 0 0 0 0 0];

if rfobj.MTSConfigure
    EventMode = 'Sysref';
else   
    EventMode = 'Tile';
end

for TileId = 0:(rfobj.TotalADCTiles-1)
    for ChId = 0:(rfobj.ADCChannelsPerTile-1)           
        if adcFineMixMode %Fine Mixing Mode
            chIndx = ChId + 1 + rfobj.ADCChannelsPerTile*TileId; % one-based index
			configureADCMixer(rfobj, TileId, ChId, 'Fine', ADC_DDC_LO(chIndx), EventMode, ADC_MixerPhase(chIndx), ADC_MixingScale); 
        else %Coarse Mixing Mode
			configureADCMixer(rfobj, TileId, ChId, 'Coarse', '-Fs/4', EventMode, ADC_MixerPhase, ADC_MixingScale); 
        end
    end
end

%% DAC IQ mode settings 
DAC_DDC_LO = [1250 1250 1250 1250 1250 1250 1250 1250];
DAC_MixingScale = '1';
DAC_MixerPhase = [0 0 0 0 0 0 0 0];

if rfobj.MTSConfigure
    EventMode = 'Sysref';
else   
    EventMode = 'Immediate';
end

for TileId = 0:(rfobj.TotalDACTiles-1)
    for ChId = 0:(rfobj.DACChannelsPerTile-1) 
        if dacFineMixMode %Fine Mixing Mode
            chIndx = ChId + 1 + rfobj.DACChannelsPerTile*TileId; % one-based index
            configureDACMixer(rfobj, TileId, ChId, 'Fine', DAC_DDC_LO(chIndx), EventMode, DAC_MixerPhase(chIndx), DAC_MixingScale);
        else %Coarse Mixing Mode
            configureDACMixer(rfobj, TileId, ChId, 'Coarse', 'Fs/4', EventMode, DAC_MixerPhase, ADC_MixingScale);
        end
    end

end

%% Apply settings to RFTool
applyConfiguration(rfobj);
applyNyquistZone(rfobj);

%% Perform MTS capture
rfobj.enableMTS();

%% Disconnect and clear system object
release(rfobj);

