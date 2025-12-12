function amplitude = pwr2IQamp(P_desired_dBm, FXP, chanConfig)

% limit power level
P_max_dBm = 0;

P_desired_mW = 10.^(P_desired_dBm/10);
P_desired_total_mW = sum(P_desired_mW(boolean(chanConfig.state)));
P_desired_total_dBm = 10*log10(P_desired_total_mW);
% 
if P_desired_total_dBm > P_max_dBm
    error('desired power exceeds %.2f dBm', P_max_dBm);
end

P_FS_dBm = 1; % full-scale power (20 mA mode) in dBm
%P_FS_dBm = 5; % full-scale power (32 mA mode) in dBm
P_FS_mW = 10.^(P_FS_dBm/10);  


% normalize amplitude
amplitude_max = 2^(FXP.sampWL-FXP.sampFL-1) - 2^(-FXP.sampFL);
amplitude = sqrt(P_desired_mW/P_FS_mW)*amplitude_max;

end

