% input
folder = fileparts(mfilename('fullpath'));
data = load(fullfile(folder, 'TestOutput', 'Task6_InitialLabeling.mat'));
initialLabels = data.labels;
initialBoxes = readmatrix(fullfile(folder, 'TestOutput', 'Task6_InitialLabeling.csv'));

% parameter
expectedWidth = 88;
tolerance = 15;

% Label
parts = cell(0, 1);
for k = 1:size(initialBoxes, 1)
    b = initialBoxes(k, :);
    mask = initialLabels(b(1):b(3), b(2):b(4)) == k;
    [y, x] = find(mask);
    pixels = [y+b(1)-1, x+b(2)-1];
    width = b(4)-b(2)+1;
    if width < expectedWidth-tolerance, continue; end
    edges = [0; width];
    if width > expectedWidth+tolerance
        count = min(width, max(2, round(width / expectedWidth)));
        nominal = (1:count-1)' * width / count;
        cells = [0; floor((nominal(1:end-1)+nominal(2:end))/2); width-1];
        projection = sum(mask, 1)';
        cuts = zeros(count-1, 1);
        for j = 1:count-1
            first = max([1, round(nominal(j))-tolerance, cells(j)+1]);
            last = min([width-1, round(nominal(j))+tolerance, cells(j+1)]);
            candidates = (first:last)';
            [~, order] = sortrows([projection(candidates), abs(candidates-nominal(j)), candidates]);
            cuts(j) = candidates(order(1));
        end
        edges = [0; cuts; width];
    end
    for j = 1:numel(edges)-1
        part = pixels(x > edges(j) & x <= edges(j+1), :);
        if ~isempty(part) && max(part(:, 2))-min(part(:, 2))+1 >= expectedWidth-tolerance
            parts{end+1, 1} = part;
        end
    end
end
boxes = zeros(numel(parts), 4);
centers = zeros(numel(parts), 2);
for k = 1:numel(parts)
    p = parts{k};
    boxes(k, :) = [min(p(:, 1)), min(p(:, 2)), max(p(:, 1)), max(p(:, 2))];
    centers(k, :) = [mean(p(:, 2)), mean(p(:, 1))];
end
[~, order] = sortrows([centers, boxes(:, 1:2), (1:numel(parts))']);
labels = zeros(size(initialLabels), 'uint32');
for k = 1:numel(parts)
    p = parts{order(k)};
    labels(sub2ind(size(labels), p(:, 1), p(:, 2))) = k;
end
boxes = boxes(order, :);

% show
palette = uint8([255 255 255; 220 45 55; 0 105 200; 0 145 70; ...
    150 55 190; 225 115 0; 0 150 165; 185 45 125; 120 135 0; ...
    90 95 210; 150 85 40; 100 120 140]);
rgb = reshape(palette(min(double(labels(:)), 11)+1, :), [size(labels), 3]);
for k = 1:size(boxes, 1)
    b = boxes(k, :);
    rgb([b(1), b(3)], b(2):b(4), :) = 0;
    rgb(b(1):b(3), [b(2), b(4)], :) = 0;
end
glyphs = {'111101101101111', '010110010010111', '111001111100111', ...
    '111001111001111', '101101111001001', '111100111001111', ...
    '111100111101111', '111001001001001', '111101111101111', '111101111001111'};
for k = 1:size(boxes, 1)
    digits = sprintf('%d', k);
    mask = false(5, 4*numel(digits)-1);
    for d = 1:numel(digits)
        mask(:, 4*(d-1)+(1:3)) = reshape(glyphs{digits(d)-'0'+1} == '1', 3, 5)';
    end
    y = max(1, min(boxes(k, 1)+1, size(labels, 1)-4));
    x = max(1, min(boxes(k, 2)+1, size(labels, 2)-size(mask, 2)+1));
    r = y:min(size(labels, 1), y+4);
    c = x:min(size(labels, 2), x+size(mask, 2)-1);
    rgb(r, c, :) = repmat(uint8(~mask(1:numel(r), 1:numel(c))) * 255, 1, 1, 3);
end
view = figure;
image(rgb); axis image off;

% output
outputFolder = fullfile(folder, 'TestOutput');
if ~isfolder(outputFolder), mkdir(outputFolder); end
save(fullfile(outputFolder, 'Task6_Relabeling.mat'), 'labels');
writetable(array2table(boxes, VariableNames={'TopRow', 'LeftColumn', 'BottomRow', 'RightColumn'}), ...
    fullfile(outputFolder, 'Task6_Relabeling.csv'));
