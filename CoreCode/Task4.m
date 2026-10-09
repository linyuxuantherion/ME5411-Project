% input
folder = fileparts(mfilename('fullpath'));
I = imread(fullfile(folder, 'TestOutput', 'Task3_Output.png'));

% parameter
threshold = 128;

% transform
J = I > threshold;

% show
view = figure;
subplot(2, 1, 1); imagesc(I, [0 255]); axis image off;
subplot(2, 1, 2); imagesc(uint8(J) * 255, [0 255]); axis image off;
colormap(view, gray(256));

% output
outputFolder = fullfile(folder, 'TestOutput');
if ~isfolder(outputFolder), mkdir(outputFolder); end
imwrite(J, fullfile(outputFolder, 'Task4_Output.png'));
