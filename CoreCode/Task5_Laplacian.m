% input
folder = fileparts(mfilename('fullpath'));
I = imread(fullfile(folder, 'TestOutput', 'Task4_Output.png')) ~= 0;

% parameter
threshold = 0.2;

% transform
[h, w] = size(I);
P = double(I([1, 1:h, h], [1, 1:w, w]));
L = conv2(P, [0 -1 0; -1 4 -1; 0 -1 0], 'valid');
[h, w] = size(I);
J = false(h, w);
offsets = [0 1; 1 -1; 1 0; 1 1];
for k = 1:4
    dy = offsets(k, 1); dx = offsets(k, 2);
    r = max(1, 1-dy):min(h, h-dy);
    c = max(1, 1-dx):min(w, w-dx);
    a = L(r, c); b = L(r+dy, c+dx);
    crossing = a .* b < 0 & abs(a-b) > 8 * threshold;
    J(r, c) = J(r, c) | (crossing & abs(a) <= abs(b));
    J(r+dy, c+dx) = J(r+dy, c+dx) | (crossing & abs(a) > abs(b));
    r = 1+abs(dy):h-abs(dy); c = 1+abs(dx):w-abs(dx);
    a = L(r-dy, c-dx); b = L(r+dy, c+dx);
    J(r, c) = J(r, c) | (L(r, c) == 0 & a .* b < 0 & abs(a-b) > 8 * threshold);
end

% show
view = figure;
subplot(2, 1, 1); imagesc(uint8(I) * 255, [0 255]); axis image off;
subplot(2, 1, 2); imagesc(uint8(J) * 255, [0 255]); axis image off;
colormap(view, gray(256));

% output
outputFolder = fullfile(folder, 'TestOutput');
if ~isfolder(outputFolder), mkdir(outputFolder); end
imwrite(J, fullfile(outputFolder, 'Task5_Output1.png'));
