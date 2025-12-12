function txSCwaveformRes = SCmod(modType, SC, numSamp)

% modulation order
switch modType
    case "SC-QPSK"
        modOrder = 4;
    case {"SC-16QAM", "SC-16APSK"}
        modOrder = 16;
end

sampPerSym = SC.RRC.sampPerSym*SC.firInterpFactor;

% validate numSamples 
if mod(numSamp, sampPerSym) ~= 0
    error('numSamp (%d) must be a multiple of sampPerSym (%d).', ...
        numSamp, sampPerSym);
end

% derived Parameters 
numSym     = numSamp/sampPerSym;
bitsPerSym = log2(modOrder);
numBits    = bitsPerSym*numSym;

% generate random data
txBits = randi([0 1], numBits, 1);

% bits -> IQ symbols
switch modType
    case "SC-QPSK"
        txIQsymbols = pskmod(txBits, modOrder, pi/4, 'gray', 'InputType', 'bit');
    case "SC-16QAM"
        txIQsymbols = qammod(txBits, modOrder, 'gray', 'InputType', 'bit');
    case "SC-16APSK"
        txIQsymbols = apskmod(txBits, [4,12], [1,2.6], [pi/4, pi/12], ...
            'InputType', 'bit', 'SymbolMapping', 'contourwise-gray');
end

% pulse shaping
txIQsymbolsRes = upsample(txIQsymbols, SC.RRC.sampPerSym);
txSCwaveform   = filter(SC.RRC.taps, 1, txIQsymbolsRes);

% resample
txSCwaveformRes = upsample(txSCwaveform, SC.firInterpFactor);
txSCwaveformRes = filter(SC.firTaps, 1, txSCwaveformRes);

% normalize
txSCwaveformRes = txSCwaveformRes./rms(txSCwaveformRes);

end
