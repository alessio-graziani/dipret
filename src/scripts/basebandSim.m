init;
numSamp = 512*1e3;

%% ==== Baseband Signal Generation ==== %%
txBasebandSig = zeros(numSamp, sysParams.numChan);

for i = 1:sysParams.numChan
    if chanConfig.state(i)
        switch chanConfig.mode(i)
            case "OFDM"
                txBasebandSig(:, i) = OFDMmod(OFDM.modType(i), ...
                    OFDM.ifftSize, OFDM.numSc, numSamp);
            case {"SC-QPSK", "SC-16APSK", "SC-16QAM"}
                txBasebandSig(:, i) = SCmod(chanConfig.mode(i), ...
                    SC, numSamp);
        end
    end
end

%% ==== Resampling ==== %%
txResampledSig = resample(txBasebandSig, iChain.interpFactor, 1);
numSampRes = size(txResampledSig, 1);

%% ==== Amplitude Control and Frequency Shift ==== %%
omega = 2*pi*chanConfig.freqLoc.BB(:)/iChain.FsOut;
t = (0:numSampRes-1)';

txChanSig = zeros(size(txResampledSig));

for i = 1:sysParams.numChan
    if chanConfig.state(i)
        % Frequency shift
        if chanConfig.mode(i) == "CW"
            txChanSig(:, i) = 1.*exp(1j*omega(i)*t);
        else
            txChanSig(:, i) = txResampledSig(:, i).*exp(1j*omega(i)*t);
        end
        % Amplitude control
        txChanSig(:, i) = txChanSig(:, i).*chanConfig.amplitude(i);
    end
end

%% ==== Beamforming and Aggregation ==== %%
txCompositeBB = txChanSig*bfCoeffs.';

%% ==== Results Evaluation ==== %%
% single -> plot only one element
% all    -> plot all elements
plotSel = "single";

switch plotSel
    case "single"
        analyzeIQSignal(txCompositeBB(:, 1), iChain.FsOut, ...
            'Element A', sysParams, chanConfig);
    case "all"
        letters = ['A', 'B', 'C', 'D'];
        for i = 1:sysParams.numElem
            analyzeIQSignal(txCompositeBB(:, i), iChain.FsOut, ...
                ['Element ' letters(i)], sysParams, chanConfig);
        end
end