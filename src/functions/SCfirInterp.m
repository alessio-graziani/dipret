function [firTaps] = SCfirInterp(FsIn, interpFactor, BW)

% **** FIR Lowpass Filter Interpolator **** %
guardOffset = 5e6; % [Hz]
Fpass = BW/2 + guardOffset;          % passband Frequency [Hz]
Fstop = FsIn - (BW/2 + guardOffset); % stopband Frequency [Hz]
Ap    = 0.1; % passband ripple [dB]
Ast   = 80;  % stopband attenuation [dB]

lpfParams.FsIn = FsIn;
lpfParams.InterpFactor = interpFactor;
lpfParams.FsOut = lpfParams.FsIn*lpfParams.InterpFactor;

lpfSpec = fdesign.interpolator(lpfParams.InterpFactor, ...
    'lowpass','Fp,Fst,Ap,Ast',Fpass,Fstop,Ap,Ast,lpfParams.FsOut);
lpf = design(lpfSpec,'SystemObject',true);

firTaps = coeffs(lpf).Numerator;

% **** Plot **** %
% plot = fvtool(lpf,'Fs',lpfParams.FsOut);
% legend(plot,"lpf");

end