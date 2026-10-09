% input
folder = fileparts(mfilename('fullpath'));
I = imread(fullfile(folder, 'TestOutput', 'Task4_Output.png')) ~= 0;

% parameter
threshold = 0.2;

% transform
[h, w] = size(I);
P = double(I([1, 1:h, h], [1, 1:w, w]));
Gy = conv2(P, [1 2 1; 0 0 0; -1 -2 -1], 'valid');
Gx = conv2(P, [1 0 -1; 2 0 -2; 1 0 -1], 'valid');
M = min(1, hypot(Gx, Gy) / (4 * sqrt(2)));
J = M > threshold;

% show
view = figure;
subplot(2, 1, 1); imagesc(uint8(I) * 255, [0 255]); axis image off;
subplot(2, 1, 2); imagesc(uint8(J) * 255, [0 255]); axis image off;
colormap(view, gray(256));

% output
outputFolder = fullfile(folder, 'TestOutput');
if ~isfolder(outputFolder), mkdir(outputFolder); end
imwrite(J, fullfile(outputFolder, 'Task5_Output1.png'));
