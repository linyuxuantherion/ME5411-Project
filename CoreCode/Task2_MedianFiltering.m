% input
folder = fileparts(mfilename('fullpath'));
I = imread(fullfile(folder, '..', 'dataset_2026', 'Test_Image_2026.bmp'));
if ndims(I) == 3
    rgb = double(I);
    I = uint8(round(0.298936021293775 * rgb(:, :, 1) + ...
        0.587043074451121 * rgb(:, :, 2) + 0.114020904255103 * rgb(:, :, 3)));
end

% parameter
n = 5;

% transform
[h, w] = size(I);
r = (n - 1) / 2;
P = I(min(max((1-r):(h+r), 1), h), min(max((1-r):(w+r), 1), w));
minimumGray = double(min(P(:)));
maximumGray = double(max(P(:)));
numberOfBins = maximumGray - minimumGray + 1;
numberOfRows = size(P, 1);
rowIndices = (1:numberOfRows).';
rowHistograms = zeros(numberOfRows, numberOfBins, 'single');
for column = 1:n
    indices = rowIndices + numberOfRows * (double(P(:, column)) - minimumGray);
    rowHistograms(indices) = rowHistograms(indices) + 1;
end
medianRank = (n^2 + 1) / 2;
J = zeros(h, w, 'uint8');
for column = 1:w
    verticalSums = [zeros(1, numberOfBins, 'single'); cumsum(rowHistograms, 1)];
    windowHistograms = verticalSums((n + 1):end, :) ...
        - verticalSums(1:(end - n), :);
    cumulativeCounts = cumsum(windowHistograms, 2);
    J(:, column) = uint8(minimumGray + sum(cumulativeCounts < medianRank, 2));
    if column < w
        outgoing = rowIndices + numberOfRows * ...
            (double(P(:, column)) - minimumGray);
        incoming = rowIndices + numberOfRows * ...
            (double(P(:, column + n)) - minimumGray);
        rowHistograms(outgoing) = rowHistograms(outgoing) - 1;
        rowHistograms(incoming) = rowHistograms(incoming) + 1;
    end
end

% show
view = figure;
subplot(2, 1, 1); imagesc(I, [0 255]); axis image off;
subplot(2, 1, 2); imagesc(J, [0 255]); axis image off;
colormap(view, gray(256));

% output
outputFolder = fullfile(folder, 'TestOutput');
if ~isfolder(outputFolder), mkdir(outputFolder); end
imwrite(J, fullfile(outputFolder, 'Task2_Output.png'));
