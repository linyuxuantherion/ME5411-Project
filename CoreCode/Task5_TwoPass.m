% input
folder = fileparts(mfilename('fullpath'));
I = imread(fullfile(folder, 'TestOutput', 'Task4_Output.png')) ~= 0;

% transform
J = false(size(I));
J(:, 2:end) = I(:, 2:end) ~= I(:, 1:end-1);
J(2:end, :) = J(2:end, :) | I(2:end, :) ~= I(1:end-1, :);

% show
view = figure;
subplot(2, 1, 1); imagesc(uint8(I) * 255, [0 255]); axis image off;
subplot(2, 1, 2); imagesc(uint8(J) * 255, [0 255]); axis image off;
colormap(view, gray(256));

% output
outputFolder = fullfile(folder, 'TestOutput');
if ~isfolder(outputFolder), mkdir(outputFolder); end
imwrite(J, fullfile(outputFolder, 'Task5_Output1.png'));
