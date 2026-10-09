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
m = min(n, 2 * floor((n + 1) / 4) + 1);
d = (n - m) / 2;
offsets = [d d; 0 0; 0 d; 0 2*d; d 0; d 2*d; 2*d 0; 2*d d; 2*d 2*d];
[h, w] = size(I);
r = (n - 1) / 2;
P = I(min(max((1-r):(h+r), 1), h), min(max((1-r):(w+r), 1), w));
P = double(P);
S = squareWindowSums(makeSummedArea(P), m);
Q = squareWindowSums(makeSummedArea(P.^2), m);
best = inf(size(I));
J = zeros(size(I));
for k = 1:9
    rows = (1:size(I, 1)) + offsets(k, 1);
    cols = (1:size(I, 2)) + offsets(k, 2);
    sums = S(rows, cols);
    score = m^2 * Q(rows, cols) - sums.^2;
    selected = score < best;
    best(selected) = score(selected);
    J(selected) = sums(selected) / m^2;
end
J = uint8(J);

% show
view = figure;
subplot(2, 1, 1); imagesc(I, [0 255]); axis image off;
subplot(2, 1, 2); imagesc(J, [0 255]); axis image off;
colormap(view, gray(256));

% output
outputFolder = fullfile(folder, 'TestOutput');
if ~isfolder(outputFolder), mkdir(outputFolder); end
imwrite(J, fullfile(outputFolder, 'Task2_Output.png'));

function summedArea = makeSummedArea(pixels)
    summedArea = zeros(size(pixels) + 1);
    summedArea(2:end, 2:end) = cumsum(cumsum(pixels, 1), 2);
end

function sums = squareWindowSums(summedArea, width)
    sums = summedArea((width + 1):end, (width + 1):end) ...
        - summedArea(1:(end - width), (width + 1):end) ...
        - summedArea((width + 1):end, 1:(end - width)) ...
        + summedArea(1:(end - width), 1:(end - width));
end
