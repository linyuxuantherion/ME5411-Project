% input
folder = fileparts(mfilename('fullpath'));
I = imread(fullfile(folder, 'TestOutput', 'Task4_Output.png')) ~= 0;
data = load(fullfile(folder, 'TestOutput', 'Task6_Relabeling.mat'));
labels = data.labels;
boxes = readmatrix(fullfile(folder, 'TestOutput', 'Task6_Relabeling.csv'));

% Cut
assert(isequal(size(I), size(labels)), 'Image and label matrix sizes must match.');
regions = double(max(labels(:)));
assert(size(boxes, 1) == regions, 'Bounding boxes must match the region count.');
characters = cell(regions, 1);
for k = 1:regions
    b = boxes(k, :);
    characters{k} = I(b(1):b(3), b(2):b(4));
end

% output
outputFolder = fullfile(folder, 'TestOutput');
if ~isfolder(outputFolder), mkdir(outputFolder); end
for k = 1:regions
    imwrite(characters{k}, fullfile(outputFolder, sprintf('Task6_Character_%d.png', k)));
end
