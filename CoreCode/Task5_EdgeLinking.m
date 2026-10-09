% input
folder = fileparts(mfilename('fullpath'));
I = imread(fullfile(folder, 'TestOutput', 'Task5_Output1.png')) ~= 0;

% parameter
n = 5;
magnitudeDifference = 0.1;
directionDifference = 20;

% transform
[h, w] = size(I);
P = double(I([1, 1:h, h], [1, 1:w, w]));
Gy = conv2(P, [1 2 1; 0 0 0; -1 -2 -1], 'valid');
Gx = conv2(P, [1 0 -1; 2 0 -2; 1 0 -1], 'valid');
M = min(1, hypot(Gx, Gy) / (4 * sqrt(2)));
D = atan2d(Gx, Gy);
J = I;
[h, w] = size(I);
radius = (n - 1) / 2;
for dy = 0:radius
    for dx = -radius:radius
        if dy == 0 && dx <= 0, continue; end
        r = max(1, 1-dy):min(h, h-dy);
        c = max(1, 1-dx):min(w, w-dx);
        if isempty(r) || isempty(c), continue; end
        angle = abs(D(r, c) - D(r+dy, c+dx));
        angle = min(angle, 360-angle);
        accepted = I(r, c) & I(r+dy, c+dx) ...
            & M(r, c) > 0 & M(r+dy, c+dx) > 0 ...
            & abs(M(r, c) - M(r+dy, c+dx)) <= magnitudeDifference ...
            & angle <= directionDifference;
        if max(abs([dy dx])) == 2
            [y, x] = find(accepted);
            y = y + r(1) - 1 + round(dy / 2);
            x = x + c(1) - 1 + round(dx / 2);
            J(sub2ind([h w], y, x)) = true;
        end
    end
end

% show
view = figure;
subplot(2, 1, 1); imagesc(uint8(I) * 255, [0 255]); axis image off;
subplot(2, 1, 2); imagesc(uint8(J) * 255, [0 255]); axis image off;
colormap(view, gray(256));

% output
outputFolder = fullfile(folder, 'TestOutput');
if ~isfolder(outputFolder), mkdir(outputFolder); end
imwrite(J, fullfile(outputFolder, 'Task5_Output2.png'));
