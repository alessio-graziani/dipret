function [hbTaps, firTaps] = interpChain(FsIn, interpFactor, OFDM_BW, SC_BW)

BW = max(SC_BW, OFDM_BW);  % [Hz]
guardOffset = 0;           % [Hz]

% **** FIR Lowpass Filter Interpolator **** %
Fpass = BW/2 + guardOffset;           % passband frequency [Hz]
Fstop = FsIn - (BW/2 + guardOffset);  % stopband frequency [Hz]
Ap    = 0.1; % passband ripple [dB]
Ast   = 80;  % stopband attenuation [dB]

lpfParams.FsIn = FsIn;
lpfParams.InterpFactor = interpFactor/2;
lpfParams.FsOut = lpfParams.FsIn*lpfParams.InterpFactor;
lpfSpec = fdesign.interpolator(lpfParams.InterpFactor, ...
    'lowpass','Fp,Fst,Ap,Ast',Fpass,Fstop,Ap,Ast,lpfParams.FsOut);

fir = design(lpfSpec,'SystemObject',true);
firTaps = coeffs(fir).Numerator;

% **** Halfband (Nyquist band-2) Interpolator **** %
hbParams.FsIn = lpfParams.FsOut;
hbParams.InterpFactor = interpFactor/4;
hbParams.FsOut = hbParams.FsIn*hbParams.InterpFactor;
hbParams.TransitionWidth = hbParams.FsIn - 2*(BW/2 - guardOffset);
hbParams.StopbandAttenuation = 80;
hbSpec = fdesign.interpolator(hbParams.InterpFactor,'halfband', ...
          'TW,Ast', ...
          hbParams.TransitionWidth, ...
          hbParams.StopbandAttenuation, ...
          hbParams.FsOut);

hb = design(hbSpec,'SystemObject',true);
hbTaps = coeffs(hb).Numerator;

% **** Plot **** %
% % individual responses plot
% plots = fvtool(hb, fir, 'Fs', [hbParams.FsOut, lpfParams.FsOut]);
% legend(plots, "hb", "fir");
% 
% filterChain = dsp.FilterCascade(hb, fir);
% 
% % cascade response plot
% cascadePlot = fvtool(filterChain, 'Fs', lpfParams.FsOut);
% legend(cascadePlot,"hb + fir");

end
