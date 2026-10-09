% input
folder = fileparts(mfilename('fullpath'));
I = imread(fullfile(folder, 'TestOutput', 'Task4_Output.png')) ~= 0;

% parameter
connectivity = 8;

% Label
[height, width] = size(I);
labels = zeros(height, width, 'uint32');
boxes = zeros(0, 4);
centroids = zeros(0, 2);
areas = zeros(0, 1);
totalCount = 0;
if any(I(:))
    provisional = zeros(height, width, 'uint32');
    parents = zeros(nnz(I), 1, 'uint32');
    nextLabel = 0;
    neighbors = zeros(1, 4, 'uint32');
    for row = 1:height
        for column = 1:width
            if ~I(row, column)
                continue;
            end
            neighbors(:) = 0;
            if column > 1
                neighbors(1) = provisional(row, column - 1);
            end
            if row > 1
                neighbors(2) = provisional(row - 1, column);
                if connectivity == 8
                    if column > 1
                        neighbors(3) = provisional(row - 1, column - 1);
                    end
                    if column < width
                        neighbors(4) = provisional(row - 1, column + 1);
                    end
                end
            end
            candidates = neighbors(neighbors ~= 0);
            if isempty(candidates)
                nextLabel = nextLabel + 1;
                parents(nextLabel) = nextLabel;
                provisional(row, column) = nextLabel;
            else
                for index = 1:numel(candidates)
                    root = candidates(index);
                    while parents(root) ~= root
                        root = parents(root);
                    end
                    candidates(index) = root;
                end
                smallest = min(candidates);
                parents(candidates) = smallest;
                provisional(row, column) = smallest;
            end
        end
    end
    roots = zeros(nextLabel, 1, 'uint32');
    for index = 1:nextLabel
        root = uint32(index);
        while parents(root) ~= root
            root = parents(root);
        end
        roots(index) = root;
    end
    foreground = find(I);
    [~, ~, componentIds] = unique(roots(double(provisional(foreground))));
    totalCount = max(componentIds);
    [rows, columns] = ind2sub([height, width], foreground);
    allAreas = accumarray(componentIds, 1, [totalCount, 1]);
    centerX = accumarray(componentIds, columns, [totalCount, 1]) ./ allAreas;
    centerY = accumarray(componentIds, rows, [totalCount, 1]) ./ allAreas;
    allBoxes = [accumarray(componentIds, rows, [totalCount, 1], @min), ...
        accumarray(componentIds, columns, [totalCount, 1], @min), ...
        accumarray(componentIds, rows, [totalCount, 1], @max), ...
        accumarray(componentIds, columns, [totalCount, 1], @max)];
    [~, areaOrder] = sortrows([-allAreas, centerX, centerY, (1:totalCount)']);
    selected = areaOrder;
    mapping = zeros(totalCount, 1, 'uint32');
    mapping(selected) = uint32(1:totalCount);
    labels(foreground) = mapping(componentIds);
    boxes = allBoxes(selected, :);
    centroids = [centerX(selected), centerY(selected)];
    areas = allAreas(selected);
end

% show
palette = uint8([255 255 255; 220 45 55; 0 105 200; 0 145 70; ...
    150 55 190; 225 115 0; 0 150 165; 185 45 125; 120 135 0; ...
    90 95 210; 150 85 40; 100 120 140]);
rgb = reshape(palette(min(double(labels(:)), 11) + 1, :), [size(I), 3]);
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
    mask = false(5, 4 * numel(digits) - 1);
    for d = 1:numel(digits)
        mask(:, 4*(d-1)+(1:3)) = reshape(glyphs{digits(d)-'0'+1} == '1', 3, 5)';
    end
    y = max(1, min(boxes(k, 1)+1, size(I, 1)-4));
    x = max(1, min(boxes(k, 2)+1, size(I, 2)-size(mask, 2)+1));
    r = y:min(size(I, 1), y+4);
    c = x:min(size(I, 2), x+size(mask, 2)-1);
    rgb(r, c, :) = repmat(uint8(~mask(1:numel(r), 1:numel(c))) * 255, 1, 1, 3);
end
original = repmat(uint8(I) * 255, 1, 1, 3);
view = figure;
subplot(2, 1, 1); image(original); axis image off;
subplot(2, 1, 2); image(rgb); axis image off;

% output
outputFolder = fullfile(folder, 'TestOutput');
if ~isfolder(outputFolder), mkdir(outputFolder); end
save(fullfile(outputFolder, 'Task6_InitialLabeling.mat'), 'labels');
writetable(array2table(boxes, VariableNames={'TopRow', 'LeftColumn', 'BottomRow', 'RightColumn'}), ...
    fullfile(outputFolder, 'Task6_InitialLabeling.csv'));
