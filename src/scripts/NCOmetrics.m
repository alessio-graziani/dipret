%% ==== NCO Quantization Metrics ==== %%

% The script is automatically executed after the NCO model simulation ends.

% import signals from workspace
exp_ideal = out.exp_double;
exp_fxp = out.exp_fxp;

N = length(exp_ideal);

% **** SFDR Evaluation **** %
sine_fxp = real(exp_fxp);
SFDR = sfdr(sine_fxp,sysParams.FPGAClkRate*iChain.interpFactor);
sfdr(sine_fxp,sysParams.FPGAClkRate*iChain.interpFactor);

% **** SQNR Evaluation **** %
error = exp_fxp - exp_ideal;
Ps = sum(abs(exp_ideal).^2)/N;
Pn = sum(abs(error).^2)/N;
SQNR = 10*log10(Ps/Pn);

% **** Display Metrics **** %
fprintf('\n===== Quantization Metrics =====\n');
fprintf('SQNR (dB): %.2f\n', SQNR);
fprintf('SFDR (dB): %.2f\n', SFDR);
fprintf('================================\n\n');
