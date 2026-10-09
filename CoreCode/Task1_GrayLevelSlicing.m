% input
folder = fileparts(mfilename('fullpath'));
I = imread(fullfile(folder, '..', 'dataset_2026', 'Test_Image_2026.bmp'));
if ndims(I) == 3
    rgb = double(I);
    I = uint8(round(0.298936021293775 * rgb(:, :, 1) + ...
        0.587043074451121 * rgb(:, :, 2) + 0.114020904255103 * rgb(:, :, 3)));
end

% parameter
A = 80;
B = 140;
s_in = 255;
s_out = 0;

% transform
if isequal(s_out, 'r')
    J = I;
else
    J = repmat(uint8(s_out), size(I));
end
J(I >= A & I <= B) = s_in;

% show
view = figure;
subplot(2, 1, 1); imagesc(I, [0 255]); axis image off;
subplot(2, 1, 2); imagesc(J, [0 255]); axis image off;
colormap(view, gray(256));

% output
outputFolder = fullfile(folder, 'TestOutput');
if ~isfolder(outputFolder), mkdir(outputFolder); end
imwrite(J, fullfile(outputFolder, 'Task1_Output.png'));
