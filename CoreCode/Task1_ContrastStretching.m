% input
folder = fileparts(mfilename('fullpath'));
I = imread(fullfile(folder, '..', 'dataset_2026', 'Test_Image_2026.bmp'));
if ndims(I) == 3
    rgb = double(I);
    I = uint8(round(0.298936021293775 * rgb(:, :, 1) + ...
        0.587043074451121 * rgb(:, :, 2) + 0.114020904255103 * rgb(:, :, 3)));
end

% parameter
r1 = 80;
r2 = 140;
s1 = 30;
s2 = 220;

% transform
r = double(I);
J = zeros(size(I));
low = r <= r1; middle = r > r1 & r <= r2; high = r > r2;
J(low) = s1 * r(low) / r1;
J(middle) = s1 + (s2-s1) * (r(middle)-r1) / (r2-r1);
J(high) = s2 + (255-s2) * (r(high)-r2) / (255-r2);
J = uint8(round(min(max(J, 0), 255)));

% show
view = figure;
subplot(2, 1, 1); imagesc(I, [0 255]); axis image off;
subplot(2, 1, 2); imagesc(J, [0 255]); axis image off;
colormap(view, gray(256));

% output
outputFolder = fullfile(folder, 'TestOutput');
if ~isfolder(outputFolder), mkdir(outputFolder); end
imwrite(J, fullfile(outputFolder, 'Task1_Output.png'));
