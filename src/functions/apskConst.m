function [const_16APSK, const_64APSK] = apskConst()

% **** DVB-S2 16APSK constellation [code rate 8/9] **** %
% parameter gamma
gamma = 2.60;  

% define ring radii
r1 = 1;      % inner ring radius
r2 = gamma;  % outer ring radius

% phases for 4 symbols in the inner ring (every 90°), rotated by 45°
theta_inner = (0:3)*(2*pi/4) + pi/4;
inner_ring = r1*exp(1j*theta_inner); 

% phases for 12 symbols in the outer ring (every 30°), rotated by 15°
theta_outer = (0:11)*(2*pi/12) + pi/12;
outer_ring = r2*exp(1j*theta_outer); 

% complete 16APSK constellation
const_16APSK = [inner_ring, outer_ring];

% normalize to unit average power
P_avg = mean(abs(const_16APSK).^2);      % compute average power
const_16APSK = const_16APSK/sqrt(P_avg); % normalize

% gray bit-mapping
index = [6,15,9,12,5,16,10,11,7,14,8,13,1,4,2,3];
const_16APSK = const_16APSK(index);

% 16APSK constellation plot
% numSymbols = length(constellation_16APSK); 
% figure();
% scatter(real(constellation_16APSK), imag(constellation_16APSK),'filled');grid on; 
% for i = 1:numSymbols
%     text(real(constellation_16APSK(i))+0.05,imag(constellation_16APSK(i))+0.05,num2str(dec2bin(i-1,4)),'FontSize',10,...
%          'HorizontalAlignment','center','VerticalAlignment','middle');
% end
% xlabel('I (In-phase)');
% ylabel('Q (Quadrature)');
% title('Normalized DVB-S2 16APSK Constellation [Code Rate 8/9]');

% **** DVB-S2X 64APSK constellation [code rate 4/5] **** %
% define ring radii
R1 = 1;           
R2 = 2.2*R1;    
R3 = 3.6*R1;    
R4 = 5.2*R1;    

% define angular offsets
offset1 = pi/8;
offset2 = pi/16;
offset3 = pi/20;
offset4 = pi/20;

% number of symbols per ring
N1 = 8;
N2 = 16;
N3 = 20;
N4 = 20;

% compute phase positions for constellation points
theta1 = linspace(0, 2*pi*(1-1/N1), N1) + offset1;
theta2 = linspace(0, 2*pi*(1-1/N2), N2) + offset2; 
theta3 = linspace(0, 2*pi*(1-1/N3), N3) + offset3; 
theta4 = linspace(0, 2*pi*(1-1/N4), N4) + offset4; 

% compute constellation symbols
const_64APSK = [R1*exp(1j*theta1), ...
                 R2*exp(1j*theta2), ...
                 R3*exp(1j*theta3), ...
                 R4*exp(1j*theta4)];

% normalize to unit average power
P_avg = mean(abs(const_64APSK).^2);      % compute average power
const_64APSK = const_64APSK/sqrt(P_avg); % normalize

% gray bit-mapping
index = [21,62,22,42,60,61,40,41,20,57,19,37,59,58,39,38,7,63,23,43,8,64,24,44,6,56,18,36,5,55,17,35,12,47,11,27,49,...
    48,29,28,13,52,14,32,50,51,30,31,2,46,10,26,1,45,9,25,3,53,15,33,4,54,16,34];
const_64APSK = const_64APSK(index);

% 64APSK constellation plot
% numSymbols = length(constellation_64APSK); 
% figure();
% scatter(real(constellation_64APSK), imag(constellation_64APSK),'filled');grid on; 
% for i = 1:numSymbols
%     text(real(constellation_64APSK(i))+0.05,imag(constellation_64APSK(i))+0.05,num2str(dec2bin(i-1,6)),'FontSize',10,...
%          'HorizontalAlignment','center','VerticalAlignment','middle');
% end
% xlabel('I (In-phase)');
% ylabel('Q (Quadrature)');
% title('Normalized DVB-S2X 64APSK Constellation [Code Rate 4/5]');

end

