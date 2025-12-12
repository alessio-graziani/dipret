function txOFDMwaveform = OFDMmod(modType, ifftSize, numSc, numSamp)

% modulation order
switch modType
    case "QPSK"
        modOrder = 4;
    case {"16QAM", "16APSK"}
        modOrder = 16;
    case "64APSK"
        modOrder = 64;
end

% validate numSamples
if mod(numSamp, ifftSize) ~= 0
    error('numSamp (%d) must be a multiple of ifftSize (%d).', ...
          numSamp, ifftSize);
end

% derived parameters 
numOFDMSymbols = numSamp/ifftSize;
bitsPerSc = log2(modOrder);
numBits = numOFDMSymbols*numSc*bitsPerSc;

% generate random data
txBits = randi([0 1], numBits, 1);

% bits -> IQ symbols 
switch modType
    case "QPSK"
        txIQsymbols = pskmod(txBits, modOrder, pi/4, 'gray', 'InputType', 'bit');
    case "16QAM"
        txIQsymbols = qammod(txBits, modOrder, 'gray', 'InputType', 'bit');
    case "16APSK"
        txIQsymbols = apskmod(txBits, [4,12], [1,2.6], [pi/4, pi/12], ...
                              'InputType', 'bit', 'SymbolMapping', 'contourwise-gray');
    case "64APSK"
        txIQsymbols = apskmod(txBits, [8,16,20,20], [1,2.2,3.6,5.2], ...
                              [pi/8, pi/16, pi/20, pi/20], 'InputType', 'bit', ...
                                'SymbolMapping', 'contourwise-gray');
end

% normalization
txIQsymbols = txIQsymbols/rms(txIQsymbols);

% reshape into OFDM subcarrier grid
txIQsymbols = reshape(txIQsymbols, numSc, []);

% subcarrier mapping (DC-centered)
ofdmGrid = zeros(ifftSize, numOFDMSymbols);
dcIndex = floor(ifftSize/2) + 1;
left = floor((numSc - 1)/2);
right = ceil((numSc - 1)/2);
scIdx = (dcIndex - left):(dcIndex + right);
ofdmGrid(scIdx, :) = txIQsymbols;

% OFDM modulation (IFFT + serialization)
ifftOut = ifft(ifftshift(ofdmGrid, 1), ifftSize, 1);
txOFDMwaveform = ifftOut(:);

% normalize
txOFDMwaveform = txOFDMwaveform./rms(txOFDMwaveform);

end

