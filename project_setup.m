%% ==== Sets up MATLAB/Simulink project environment ==== %%
% get the root of the project
root = fileparts(mfilename('fullpath'));

% add folders to Matlab path
addpath(fullfile(root, 'src', 'functions'));
addpath(fullfile(root, 'src', 'scripts'));
addpath(fullfile(root, 'models'));
addpath(fullfile(root, 'data'));

% add external tools path
hdlsetuptoolpath('ToolName','Xilinx Vivado',...
                 'ToolPath','C:\Xilinx\Vivado\2023.1\bin\vivado.bat');

disp('Project environment set up successfully');


