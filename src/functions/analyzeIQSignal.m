function analyzeIQSignal(IQsignal, fs, titleStr, sysParams, chanConfig)

% **** Time-Domain I/Q Plot **** %
figure('Color', 'w', 'Name', [titleStr ' - Time Domain']);
n = 0:length(IQsignal)-1;

% in-phase component
subplot(2, 1, 1);
stem(n, real(IQsignal), 'o', 'LineWidth', 0.8); grid on;
title([titleStr ' - Baseband In-phase Component'], 'FontWeight', 'bold');
xlabel('Samples'); ylabel('Amplitude');
xlim([0, min(1e4, length(IQsignal))]);

% quadrature component
subplot(2, 1, 2);
stem(n, imag(IQsignal), 'o', 'LineWidth', 0.8); grid on;
title([titleStr ' - Baseband Quadrature Component'], 'FontWeight', 'bold');
xlabel('Samples'); ylabel('Amplitude');
xlim([0, min(1e4, length(IQsignal))]);

% **** Power Spectrum Plot **** %
figure('Color', 'w', 'Name', [titleStr ' - Power Spectrum']);
fftSize = 8192;
window = hamming(4096);
noverlap = numel(window)/2;
[pxx, f] = pwelch(IQsignal, window, noverlap, fftSize, fs, 'centered', 'power');
pxx_mW = pxx*1e3;
ps_dB = pow2db(pxx_mW);
f_MHz = f*1e-6;

plot(f_MHz, ps_dB, 'b', 'LineWidth', 0.8); hold on; grid on;
title([titleStr ' - Power Spectrum'], 'FontWeight', 'bold');
xlabel('Frequency [MHz]');
xlim([-fs/3, fs/3] ./ 1e6);
ylabel('Power [dBm]');
ylim([max(ps_dB)-60, max(ps_dB)+20]);

for i = 1:sysParams.numChan
    fc = chanConfig.freqLoc.BB(i) * 1e-6;
    if chanConfig.state(i) == 1
        xline(fc, '--r', sprintf('CH%d: %s', i, chanConfig.mode(i)), ...
            'LabelOrientation', 'horizontal', 'LabelVerticalAlignment','top', ...
            'LineWidth', 1.0, 'FontSize', 10);
    end
end

end




