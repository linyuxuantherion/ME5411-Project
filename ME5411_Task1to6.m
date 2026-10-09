%% ME5411 - Tasks 1-6
scriptPath = which('ME5411_Task1to6.m');
if isempty(scriptPath)
    projectFolder = pwd;
else
    projectFolder = fileparts(scriptPath);
end
guiWindow = launchImageProcessingGUI(projectFolder);

%% Local Functions
function window = launchImageProcessingGUI(projectFolder)
    windowTag = 'ME5411_ImageProcessingGUI';
    interfaceVersion = 40;
    existingWindow = findall(groot, 'Type', 'figure', 'Tag', windowTag);
    if ~isempty(existingWindow)
        window = existingWindow(1);
        if isstruct(window.UserData) && isfield(window.UserData, 'InterfaceVersion') ...
                && window.UserData.InterfaceVersion == interfaceVersion ...
                && isfield(window.UserData, 'ImagePath') ...
                && strcmp(window.UserData.ImagePath, ...
                    fullfile(projectFolder, 'dataset_2026', 'Test_Image_2026.bmp'))
            window.Visible = 'on';
            if strcmp(window.WindowState, 'minimized')
                window.WindowState = 'normal';
            end
            return;
        end
        delete(existingWindow);
    end

    imagePath = fullfile(projectFolder, 'dataset_2026', 'Test_Image_2026.bmp');
    if isfile(imagePath)
        grayImage = readGrayscaleImage(imagePath);
    else
        grayImage = zeros(0, 0, 'uint8');
    end
    inputIndices = double(grayImage(:)) + 1;
    inputCounts = zeros(256, 1);
    if ~isempty(grayImage)
        inputCounts = accumarray(inputIndices, 1, [256, 1]);
    end
    taskNames = {'Task 1 - Contrast Enhancement', ...
        'Task 2 - Image Smoothing', ...
        'Task 3 - Sub-image Extraction', ...
        'Task 4 - Binarization', ...
        'Task 5 - Character Outlines', ...
        'Task 6 - Character Segmentation'};
    methodNames = {'Contrast Stretching', 'Gray-Level Slicing', ...
        'Dynamic Range Compression', 'Histogram Equalization'};
    methodDefinitions = getEnhancementParameterDefinitions();
    methodParameters = cellfun(@(definition) definition.DefaultValues, ...
        methodDefinitions, 'UniformOutput', false);
    currentTask = 1;
    currentMethod = 1;
    parameters = methodParameters{currentMethod};
    parameterDefinition = methodDefinitions{currentMethod};
    slicePreserveBackground = false;
    filterNames = {'Mean Filtering', 'Rotating mask', 'Median Filtering'};
    currentFilter = 1;
    neighborhoodWidth = 5;
    neighborhoodLimits = [1, 31];
    lastTask2Filter = 0;
    lastTask2Width = 0;
    [imageHeight, imageWidth] = size(grayImage);
    % Positive layout bounds only; an absent source remains an empty image.
    imageHeight = max(2, imageHeight);
    imageWidth = max(2, imageWidth);
    cropBounds = min([56, 201, 946, 341], ...
        [imageWidth, imageHeight, imageWidth, imageHeight]);
    cropDrag = struct('Active', false, 'Mode', '', 'StartPoint', [0, 0], ...
        'StartBounds', cropBounds);
    task4InputPath = fullfile(projectFolder, 'Task1-6_Output', 'Task3_Sub-image.png');
    task4InputImage = zeros(0, 0, 'uint8');
    binaryThreshold = 128;
    edgeMethodNames = {'Two-pass', 'Sobel', 'Laplacian'};
    task5State = struct('MethodIndex', 1, 'UseBinaryImage', true, 'SmoothingEnabled', false, ...
        'SmoothingFilterIndex', 1, 'SmoothingWidth', 5, 'EdgeThreshold', 0.2, ...
        'LaplacianThreshold', 0.2, ...
        'LinkingEnabled', true, 'LinkNeighborhoodWidth', 3, ...
        'MagnitudeDifference', 0.1, 'DirectionDifference', 20);
    task5SourceImage = zeros(0, 0, 'uint8');
    task5SourcePath = '';
    task5SourceMessage = '';
    task5Cache = struct('Key', [], 'WorkImage', [], 'Magnitude', [], ...
        'Direction', [], 'Laplacian', [], 'ScanEdges', []);
    task5EdgeImage = false(0, 0);
    task5FinalImage = false(0, 0);
    task5LinkCount = 0;
    task5ProcessingSeconds = 0;
    task6State = struct('ExpectedWidth', 88, 'Tolerance', 15, 'Connectivity', 8);
    task6InputPath = fullfile(projectFolder, 'Task1-6_Output', 'Task4_Binary.png');
    task6InputImage = false(0, 0);
    task6InputMessage = '';
    task6InitialLabels = zeros(0, 0, 'uint32');
    task6InitialBoxes = zeros(0, 4);
    task6InitialCentroids = zeros(0, 2);
    task6InitialAreas = zeros(0, 1);
    task6InitialImage = zeros(0, 0, 3, 'uint8');
    task6LabelMatrix = zeros(0, 0, 'uint32');
    task6BoundingBoxes = zeros(0, 4);
    task6Centroids = zeros(0, 2);
    task6Areas = zeros(0, 1);
    task6RegionCount = 0;
    task6TotalRegionCount = 0;
    task6LabeledImage = zeros(0, 0, 3, 'uint8');
    task6InitialKey = [];
    task6LabelKey = [];
    task6ProcessingSeconds = 0;

    taskSelector = gobjects(1);
    exportButton = gobjects(1);
    methodSelector = gobjects(1);
    task1Content = gobjects(1);
    task2Content = gobjects(1);
    task3Content = gobjects(1);
    task4Content = gobjects(1);
    task4OriginalAxes = gobjects(1);
    task4BinaryAxes = gobjects(1);
    task4OriginalDisplay = gobjects(1);
    task4BinaryDisplay = gobjects(1);
    task4InputMessage = gobjects(1);
    thresholdField = gobjects(1);
    thresholdSlider = gobjects(1);
    task5Content = gobjects(1);
    task5MethodSelector = gobjects(1);
    task5BinaryToggle = gobjects(1);
    task5SmoothingToggle = gobjects(1);
    task5SmoothingControls = gobjects(1);
    task5FilterSelector = gobjects(1);
    task5WidthField = gobjects(1);
    task5WidthSlider = gobjects(1);
    task5EdgeControls = gobjects(1);
    task5EdgeField = gobjects(1);
    task5EdgeSlider = gobjects(1);
    task5OriginalAxes = gobjects(1);
    task5OriginalDisplay = gobjects(1);
    task5OriginalNote = gobjects(1);
    task5EdgeAxes = gobjects(1);
    task5EdgeDisplay = gobjects(1);
    task5LinkArea = gobjects(1);
    task5LinkLeft = gobjects(1);
    task5LinkToggle = gobjects(1);
    task5LinkControls = gobjects(1);
    task5LinkResult = gobjects(1);
    task5LinkedAxes = gobjects(1);
    task5LinkedDisplay = gobjects(1);
    task5LinkFields = gobjects(1, 2);
    task5LinkSliders = gobjects(1, 2);
    task5LinkWidthGroup = gobjects(1);
    task6Content = gobjects(1);
    task6WidthFields = gobjects(1, 2);
    task6WidthSliders = gobjects(1, 2);
    task6ConnectivityGroup = gobjects(1);
    task6OriginalAxes = gobjects(1);
    task6InitialAxes = gobjects(1);
    task6LabeledAxes = gobjects(1);
    task6OriginalDisplay = gobjects(1);
    task6InitialDisplay = gobjects(1);
    task6LabeledDisplay = gobjects(1);
    task6OriginalNote = gobjects(1);
    task3OriginalAxes = gobjects(1);
    task3ProcessedAxes = gobjects(1);
    task3ProcessedDisplay = gobjects(1);
    cropOverlay = gobjects(1);
    cropHandles = gobjects(1, 8);
    cropSpinners = gobjects(1, 4);
    filterSelector = gobjects(1);
    neighborhoodField = gobjects(1);
    neighborhoodSlider = gobjects(1);
    placeholder = gobjects(1);
    histogramAxes = gobjects(1);
    histogramBars = gobjects(1);
    transferLine = gobjects(1);
    transferSteps = gobjects(1);
    processedDisplay = gobjects(1);
    task2ProcessedDisplay = gobjects(1);
    sliders = gobjects(1, 4);
    fields = gobjects(1, 4);
    parameterLabels = gobjects(1, 4);
    controlGrid = gobjects(1);
    sliceBackgroundToggle = gobjects(1);
    formulaLabel = gobjects(1);

    screen = get(groot, 'ScreenSize');
    defaultSize = getTaskDefaultWindowSize(currentTask, task5State);
    windowWidth = min(defaultSize(1), screen(3) - 60);
    windowHeight = min(defaultSize(2), screen(4) - 100);
    window = uifigure('Name', 'ME5411 | Image Processing', ...
        'Tag', windowTag, 'Visible', 'off', ...
        'Position', [screen(1) + (screen(3) - windowWidth) / 2, ...
        screen(2) + (screen(4) - windowHeight) / 2, windowWidth, windowHeight]);
    try
        buildInterface();
        configureParameters();
        refreshOutput([]);
        refreshTask3Output([]);
        window.Visible = 'on';
    catch exception
        delete(window);
        rethrow(exception);
    end

    function buildInterface()
        rootGrid = uigridlayout(window, [2, 1]);
        rootGrid.RowHeight = {40, '1x'};
        rootGrid.Padding = [16, 12, 16, 12];
        rootGrid.RowSpacing = 10;

        headerGrid = uigridlayout(rootGrid, [1, 2]);
        headerGrid.Layout.Row = 1;
        headerGrid.Layout.Column = 1;
        headerGrid.ColumnWidth = {'1x', 140};
        headerGrid.Padding = [0, 0, 0, 0];
        headerGrid.ColumnSpacing = 12;

        taskSelector = uidropdown(headerGrid, 'Items', taskNames, ...
            'ItemsData', 1:6, 'Value', currentTask, 'FontSize', 18, ...
            'Tag', 'ME5411TaskSelector', ...
            'ValueChangedFcn', @(~, event) changeTask(event.Value));
        taskSelector.Layout.Row = 1;
        taskSelector.Layout.Column = 1;

        exportButton = uibutton(headerGrid, 'push', 'Text', 'Export Image', ...
            'FontSize', 16, 'Tag', 'ME5411ExportImageButton', ...
            'Tooltip', 'Save the current grayscale result to Task1-6_Output.', ...
            'ButtonPushedFcn', @(~, ~) exportCurrentImage());
        exportButton.Layout.Row = 1;
        exportButton.Layout.Column = 2;

        task1Content = uigridlayout(rootGrid, [2, 1]);
        task1Content.Layout.Row = 2;
        task1Content.Layout.Column = 1;
        task1Content.RowHeight = {'1x', 340};
        task1Content.Padding = [0, 0, 0, 0];
        task1Content.RowSpacing = 12;

        displayGrid = uigridlayout(task1Content, [2, 2]);
        displayGrid.Layout.Row = 1;
        displayGrid.Layout.Column = 1;
        displayGrid.RowHeight = {'1x', '1x'};
        displayGrid.ColumnWidth = {'1x', '1x'};
        displayGrid.Padding = [0, 0, 0, 0];
        displayGrid.RowSpacing = 16;
        displayGrid.ColumnSpacing = 20;

        originalAxes = uiaxes(displayGrid, 'Tag', 'Task1OriginalAxes');
        originalAxes.Layout.Row = 1;
        originalAxes.Layout.Column = 1;
        image(originalAxes, grayImage, 'CDataMapping', 'scaled', ...
            'Tag', 'Task1OriginalImage');
        configureImageAxes(originalAxes, 'Original Image');
        showMissingOriginal(displayGrid, originalAxes, 'Task1InputMessage');

        originalHistogramAxes = uiaxes(displayGrid, ...
            'Tag', 'Task1OriginalHistogramAxes');
        originalHistogramAxes.Layout.Row = 1;
        originalHistogramAxes.Layout.Column = 2;
        bar(originalHistogramAxes, 0:255, inputCounts.', 1, ...
            'Tag', 'Task1OriginalHistogram');
        configureHistogramAxes(originalHistogramAxes);
        originalHistogramAxes.YLim = [0, max(1, max(inputCounts) * 1.08)];
        if isempty(grayImage)
            originalHistogramAxes.Visible = 'off';
            originalHistogramAxes.Children.Visible = 'off';
        end

        processedAxes = uiaxes(displayGrid, 'Tag', 'Task1ProcessedAxes');
        processedAxes.Layout.Row = 2;
        processedAxes.Layout.Column = 1;
        processedDisplay = image(processedAxes, grayImage, ...
            'CDataMapping', 'scaled', 'Tag', 'Task1ProcessedImage');
        configureImageAxes(processedAxes, 'Processed Image');

        histogramAxes = uiaxes(displayGrid, 'Tag', 'Task1HistogramAxes');
        histogramAxes.Layout.Row = 2;
        histogramAxes.Layout.Column = 2;
        histogramBars = bar(histogramAxes, 0:255, zeros(1, 256), 1, ...
            'Tag', 'Task1Histogram');
        configureHistogramAxes(histogramAxes);
        if isempty(grayImage)
            processedAxes.Visible = 'off';
            histogramAxes.Visible = 'off';
            histogramBars.Visible = 'off';
        end

        bottomGrid = uigridlayout(task1Content, [1, 2]);
        bottomGrid.Layout.Row = 2;
        bottomGrid.Layout.Column = 1;
        bottomGrid.ColumnWidth = {'3x', '2x'};
        bottomGrid.Padding = [0, 0, 0, 0];
        bottomGrid.ColumnSpacing = 20;

        controlGrid = uigridlayout(bottomGrid, [7, 3]);
        controlGrid.Layout.Row = 1;
        controlGrid.Layout.Column = 1;
        controlGrid.RowHeight = {32, 26, 26, 26, 0, 26, '1x'};
        controlGrid.ColumnWidth = {36, 40, '1x'};
        controlGrid.Padding = [0, 8, 6, 8];
        controlGrid.RowSpacing = 6;
        controlGrid.ColumnSpacing = 12;

        methodSelector = uidropdown(controlGrid, 'Items', methodNames, ...
            'ItemsData', 1:4, 'Value', currentMethod, 'FontSize', 14, ...
            'Tag', 'Task1MethodSelector', ...
            'ValueChangedFcn', @(~, event) changeMethod(event.Value));
        methodSelector.Layout.Row = 1;
        methodSelector.Layout.Column = [1, 3];

        for parameterIndex = 1:4
            parameterRow = parameterIndex + 1 + (parameterIndex == 4);
            parameterLabels(parameterIndex) = uilabel(controlGrid, ...
                'Text', '', 'Tag', sprintf('Task1Label_%d', parameterIndex));
            parameterLabels(parameterIndex).Layout.Row = parameterRow;
            parameterLabels(parameterIndex).Layout.Column = 1;
            fields(parameterIndex) = uieditfield(controlGrid, 'numeric', ...
                'Limits', [0, 255], 'Value', 0, ...
                'RoundFractionalValues', 'on', 'ValueDisplayFormat', '%.0f', ...
                'Tag', sprintf('Task1Field_%d', parameterIndex), ...
                'ValueChangedFcn', @(src, event) changeParameter( ...
                parameterIndex, event.Value, src, false));
            fields(parameterIndex).Layout.Row = parameterRow;
            fields(parameterIndex).Layout.Column = 2;
            sliders(parameterIndex) = uislider(controlGrid, ...
                'Limits', [0, 255], 'Value', 0, ...
                'MajorTicks', [], 'MinorTicks', [], ...
                'Tag', sprintf('Task1Slider_%d', parameterIndex), ...
                'ValueChangingFcn', @(src, event) changeParameter( ...
                parameterIndex, event.Value, src, true), ...
                'ValueChangedFcn', @(src, event) changeParameter( ...
                parameterIndex, event.Value, src, false));
            sliders(parameterIndex).Layout.Row = parameterRow;
            sliders(parameterIndex).Layout.Column = 3;
        end

        sliceBackgroundToggle = uicheckbox(controlGrid, ...
            'Text', 's_out = r', 'Value', slicePreserveBackground, ...
            'Visible', 'off', 'Tag', 'Task1SliceBackgroundToggle', ...
            'ValueChangedFcn', @(~, event) changeSliceBackground(event.Value));
        sliceBackgroundToggle.Layout.Row = 5;
        sliceBackgroundToggle.Layout.Column = [1, 3];

        formulaLabel = uilabel(controlGrid, 'Text', '', ...
            'Interpreter', 'latex', 'FontSize', 15, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'center', ...
            'Tag', 'Task1Formula');
        formulaLabel.Layout.Row = 7;
        formulaLabel.Layout.Column = [1, 3];

        mappingAxes = uiaxes(bottomGrid, 'Tag', 'Task1MappingAxes');
        mappingAxes.Layout.Row = 1;
        mappingAxes.Layout.Column = 2;
        transferLine = plot(mappingAxes, [0, 80, 140, 255], ...
            [0, 30, 220, 255], '-', 'LineWidth', 2, ...
            'Marker', 'none', 'Tag', 'Task1TransferCurve');
        hold(mappingAxes, 'on');
        transferSteps = stairs(mappingAxes, 0:255, zeros(1, 256), ...
            'LineWidth', 2, 'Visible', 'off', 'Tag', 'Task1TransferSteps');
        hold(mappingAxes, 'off');
        xlabel(mappingAxes, 'r');
        ylabel(mappingAxes, 's');
        mappingAxes.XLim = [0, 255];
        mappingAxes.YLim = [0, 255];
        mappingAxes.XTick = [0, 64, 128, 192, 255];
        mappingAxes.YTick = [0, 64, 128, 192, 255];
        mappingAxes.Box = 'on';
        mappingAxes.Toolbar.Visible = 'off';
        grid(mappingAxes, 'on');

        buildTask2Interface(rootGrid);
        buildTask3Interface(rootGrid);
        buildTask4Interface(rootGrid);
        buildTask5Interface(rootGrid);
        buildTask6Interface(rootGrid);

        if isempty(grayImage)
            set([methodSelector, sliceBackgroundToggle, fields, sliders], 'Enable', 'off');
            set([filterSelector, neighborhoodField, neighborhoodSlider], 'Enable', 'off');
            set(cropSpinners, 'Enable', 'off');
            set([cropOverlay, cropHandles], 'Visible', 'off');
            exportButton.Enable = 'off';
        end

        window.WindowButtonMotionFcn = @(~, event) continueCropDrag(event);
        window.WindowButtonUpFcn = @(~, event) endCropDrag(event);

        placeholder = uilabel(rootGrid, 'Text', 'Not implemented yet.', ...
            'FontSize', 18, 'HorizontalAlignment', 'center', ...
            'Visible', 'off', 'Tag', 'ME5411TaskPlaceholder');
        placeholder.Layout.Row = 2;
        placeholder.Layout.Column = 1;
    end

    function showMissingOriginal(parentGrid, sourceAxes, tag)
        if ~isempty(grayImage)
            return;
        end
        sourceAxes.Visible = 'off';
        set(sourceAxes.Children, 'Visible', 'off');
        missingLabel = uilabel(parentGrid, ...
            'Text', getMissingImageMessage(projectFolder, imagePath), ...
            'HorizontalAlignment', 'center', 'WordWrap', 'on', ...
            'FontSize', 16, 'Tag', tag);
        missingLabel.Layout.Row = sourceAxes.Layout.Row;
        missingLabel.Layout.Column = sourceAxes.Layout.Column;
    end

    function buildTask2Interface(rootGrid)
        task2Content = uigridlayout(rootGrid, [3, 1], ...
            'Visible', 'off', 'Tag', 'Task2Content');
        task2Content.Layout.Row = 2;
        task2Content.Layout.Column = 1;
        task2Content.RowHeight = {'1x', '1x', 32};
        task2Content.Padding = [0, 0, 0, 0];
        task2Content.RowSpacing = 12;

        originalAxes = uiaxes(task2Content, 'Tag', 'Task2OriginalAxes');
        originalAxes.Layout.Row = 1;
        originalAxes.Layout.Column = 1;
        image(originalAxes, grayImage, 'CDataMapping', 'scaled', ...
            'Tag', 'Task2OriginalImage');
        configureImageAxes(originalAxes, 'Original Image');
        showMissingOriginal(task2Content, originalAxes, 'Task2InputMessage');

        processedAxes = uiaxes(task2Content, 'Tag', 'Task2ProcessedAxes');
        processedAxes.Layout.Row = 2;
        processedAxes.Layout.Column = 1;
        task2ProcessedDisplay = image(processedAxes, grayImage, 'CDataMapping', 'scaled', ...
            'Tag', 'Task2ProcessedImage');
        configureImageAxes(processedAxes, 'Processed Image');
        if isempty(grayImage)
            processedAxes.Visible = 'off';
        end

        filterGrid = uigridlayout(task2Content, [1, 4], 'Tag', 'Task2Controls');
        filterGrid.Layout.Row = 3;
        filterGrid.Layout.Column = 1;
        filterGrid.ColumnWidth = {150, 150, 40, '1x'};
        filterGrid.Padding = [0, 3, 6, 3];
        filterGrid.ColumnSpacing = 12;

        filterSelector = uidropdown(filterGrid, 'Items', filterNames, ...
            'ItemsData', 1:3, 'Value', currentFilter, 'FontSize', 14, ...
            'Tag', 'Task2FilterSelector', ...
            'ValueChangedFcn', @(~, event) changeFilter(event.Value));
        filterSelector.Layout.Row = 1;
        filterSelector.Layout.Column = 1;

        widthLabel = uilabel(filterGrid, 'Text', 'Neighborhood Width', ...
            'FontSize', 14, 'Tag', 'Task2NeighborhoodLabel');
        widthLabel.Layout.Row = 1;
        widthLabel.Layout.Column = 2;

        neighborhoodField = uieditfield(filterGrid, 'numeric', ...
            'Limits', neighborhoodLimits, 'Value', neighborhoodWidth, ...
            'RoundFractionalValues', 'on', 'ValueDisplayFormat', '%.0f', ...
            'Tag', 'Task2NeighborhoodField', ...
            'ValueChangedFcn', @(~, event) changeNeighborhoodWidth(event.Value, false, false));
        neighborhoodField.Layout.Row = 1;
        neighborhoodField.Layout.Column = 3;

        % Slider indices represent odd widths: 0 -> 1, 1 -> 3, ..., 15 -> 31.
        neighborhoodSlider = uislider(filterGrid, 'Limits', [0, 15], ...
            'Value', (neighborhoodWidth - 1) / 2, 'MajorTicks', [], 'MinorTicks', [], ...
            'Tag', 'Task2NeighborhoodSlider', ...
            'ValueChangingFcn', @(~, event) changeNeighborhoodWidth(event.Value, true, true), ...
            'ValueChangedFcn', @(~, event) changeNeighborhoodWidth(event.Value, true, false));
        neighborhoodSlider.Layout.Row = 1;
        neighborhoodSlider.Layout.Column = 4;
    end

    function buildTask3Interface(rootGrid)
        task3Content = uigridlayout(rootGrid, [2, 2], ...
            'Visible', 'off', 'Tag', 'Task3Content');
        task3Content.Layout.Row = 2;
        task3Content.Layout.Column = 1;
        task3Content.RowHeight = {'1x', 30};
        task3Content.ColumnWidth = {'1x', '1x'};
        task3Content.Padding = [0, 0, 0, 0];
        task3Content.RowSpacing = 12;
        task3Content.ColumnSpacing = 16;

        task3OriginalAxes = uiaxes(task3Content, 'Tag', 'Task3OriginalAxes');
        task3OriginalAxes.Layout.Row = 1;
        task3OriginalAxes.Layout.Column = 1;
        image(task3OriginalAxes, grayImage, 'CDataMapping', 'scaled', ...
            'Tag', 'Task3OriginalImage');
        configureImageAxes(task3OriginalAxes, 'Original Image');
        task3OriginalAxes.XLim = [0.5, imageWidth + 0.5];
        task3OriginalAxes.YLim = [0.5, imageHeight + 0.5];
        disableDefaultInteractivity(task3OriginalAxes);
        hold(task3OriginalAxes, 'on');
        cropOverlay = patch(task3OriginalAxes, 'XData', [0, 1, 1, 0], ...
            'YData', [0, 0, 1, 1], 'FaceColor', [1, 1, 1], 'FaceAlpha', 0.15, ...
            'EdgeColor', [1, 1, 1], 'LineWidth', 1.5, ...
            'Tag', 'Task3CropOverlay', 'PickableParts', 'all', ...
            'ButtonDownFcn', @(~, event) beginCropDrag('move', event));
        handleModes = {'nw', 'n', 'ne', 'e', 'se', 's', 'sw', 'w'};
        for handleIndex = 1:numel(handleModes)
            mode = handleModes{handleIndex};
            cropHandles(handleIndex) = line(task3OriginalAxes, NaN, NaN, ...
                'LineStyle', 'none', 'Marker', 's', 'MarkerSize', 7, ...
                'MarkerFaceColor', [1, 1, 1], 'MarkerEdgeColor', [0, 0, 0], ...
                'Tag', ['Task3CropHandle_', mode], 'PickableParts', 'all', ...
                'ButtonDownFcn', @(~, event) beginCropDrag(mode, event));
        end
        hold(task3OriginalAxes, 'off');
        showMissingOriginal(task3Content, task3OriginalAxes, 'Task3InputMessage');

        task3ProcessedAxes = uiaxes(task3Content, 'Tag', 'Task3ProcessedAxes');
        task3ProcessedAxes.Layout.Row = 1;
        task3ProcessedAxes.Layout.Column = 2;
        task3ProcessedDisplay = image(task3ProcessedAxes, grayImage, ...
            'CDataMapping', 'scaled', 'Tag', 'Task3ProcessedImage');
        configureImageAxes(task3ProcessedAxes, 'Processed Image');
        disableDefaultInteractivity(task3ProcessedAxes);
        if isempty(grayImage)
            task3ProcessedAxes.Visible = 'off';
        end

        coordinateGrid = uigridlayout(task3Content, [1, 9], 'Tag', 'Task3Controls');
        coordinateGrid.Layout.Row = 2;
        coordinateGrid.Layout.Column = [1, 2];
        % About 40 pixels of numeric input plus the native arrow-button area.
        coordinateGrid.ColumnWidth = {24, 60, 24, 60, 24, 60, 24, 60, '1x'};
        coordinateGrid.Padding = [0, 0, 0, 0];
        coordinateGrid.ColumnSpacing = 10;
        names = {'x1', 'y1', 'x2', 'y2'};
        maximumCoordinates = [imageWidth, imageHeight, imageWidth, imageHeight];
        for coordinateIndex = 1:4
            label = uilabel(coordinateGrid, 'Text', names{coordinateIndex}, 'FontSize', 14);
            label.Layout.Row = 1;
            label.Layout.Column = 2 * coordinateIndex - 1;
            cropSpinners(coordinateIndex) = uispinner(coordinateGrid, ...
                'Limits', [1, maximumCoordinates(coordinateIndex)], 'Step', 1, ...
                'Value', cropBounds(coordinateIndex), 'FontSize', 14, ...
                'RoundFractionalValues', 'on', 'ValueDisplayFormat', '%.0f', ...
                'Tag', ['Task3Spinner_', names{coordinateIndex}], ...
                'ValueChangingFcn', @(~, event) changeCropCoordinate(coordinateIndex, event.Value, true), ...
                'ValueChangedFcn', @(~, event) changeCropCoordinate(coordinateIndex, event.Value, false));
            cropSpinners(coordinateIndex).Layout.Row = 1;
            cropSpinners(coordinateIndex).Layout.Column = 2 * coordinateIndex;
        end
    end

    function buildTask4Interface(rootGrid)
        task4Content = uigridlayout(rootGrid, [2, 2], ...
            'Visible', 'off', 'Tag', 'Task4Content');
        task4Content.Layout.Row = 2;
        task4Content.Layout.Column = 1;
        task4Content.RowHeight = {'1x', 30};
        task4Content.ColumnWidth = {'1x', '1x'};
        task4Content.Padding = [0, 0, 0, 0];
        task4Content.RowSpacing = 12;
        task4Content.ColumnSpacing = 16;

        task4OriginalAxes = uiaxes(task4Content, 'Tag', 'Task4OriginalAxes');
        task4OriginalAxes.Layout.Row = 1;
        task4OriginalAxes.Layout.Column = 1;
        task4OriginalDisplay = image(task4OriginalAxes, zeros(2, 2, 'uint8'), ...
            'CDataMapping', 'scaled', 'Tag', 'Task4OriginalImage');
        configureImageAxes(task4OriginalAxes, 'Original Sub-image');
        disableDefaultInteractivity(task4OriginalAxes);

        task4BinaryAxes = uiaxes(task4Content, 'Tag', 'Task4BinaryAxes');
        task4BinaryAxes.Layout.Row = 1;
        task4BinaryAxes.Layout.Column = 2;
        task4BinaryDisplay = image(task4BinaryAxes, false(2, 2), ...
            'CDataMapping', 'scaled', 'Tag', 'Task4BinaryImage');
        configureImageAxes(task4BinaryAxes, 'Binary Image');
        task4BinaryAxes.CLim = [0, 1];
        disableDefaultInteractivity(task4BinaryAxes);

        % Only visible when no valid exported Task 3 input can be loaded.
        task4InputMessage = uilabel(task4Content, 'Text', '', ...
            'Visible', 'off', 'HorizontalAlignment', 'center', ...
            'WordWrap', 'on', 'FontSize', 16, 'Tag', 'Task4InputMessage');
        task4InputMessage.Layout.Row = 1;
        task4InputMessage.Layout.Column = [1, 2];

        thresholdGrid = uigridlayout(task4Content, [1, 3], 'Tag', 'Task4Controls');
        thresholdGrid.Layout.Row = 2;
        thresholdGrid.Layout.Column = [1, 2];
        thresholdGrid.ColumnWidth = {80, 40, '1x'};
        thresholdGrid.Padding = [0, 2, 6, 2];
        thresholdGrid.ColumnSpacing = 12;
        label = uilabel(thresholdGrid, 'Text', 'Threshold', 'FontSize', 14);
        label.Layout.Row = 1;
        label.Layout.Column = 1;
        thresholdField = uieditfield(thresholdGrid, 'numeric', ...
            'Limits', [0, 255], 'Value', binaryThreshold, ...
            'RoundFractionalValues', 'on', 'ValueDisplayFormat', '%.0f', ...
            'Tag', 'Task4ThresholdField', ...
            'ValueChangedFcn', @(~, event) changeBinaryThreshold(event.Value, false));
        thresholdField.Layout.Row = 1;
        thresholdField.Layout.Column = 2;
        thresholdSlider = uislider(thresholdGrid, 'Limits', [0, 255], ...
            'Value', binaryThreshold, 'MajorTicks', [], 'MinorTicks', [], ...
            'Tag', 'Task4ThresholdSlider', ...
            'ValueChangingFcn', @(~, event) changeBinaryThreshold(event.Value, true), ...
            'ValueChangedFcn', @(~, event) changeBinaryThreshold(event.Value, false));
        thresholdSlider.Layout.Row = 1;
        thresholdSlider.Layout.Column = 3;
    end

    function buildTask5Interface(rootGrid)
        % Source, edge map and optional local linking are updated in place.
        task5Content = uigridlayout(rootGrid, [5, 1], ...
            'Visible', 'off', 'Tag', 'Task5Content');
        task5Content.Layout.Row = 2;
        task5Content.Layout.Column = 1;
        task5Content.RowHeight = {32, 0, 0, '1x', 30};
        task5Content.Padding = [0, 0, 0, 0];
        task5Content.RowSpacing = 8;

        selectionGrid = uigridlayout(task5Content, [1, 4]);
        selectionGrid.Layout.Row = 1;
        selectionGrid.Layout.Column = 1;
        selectionGrid.ColumnWidth = {150, 160, 160, '1x'};
        selectionGrid.Padding = [0, 0, 0, 0];
        selectionGrid.ColumnSpacing = 12;
        task5MethodSelector = uidropdown(selectionGrid, 'Items', edgeMethodNames, ...
            'ItemsData', 1:3, 'Value', task5State.MethodIndex, 'FontSize', 14, ...
            'Tag', 'Task5MethodSelector', ...
            'ValueChangedFcn', @(~, event) changeTask5Method(event.Value));
        task5MethodSelector.Layout.Column = 1;
        task5BinaryToggle = uicheckbox(selectionGrid, 'Text', 'Use Binary Image', ...
            'Value', task5State.UseBinaryImage, 'Visible', 'off', 'FontSize', 14, ...
            'Tag', 'Task5BinaryToggle', ...
            'ValueChangedFcn', @(~, event) changeTask5Toggle('UseBinaryImage', event.Value));
        task5BinaryToggle.Layout.Column = 2;
        task5SmoothingToggle = uicheckbox(selectionGrid, 'Text', 'Pre-smoothing', ...
            'Value', task5State.SmoothingEnabled, 'Visible', 'off', 'FontSize', 14, ...
            'Tag', 'Task5SmoothingToggle', ...
            'ValueChangedFcn', @(~, event) changeTask5Toggle('SmoothingEnabled', event.Value));
        task5SmoothingToggle.Layout.Column = 3;

        task5SmoothingControls = uigridlayout(task5Content, [1, 4], ...
            'Visible', 'off', 'Tag', 'Task5SmoothingControls');
        task5SmoothingControls.Layout.Row = 2;
        task5SmoothingControls.Layout.Column = 1;
        task5SmoothingControls.ColumnWidth = {150, 150, 40, '1x'};
        task5SmoothingControls.Padding = [0, 3, 6, 3];
        task5SmoothingControls.ColumnSpacing = 12;
        task5FilterSelector = uidropdown(task5SmoothingControls, 'Items', filterNames, ...
            'ItemsData', 1:3, 'Value', task5State.SmoothingFilterIndex, 'FontSize', 14, ...
            'Tag', 'Task5FilterSelector', ...
            'ValueChangedFcn', @(~, event) changeTask5Filter(event.Value));
        task5FilterSelector.Layout.Column = 1;
        label = uilabel(task5SmoothingControls, 'Text', 'Neighborhood Width', 'FontSize', 14);
        label.Layout.Column = 2;
        task5WidthField = uieditfield(task5SmoothingControls, 'numeric', ...
            'Limits', neighborhoodLimits, 'Value', task5State.SmoothingWidth, ...
            'RoundFractionalValues', 'on', 'ValueDisplayFormat', '%.0f', ...
            'Tag', 'Task5NeighborhoodField', ...
            'ValueChangedFcn', @(~, event) changeTask5Width(event.Value, false, false));
        task5WidthField.Layout.Column = 3;
        task5WidthSlider = uislider(task5SmoothingControls, 'Limits', [0, 15], ...
            'Value', (task5State.SmoothingWidth - 1) / 2, 'MajorTicks', [], 'MinorTicks', [], ...
            'Tag', 'Task5NeighborhoodSlider', ...
            'ValueChangingFcn', @(~, event) changeTask5Width(event.Value, true, true), ...
            'ValueChangedFcn', @(~, event) changeTask5Width(event.Value, true, false));
        task5WidthSlider.Layout.Column = 4;

        task5EdgeControls = uigridlayout(task5Content, [1, 3], ...
            'Visible', 'off', 'Tag', 'Task5EdgeControls');
        task5EdgeControls.Layout.Row = 3;
        task5EdgeControls.Layout.Column = 1;
        task5EdgeControls.ColumnWidth = {110, 40, '1x'};
        task5EdgeControls.Padding = [0, 3, 6, 3];
        task5EdgeControls.ColumnSpacing = 12;
        label = uilabel(task5EdgeControls, 'Text', 'Edge Threshold', 'FontSize', 14);
        label.Layout.Column = 1;
        % Each detector uses its own fixed normalization and saved threshold.
        task5EdgeField = uieditfield(task5EdgeControls, 'numeric', ...
            'Limits', [0, 1], 'Value', task5State.EdgeThreshold, 'ValueDisplayFormat', '%.2g', ...
            'Tag', 'Task5EdgeThresholdField', ...
            'ValueChangedFcn', @(~, event) changeTask5Parameter(1, event.Value, false, false));
        task5EdgeField.Layout.Column = 2;
        task5EdgeSlider = uislider(task5EdgeControls, 'Limits', [0, 1], ...
            'Value', task5State.EdgeThreshold, 'MajorTicks', [], 'MinorTicks', [], ...
            'Tag', 'Task5EdgeThresholdSlider', ...
            'ValueChangingFcn', @(~, event) changeTask5Parameter(1, event.Value, true, true), ...
            'ValueChangedFcn', @(~, event) changeTask5Parameter(1, event.Value, true, false));
        task5EdgeSlider.Layout.Column = 3;

        displayGrid = uigridlayout(task5Content, [1, 2]);
        displayGrid.Layout.Row = 4;
        displayGrid.Layout.Column = 1;
        displayGrid.ColumnWidth = {'1x', '1x'};
        displayGrid.Padding = [0, 0, 0, 0];
        displayGrid.ColumnSpacing = 16;
        task5OriginalAxes = uiaxes(displayGrid, 'Tag', 'Task5OriginalAxes');
        task5OriginalAxes.Layout.Column = 1;
        task5OriginalDisplay = image(task5OriginalAxes, zeros(0, 0, 'uint8'), ...
            'CDataMapping', 'scaled', 'Tag', 'Task5OriginalImage');
        configureImageAxes(task5OriginalAxes, 'Original Binary Image');
        disableDefaultInteractivity(task5OriginalAxes);
        task5OriginalNote = text(task5OriginalAxes, 0.5, 0.5, '', ...
            'Units', 'normalized', 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'Interpreter', 'none', ...
            'Tag', 'Task5OriginalNote');
        task5EdgeAxes = uiaxes(displayGrid, 'Tag', 'Task5EdgeAxes');
        task5EdgeAxes.Layout.Column = 2;
        task5EdgeDisplay = image(task5EdgeAxes, false(0, 0), ...
            'CDataMapping', 'scaled', 'Tag', 'Task5EdgeImage');
        configureImageAxes(task5EdgeAxes, 'Edge Image');
        task5EdgeAxes.CLim = [0, 1];
        disableDefaultInteractivity(task5EdgeAxes);

        task5LinkArea = uigridlayout(task5Content, [1, 2], 'Tag', 'Task5LinkArea');
        task5LinkArea.Layout.Row = 5;
        task5LinkArea.Layout.Column = 1;
        task5LinkArea.ColumnWidth = {'1x', '1x'};
        task5LinkArea.Padding = [0, 0, 0, 0];
        task5LinkArea.ColumnSpacing = 16;
        task5LinkLeft = uigridlayout(task5LinkArea, [2, 1]);
        task5LinkLeft.Layout.Column = 1;
        task5LinkLeft.RowHeight = {26, 0};
        task5LinkLeft.Padding = [0, 0, 0, 0];
        task5LinkLeft.RowSpacing = 0;
        task5LinkToggle = uicheckbox(task5LinkLeft, 'Text', 'Edge Linking', ...
            'Value', task5State.LinkingEnabled, 'FontSize', 14, 'Tag', 'Task5LinkToggle', ...
            'ValueChangedFcn', @(~, event) changeTask5Toggle('LinkingEnabled', event.Value));
        task5LinkToggle.Layout.Row = 1;
        task5LinkControls = uigridlayout(task5LinkLeft, [3, 3], ...
            'Visible', 'off', 'Tag', 'Task5LinkControls');
        task5LinkControls.Layout.Row = 2;
        task5LinkControls.RowHeight = {26, 26, 26};
        task5LinkControls.ColumnWidth = {160, 40, '1x'};
        task5LinkControls.Padding = [0, 0, 6, 0];
        task5LinkControls.RowSpacing = 8;
        task5LinkControls.ColumnSpacing = 12;
        label = uilabel(task5LinkControls, 'Text', 'Neighborhood Width');
        label.Layout.Row = 1;
        label.Layout.Column = 1;
        task5LinkWidthGroup = createHorizontalRadioGroup(task5LinkControls, ...
            {'3 x 3', '5 x 5'}, [3, 5], task5State.LinkNeighborhoodWidth, ...
            'Task5LinkNeighborhoodGroup', ...
            @(~, event) changeTask5LinkWidth(event.NewValue.UserData));
        task5LinkWidthGroup.Layout.Row = 1;
        task5LinkWidthGroup.Layout.Column = [2, 3];
        names = {'Neighborhood Width', 'Magnitude Difference', 'Direction Difference (deg)'};
        tags = {'Neighborhood', 'Magnitude', 'Direction'};
        limits = [3, 5; 0, 1; 0, 180];
        values = [task5State.LinkNeighborhoodWidth, task5State.MagnitudeDifference, ...
            task5State.DirectionDifference];
        for parameterIndex = 2:3
            controlIndex = parameterIndex - 1;
            label = uilabel(task5LinkControls, 'Text', names{parameterIndex});
            label.Layout.Row = parameterIndex;
            label.Layout.Column = 1;
            task5LinkFields(controlIndex) = uieditfield(task5LinkControls, 'numeric', ...
                'Limits', limits(parameterIndex, :), 'Value', values(parameterIndex), ...
                'ValueDisplayFormat', '%.2g', 'Tag', ['Task5LinkField_', tags{parameterIndex}], ...
                'ValueChangedFcn', @(~, event) changeTask5Parameter(parameterIndex + 1, event.Value, false, false));
            task5LinkFields(controlIndex).Layout.Row = parameterIndex;
            task5LinkFields(controlIndex).Layout.Column = 2;
            sliderLimits = limits(parameterIndex, :);
            sliderValue = values(parameterIndex);
            if parameterIndex ~= 2
                task5LinkFields(controlIndex).RoundFractionalValues = 'on';
                task5LinkFields(controlIndex).ValueDisplayFormat = '%.0f';
            end
            task5LinkSliders(controlIndex) = uislider(task5LinkControls, ...
                'Limits', sliderLimits, 'Value', sliderValue, 'MajorTicks', [], 'MinorTicks', [], ...
                'Tag', ['Task5LinkSlider_', tags{parameterIndex}], ...
                'ValueChangingFcn', @(~, event) changeTask5Parameter(parameterIndex + 1, event.Value, true, true), ...
                'ValueChangedFcn', @(~, event) changeTask5Parameter(parameterIndex + 1, event.Value, true, false));
            task5LinkSliders(controlIndex).Layout.Row = parameterIndex;
            task5LinkSliders(controlIndex).Layout.Column = 3;
        end
        task5LinkResult = uigridlayout(task5LinkArea, [1, 1], ...
            'Visible', 'off', 'Tag', 'Task5LinkResult');
        task5LinkResult.Layout.Column = 2;
        task5LinkResult.Padding = [0, 0, 0, 0];
        task5LinkedAxes = uiaxes(task5LinkResult, 'Tag', 'Task5LinkedAxes');
        task5LinkedDisplay = image(task5LinkedAxes, false(0, 0), ...
            'CDataMapping', 'scaled', 'Tag', 'Task5LinkedImage');
        configureImageAxes(task5LinkedAxes, 'Processed Image');
        task5LinkedAxes.CLim = [0, 1];
        disableDefaultInteractivity(task5LinkedAxes);
    end

    function buildTask6Interface(rootGrid)
        task6Content = uigridlayout(rootGrid, [5, 1], ...
            'Visible', 'off', 'Tag', 'Task6Content');
        task6Content.Layout.Row = 2;
        task6Content.Layout.Column = 1;
        task6Content.RowHeight = {'1x', 30, '1x', 30, '1x'};
        task6Content.Padding = [0, 0, 0, 0];
        task6Content.RowSpacing = 8;
        [originalArea, task6OriginalAxes, task6OriginalDisplay] = ...
            buildTask6ImageArea(task6Content, 1, 'Original Image', 'Task6Original');
        task6OriginalAxes.CLim = [0, 1];
        task6OriginalNote = uilabel(originalArea, 'Text', '', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'center', ...
            'WordWrap', 'on', 'FontSize', 14, 'Visible', 'off', ...
            'Tag', 'Task6OriginalNote');
        task6OriginalNote.Layout.Row = 1;
        task6OriginalNote.Layout.Column = 1;

        connectivityRow = uigridlayout(task6Content, [1, 2]);
        connectivityRow.Layout.Row = 2;
        connectivityRow.ColumnWidth = {240, '1x'};
        connectivityRow.Padding = [0, 0, 0, 0];
        task6ConnectivityGroup = createHorizontalRadioGroup(connectivityRow, ...
            {'4-connected', '8-connected'}, [4, 8], task6State.Connectivity, ...
            'Task6ConnectivityGroup', ...
            @(~, event) changeTask6Choice('Connectivity', event.NewValue.UserData));
        task6ConnectivityGroup.Layout.Column = 1;
        [~, task6InitialAxes, task6InitialDisplay] = ...
            buildTask6ImageArea(task6Content, 3, 'Initial Labeled Image (0 regions)', 'Task6Initial');
        widthRow = uigridlayout(task6Content, [1, 6], 'Tag', 'Task6WidthControls');
        widthRow.Layout.Row = 4;
        widthRow.ColumnWidth = {125, 40, '1x', 75, 40, '1x'};
        widthRow.Padding = [0, 0, 8, 0];
        widthRow.ColumnSpacing = 12;
        widthNames = {'ExpectedWidth', 'Tolerance'};
        widthLabels = {'Expected Width', 'Tolerance'};
        for index = 1:2
            name = widthNames{index};
            lowerLimit = double(index == 1);
            column = 3 * (index - 1);
            label = uilabel(widthRow, 'Text', widthLabels{index});
            label.Layout.Column = column + 1;
            task6WidthFields(index) = uieditfield(widthRow, 'numeric', ...
                'Limits', [lowerLimit, max(120, imageWidth)], 'Value', task6State.(name), ...
                'RoundFractionalValues', 'on', 'ValueDisplayFormat', '%.0f', ...
                'Tag', ['Task6', name, 'Field'], ...
                'ValueChangedFcn', @(~, event) changeTask6Width(name, event.Value));
            task6WidthFields(index).Layout.Column = column + 2;
            task6WidthSliders(index) = uislider(widthRow, ...
                'Limits', [lowerLimit, max(120, imageWidth)], 'Value', task6State.(name), ...
                'MajorTicks', [], 'MinorTicks', [], 'Tag', ['Task6', name, 'Slider'], ...
                'ValueChangingFcn', @(~, event) changeTask6Width(name, event.Value), ...
                'ValueChangedFcn', @(~, event) changeTask6Width(name, event.Value));
            task6WidthSliders(index).Layout.Column = column + 3;
        end
        [~, task6LabeledAxes, task6LabeledDisplay] = ...
            buildTask6ImageArea(task6Content, 5, 'Processed Labeled Image (0 regions)', 'Task6Labeled');
    end

    function [area, imageAxes, imageDisplay] = buildTask6ImageArea(parent, row, imageTitle, tagPrefix)
        area = uigridlayout(parent, [1, 1], 'Tag', [tagPrefix, 'Area']);
        area.Layout.Row = row;
        area.Padding = [0, 0, 0, 0];
        imageAxes = uiaxes(area, 'Tag', [tagPrefix, 'Axes']);
        imageDisplay = image(imageAxes, zeros(0, 0, 'uint8'), 'CDataMapping', 'scaled', ...
            'Tag', [tagPrefix, 'Image']);
        configureImageAxes(imageAxes, imageTitle);
        disableDefaultInteractivity(imageAxes);
    end

    function changeTask6Choice(name, value)
        if currentTask ~= 6
            return;
        end
        task6State.(name) = value;
        syncTask6Layout();
    end

    function changeTask6Width(name, value)
        if currentTask ~= 6
            return;
        end
        if isfinite(value)
            if strcmp(name, 'ExpectedWidth')
                task6State.ExpectedWidth = min(max(round(value), 1), task6WidthFields(1).Limits(2));
            else
                task6State.Tolerance = min(max(round(value), 0), task6State.ExpectedWidth - 1);
            end
        end
        syncTask6WidthControls();
        refreshTask6Output();
    end

    function syncTask6Layout()
        selectHorizontalRadioValue(task6ConnectivityGroup, task6State.Connectivity);
        syncTask6WidthControls();
        window.UserData.Task6Settings = getTask6Settings();
        window.UserData.DefaultWindowSize = getTaskDefaultWindowSize(currentTask, task5State);
        applyTaskWindowSize();
        refreshTask6Output();
    end

    function syncTask6WidthControls()
        limit = max([120, imageWidth, size(task6InputImage, 2)]);
        task6State.ExpectedWidth = min(max(task6State.ExpectedWidth, 1), limit);
        task6State.Tolerance = min(max(task6State.Tolerance, 0), task6State.ExpectedWidth - 1);
        values = [task6State.ExpectedWidth, task6State.Tolerance];
        lowerLimits = [1, 0];
        upperLimits = [limit, max(1, task6State.ExpectedWidth - 1)];
        for index = 1:2
            % Set a valid value before reducing a NumericEditField's limits.
            task6WidthFields(index).Limits = [lowerLimits(index), ...
                max(upperLimits(index), task6WidthFields(index).Limits(2))];
            task6WidthFields(index).Value = values(index);
            task6WidthFields(index).Limits = [lowerLimits(index), upperLimits(index)];
            task6WidthSliders(index).Limits = [lowerLimits(index), ...
                max(upperLimits(index), task6WidthSliders(index).Limits(2))];
            task6WidthSliders(index).Value = values(index);
            task6WidthSliders(index).Limits = [lowerLimits(index), upperLimits(index)];
        end
    end

    function settings = getTask6Settings()
        settings = task6State;
        settings.Operation = 'VerticalProjection';
        settings.InputConfigured = true;
        settings.InputPath = task6InputPath;
        settings.InputLoaded = ~isempty(task6InputImage);
        settings.ProcessingImplemented = true;
        settings.LabelingImplemented = true;
        settings.ExportImplemented = true;
        settings.MaximumRegions = Inf;
        settings.InitialLabelMatrix = task6InitialLabels;
        settings.InitialBoundingBoxes = task6InitialBoxes;
        settings.InitialCentroids = task6InitialCentroids;
        settings.InitialAreas = task6InitialAreas;
        settings.InitialRegionCount = task6TotalRegionCount;
        settings.InitialOrdering = 'Decreasing foreground area, then centroid X/Y';
        settings.FinalOrdering = 'Centroid X/Y from left to right';
        settings.WidthConvention = 'Inclusive tight bounding-box column count';
        settings.AcceptedWidthRange = [task6State.ExpectedWidth - task6State.Tolerance, ...
            task6State.ExpectedWidth + task6State.Tolerance];
        settings.SplitConvention = ['Per original component: max(2, round(width / expected width)) parts; ' ...
            'minimum column projection within tolerance of evenly spaced cuts; ' ...
            'center-nearest then leftmost ties; ordered disjoint search windows; cut after selected column'];
        settings.RecursiveSplitting = false;
        settings.FinalWidthFiltering = 'Discard narrow parts once; keep other parts without recursive splitting';
        settings.RegionCount = task6RegionCount;
        settings.TotalRegionCount = task6TotalRegionCount;
        settings.LabelMatrix = task6LabelMatrix;
        settings.BoundingBoxes = task6BoundingBoxes;
        settings.CoordinateColumns = {'TopRow', 'LeftColumn', 'BottomRow', 'RightColumn'};
        settings.CoordinateConvention = '1-based inclusive [row1, column1, row2, column2]';
        settings.Centroids = task6Centroids;
        settings.CentroidColumns = {'X', 'Y'};
        settings.Areas = task6Areas;
        settings.Colors = getTask6RegionColors();
        settings.OutputFolderName = getTask6OutputFolderName(task6State);
        settings.ProcessingSeconds = task6ProcessingSeconds;
    end

    function loadTask6Input()
        task6InputImage = false(0, 0);
        task6InputMessage = '';
        task6InitialKey = [];
        task6LabelKey = [];
        try
            if ~isfile(task6InputPath)
                error('ME5411:MissingTask6Input', '%s', ...
                    getMissingImageMessage(projectFolder, task6InputPath));
            end
            [pixels, map] = imread(task6InputPath);
            if isempty(pixels) || ~ismatrix(pixels) || ~isempty(map)
                error('ME5411:InvalidTask6Input', ...
                    'Task4_Binary.png must be a binary image. Export it again in Task 4.');
            end
            if isa(pixels, 'uint8') && all(pixels(:) == 0 | pixels(:) == 255)
                pixels = pixels ~= 0;
            end
            if ~islogical(pixels)
                error('ME5411:InvalidTask6Input', ...
                    'Task4_Binary.png must be a binary image. Export it again in Task 4.');
            end
            task6InputImage = pixels;
        catch exception
            if startsWith(exception.identifier, 'ME5411:')
                task6InputMessage = exception.message;
            else
                task6InputMessage = 'Task4_Binary.png cannot be read. Export it again in Task 4.';
            end
        end
    end

    function refreshTask6Output()
        processingTimer = tic;
        loaded = ~isempty(task6InputImage);
        task6OriginalNote.Visible = visibility(~loaded);
        task6OriginalNote.Text = task6InputMessage;
        set([task6WidthFields, task6WidthSliders, task6ConnectivityGroup], 'Enable', visibility(loaded));
        set([task6WidthFields(2), task6WidthSliders(2)], ...
            'Enable', visibility(loaded && task6State.ExpectedWidth > 1));
        set([task6OriginalAxes, task6InitialAxes, task6LabeledAxes, ...
            task6OriginalDisplay, task6InitialDisplay, task6LabeledDisplay], ...
            'Visible', visibility(loaded));
        exportButton.Enable = visibility(loaded);
        if ~loaded
            task6InitialLabels = zeros(0, 0, 'uint32');
            task6InitialBoxes = zeros(0, 4);
            task6InitialCentroids = zeros(0, 2);
            task6InitialAreas = zeros(0, 1);
            task6InitialImage = zeros(0, 0, 3, 'uint8');
            task6LabelMatrix = zeros(0, 0, 'uint32');
            task6BoundingBoxes = zeros(0, 4);
            task6Centroids = zeros(0, 2);
            task6Areas = zeros(0, 1);
            task6RegionCount = 0;
            task6TotalRegionCount = 0;
            task6LabeledImage = zeros(0, 0, 3, 'uint8');
        else
            if ~isequal(task6InitialKey, task6State.Connectivity)
                [task6InitialLabels, task6InitialBoxes, task6InitialCentroids, ...
                    task6InitialAreas, task6TotalRegionCount] = ...
                    labelTask6Components(task6InputImage, task6State.Connectivity);
                task6InitialImage = renderTask6Labels(task6InitialLabels, task6InitialBoxes);
                task6InitialKey = task6State.Connectivity;
                task6LabelKey = [];
            end
            labelKey = [task6State.Connectivity, task6State.ExpectedWidth, task6State.Tolerance];
            if ~isequal(task6LabelKey, labelKey)
                [task6LabelMatrix, task6BoundingBoxes, task6Centroids, task6Areas] = ...
                    splitTask6Regions(task6InitialLabels, task6InitialBoxes, ...
                        task6State.ExpectedWidth, task6State.Tolerance);
                task6RegionCount = size(task6BoundingBoxes, 1);
                task6LabeledImage = renderTask6Labels(task6LabelMatrix, task6BoundingBoxes);
                task6LabelKey = labelKey;
            end
            [height, width] = size(task6InputImage);
            displays = [task6OriginalDisplay, task6InitialDisplay, task6LabeledDisplay];
            imageAxes = [task6OriginalAxes, task6InitialAxes, task6LabeledAxes];
            for index = 1:3
                displays(index).XData = [1, width];
                displays(index).YData = [1, height];
                imageAxes(index).XLim = [0.5, width + 0.5];
                imageAxes(index).YLim = [0.5, height + 0.5];
            end
        end
        task6OriginalDisplay.CData = task6InputImage;
        task6InitialDisplay.CData = task6InitialImage;
        task6LabeledDisplay.CData = task6LabeledImage;
        task6InitialAxes.Title.String = sprintf('Initial Labeled Image (%d regions)', task6TotalRegionCount);
        task6LabeledAxes.Title.String = sprintf('Processed Labeled Image (%d regions)', task6RegionCount);
        task6ProcessingSeconds = toc(processingTimer);
        window.UserData.Task6Settings = getTask6Settings();
        drawnow limitrate nocallbacks;
    end

    function changeTask5LinkWidth(value)
        if currentTask ~= 5 || ~ismember(value, [3, 5])
            return;
        end
        task5State.LinkNeighborhoodWidth = value;
        selectHorizontalRadioValue(task5LinkWidthGroup, value);
        refreshTask5Output();
    end

    function changeTask5Method(methodIndex)
        if currentTask ~= 5
            return;
        end
        task5State.MethodIndex = methodIndex;
        loadTask5Source();
        syncTask5Layout();
    end

    function changeTask5Toggle(name, value)
        if currentTask ~= 5
            return;
        end
        task5State.(name) = logical(value);
        if strcmp(name, 'UseBinaryImage')
            loadTask5Source();
        end
        syncTask5Layout();
    end

    function changeTask5Filter(filterIndex)
        if currentTask ~= 5
            return;
        end
        task5State.SmoothingFilterIndex = filterIndex;
        syncTask5Width(false);
        refreshTask5Output();
    end

    function changeTask5Width(value, isSlider, isDragging)
        if currentTask ~= 5
            return;
        end
        if isfinite(value)
            if isSlider
                width = 1 + 2 * round(value);
            else
                width = 1 + 2 * round((value - 1) / 2);
            end
            task5State.SmoothingWidth = min(max(width, 1), 31);
        end
        syncTask5Width(isDragging);
        refreshTask5Output();
    end

    function syncTask5Width(isDragging)
        minimumWidth = 1;
        if task5State.SmoothingFilterIndex == 2
            minimumWidth = 5;
        end
        task5State.SmoothingWidth = max(minimumWidth, task5State.SmoothingWidth);
        task5FilterSelector.Value = task5State.SmoothingFilterIndex;
        task5WidthField.Limits = neighborhoodLimits;
        task5WidthField.Value = task5State.SmoothingWidth;
        task5WidthField.Limits = [minimumWidth, 31];
        if task5WidthSlider.Value < (minimumWidth - 1) / 2
            task5WidthSlider.Value = (minimumWidth - 1) / 2;
        end
        task5WidthSlider.Limits = [(minimumWidth - 1) / 2, 15];
        if ~isDragging
            task5WidthSlider.Value = (task5State.SmoothingWidth - 1) / 2;
        end
        window.UserData.Task5Settings = getTask5Settings();
    end

    function changeTask5Parameter(parameterIndex, value, ~, isDragging)
        if currentTask ~= 5
            return;
        end
        names = {'EdgeThreshold', 'LinkNeighborhoodWidth', 'MagnitudeDifference', 'DirectionDifference'};
        if task5State.MethodIndex == 3
            names{1} = 'LaplacianThreshold';
        end
        task5ParameterFields = [task5EdgeField, task5LinkFields];
        task5ParameterSliders = [task5EdgeSlider, task5LinkSliders];
        controlIndex = parameterIndex - (parameterIndex > 1);
        name = names{parameterIndex};
        if isfinite(value)
            if parameterIndex == 4
                value = round(value);
            end
            limits = task5ParameterFields(controlIndex).Limits;
            task5State.(name) = min(max(value, limits(1)), limits(2));
        end
        task5ParameterFields(controlIndex).Value = task5State.(name);
        if ~isDragging
            sliderValue = task5State.(name);
            task5ParameterSliders(controlIndex).Value = sliderValue;
        end
        refreshTask5Output();
    end

    function loadTask5Source()
        % Read only the appropriate saved input; do not use unsaved upstream edits.
        task5Cache.Key = [];
        binaryInput = task5State.MethodIndex == 1 || task5State.UseBinaryImage;
        if binaryInput
            task5SourcePath = fullfile(projectFolder, 'Task1-6_Output', 'Task4_Binary.png');
            prerequisite = 'Task 4';
        else
            task5SourcePath = task4InputPath;
            prerequisite = 'Task 3';
        end
        task5SourceImage = zeros(0, 0, 'uint8');
        task5SourceMessage = '';
        try
            if ~isfile(task5SourcePath)
                error('ME5411:MissingTask5Source', '%s', ...
                    getMissingImageMessage(projectFolder, task5SourcePath));
            end
            [inputImage, map] = imread(task5SourcePath);
            if isempty(inputImage) || ~ismatrix(inputImage) || ~isempty(map)
                error('ME5411:InvalidTask5Source', 'Export a valid source image in %s.', prerequisite);
            end
            if binaryInput
                if isa(inputImage, 'uint8') && all(inputImage(:) == 0 | inputImage(:) == 255)
                    inputImage = inputImage ~= 0;
                end
                if ~islogical(inputImage)
                    error('ME5411:InvalidTask5Source', 'Export a binary image in Task 4.');
                end
            elseif ~isa(inputImage, 'uint8')
                error('ME5411:InvalidTask5Source', 'Export an 8-bit grayscale image in Task 3.');
            end
            task5SourceImage = inputImage;
        catch exception
            task5SourceMessage = exception.message;
        end
    end

    function syncTask5Layout()
        derivativeMethod = task5State.MethodIndex ~= 1;
        grayscaleInput = derivativeMethod && ~task5State.UseBinaryImage;
        smoothing = grayscaleInput && task5State.SmoothingEnabled;
        task5MethodSelector.Value = task5State.MethodIndex;
        task5BinaryToggle.Value = task5State.UseBinaryImage;
        task5BinaryToggle.Visible = visibility(derivativeMethod);
        task5SmoothingToggle.Value = task5State.SmoothingEnabled;
        task5SmoothingToggle.Visible = visibility(grayscaleInput);
        task5SmoothingControls.Visible = visibility(smoothing);
        task5EdgeControls.Visible = visibility(derivativeMethod);
        task5EdgeField.Value = getTask5Threshold();
        task5EdgeSlider.Value = getTask5Threshold();
        task5LinkToggle.Value = task5State.LinkingEnabled;
        selectHorizontalRadioValue(task5LinkWidthGroup, task5State.LinkNeighborhoodWidth);
        task5LinkControls.Visible = visibility(task5State.LinkingEnabled);
        task5LinkResult.Visible = visibility(task5State.LinkingEnabled);
        rows = {32, 0, 0, '1x', 30};
        if smoothing
            rows{2} = 32;
        end
        if derivativeMethod
            rows{3} = 32;
        end
        if task5State.LinkingEnabled
            rows{5} = 156;
            task5LinkLeft.RowHeight = {26, 94};
            task5LinkLeft.RowSpacing = 8;
        else
            task5LinkLeft.RowHeight = {26, 0};
            task5LinkLeft.RowSpacing = 0;
        end
        task5Content.RowHeight = rows;
        syncTask5Width(false);
        if ~grayscaleInput
            task5OriginalAxes.Title.String = 'Original Binary Image';
            task5OriginalAxes.CLim = [0, 1];
        else
            task5OriginalAxes.Title.String = 'Original Sub-image';
            task5OriginalAxes.CLim = [0, 255];
        end
        if smoothing
            task5OriginalAxes.Title.String = 'Smoothed Image';
        end
        refreshTask5Output();
        window.UserData.DefaultWindowSize = getTaskDefaultWindowSize(currentTask, task5State);
        applyTaskWindowSize();
        drawnow limitrate nocallbacks;
    end

    function refreshTask5Output()
        processingTimer = tic;
        loaded = ~isempty(task5SourceImage);
        axesHandles = [task5OriginalAxes, task5EdgeAxes, task5LinkedAxes];
        set([axesHandles, task5OriginalDisplay, task5EdgeDisplay, task5LinkedDisplay], ...
            'Visible', visibility(loaded));
        set([axesHandles.Title], 'Visible', visibility(loaded));
        task5OriginalNote.Visible = 'off';
        if ~loaded
            task5EdgeImage = false(0, 0);
            task5FinalImage = false(0, 0);
            task5OriginalDisplay.CData = zeros(0, 0, 'uint8');
            task5EdgeDisplay.CData = task5EdgeImage;
            task5LinkedDisplay.CData = task5FinalImage;
            task5OriginalNote.String = task5SourceMessage;
            task5OriginalNote.Visible = 'on';
            exportButton.Enable = 'off';
            task5LinkCount = 0;
        else
            smoothing = task5State.MethodIndex ~= 1 && ~task5State.UseBinaryImage ...
                && task5State.SmoothingEnabled;
            cacheKey = [task5State.MethodIndex, 0, 0, task5State.UseBinaryImage];
            if smoothing
                cacheKey(2:3) = [task5State.SmoothingFilterIndex, task5State.SmoothingWidth];
            end
            if ~isequal(task5Cache.Key, cacheKey)
                task5Cache.WorkImage = task5SourceImage;
                if smoothing
                    task5Cache.WorkImage = applyImageSmoothing(task5SourceImage, ...
                        task5State.SmoothingFilterIndex, task5State.SmoothingWidth);
                end
                [task5Cache.Magnitude, task5Cache.Direction] = ...
                    computeSobelGradient(task5Cache.WorkImage);
                if task5State.MethodIndex == 1
                    task5Cache.ScanEdges = detectTwoPassEdges(task5Cache.WorkImage);
                elseif task5State.MethodIndex == 3
                    task5Cache.Laplacian = correlateImage3x3( ...
                        double(task5Cache.WorkImage), [0, -1, 0; -1, 4, -1; 0, -1, 0]);
                end
                task5Cache.Key = cacheKey;
            end
            switch task5State.MethodIndex
                case 1
                    task5EdgeImage = task5Cache.ScanEdges;
                case 2
                    task5EdgeImage = task5Cache.Magnitude > task5State.EdgeThreshold;
                case 3
                    pixelScale = 255;
                    if islogical(task5Cache.WorkImage)
                        pixelScale = 1;
                    end
                    task5EdgeImage = detectLaplacianZeroCrossings(task5Cache.Laplacian, ...
                        8 * pixelScale * task5State.LaplacianThreshold);
            end
            task5FinalImage = task5EdgeImage;
            task5LinkCount = 0;
            if task5State.LinkingEnabled
                [task5FinalImage, task5LinkCount] = linkLocalEdges(task5EdgeImage, ...
                    task5Cache.Magnitude, task5Cache.Direction, task5State.LinkNeighborhoodWidth, ...
                    task5State.MagnitudeDifference, task5State.DirectionDifference);
            end
            task5OriginalDisplay.CData = task5Cache.WorkImage;
            task5EdgeDisplay.CData = task5EdgeImage;
            task5LinkedDisplay.CData = task5FinalImage;
            [height, width] = size(task5SourceImage);
            for displayHandle = [task5OriginalDisplay, task5EdgeDisplay, task5LinkedDisplay]
                displayHandle.XData = [1, width];
                displayHandle.YData = [1, height];
            end
            for axesHandle = [task5OriginalAxes, task5EdgeAxes, task5LinkedAxes]
                axesHandle.XLim = [0.5, width + 0.5];
                axesHandle.YLim = [0.5, height + 0.5];
            end
            exportButton.Enable = 'on';
        end
        task5ProcessingSeconds = toc(processingTimer);
        window.UserData.Task5Settings = getTask5Settings();
        drawnow limitrate nocallbacks;
    end

    function threshold = getTask5Threshold()
        threshold = task5State.EdgeThreshold;
        if task5State.MethodIndex == 3
            threshold = task5State.LaplacianThreshold;
        end
    end

    function settings = getTask5Settings()
        settings = task5State;
        settings.SobelThreshold = task5State.EdgeThreshold;
        settings.EdgeThreshold = getTask5Threshold();
        settings.BinaryInput = task5State.MethodIndex == 1 || task5State.UseBinaryImage;
        settings.SmoothingApplied = ~settings.BinaryInput && task5State.SmoothingEnabled;
        settings.Method = edgeMethodNames{task5State.MethodIndex};
        settings.InputPath = task5SourcePath;
        settings.InputLoaded = ~isempty(task5SourceImage);
        settings.InputSize = size(task5SourceImage);
        settings.SmoothingFilter = filterNames{task5State.SmoothingFilterIndex};
        settings.ThresholdScale = 'Sobel magnitude / (4 * sqrt(2)) for unit-range input';
        if task5State.MethodIndex == 3
            settings.ThresholdScale = 'Laplacian zero-crossing response difference / 8 for unit-range input';
        elseif task5State.MethodIndex == 1
            settings.ThresholdScale = 'Not applicable to Two-pass';
        end
        settings.DirectionConvention = 'atan2d(column derivative, row derivative), circular 360 degrees';
        settings.EdgePixelCount = nnz(task5EdgeImage);
        settings.OutputPixelCount = nnz(task5FinalImage);
        settings.AcceptedLinkCount = task5LinkCount;
        settings.ProcessingSeconds = task5ProcessingSeconds;
        settings.ProcessingImplemented = true;
        settings.OutputFileName = getTask5OutputFileName(task5State, edgeMethodNames, filterNames);
    end

    function loadTask4Input()
        % Reload the exact saved crop each time the user enters Task 4.
        task4InputImage = zeros(0, 0, 'uint8');
        message = '';
        try
            if ~isfile(task4InputPath)
                error('ME5411:MissingSubImage', ...
                    '%s', getMissingImageMessage(projectFolder, task4InputPath));
            end
            [inputImage, map] = imread(task4InputPath);
            if ~isa(inputImage, 'uint8') || ~ismatrix(inputImage) ...
                    || isempty(inputImage) || ~isempty(map)
                error('ME5411:InvalidSubImage', ...
                    'Task3_Sub-image.png must be an 8-bit grayscale image. Export it again in Task 3.');
            end
            task4InputImage = inputImage;
        catch exception
            message = exception.message;
        end
        loaded = ~isempty(task4InputImage);
        if loaded
            task4InputMessage.Visible = 'off';
            task4OriginalAxes.Visible = 'on';
            task4BinaryAxes.Visible = 'on';
            task4OriginalDisplay.Visible = 'on';
            task4BinaryDisplay.Visible = 'on';
            thresholdField.Enable = 'on';
            thresholdSlider.Enable = 'on';
            exportButton.Enable = 'on';
            task4OriginalDisplay.CData = task4InputImage;
            [height, width] = size(task4InputImage);
            displays = [task4OriginalDisplay, task4BinaryDisplay];
            axesHandles = [task4OriginalAxes, task4BinaryAxes];
            for displayIndex = 1:2
                displays(displayIndex).XData = [1, width];
                displays(displayIndex).YData = [1, height];
                axesHandles(displayIndex).XLim = [0.5, width + 0.5];
                axesHandles(displayIndex).YLim = [0.5, height + 0.5];
            end
            refreshTask4Output();
        else
            task4OriginalDisplay.CData = zeros(0, 0, 'uint8');
            task4BinaryDisplay.CData = false(0, 0);
            task4OriginalDisplay.Visible = 'off';
            task4BinaryDisplay.Visible = 'off';
            task4OriginalAxes.Visible = 'off';
            task4BinaryAxes.Visible = 'off';
            thresholdField.Enable = 'off';
            thresholdSlider.Enable = 'off';
            exportButton.Enable = 'off';
            task4InputMessage.Text = message;
            task4InputMessage.Visible = 'on';
            window.UserData.Task4Settings = getTask4Settings();
        end
    end

    function changeBinaryThreshold(value, isDragging)
        if currentTask ~= 4 || isempty(task4InputImage)
            return;
        end
        if isfinite(value)
            binaryThreshold = min(max(round(value), 0), 255);
        end
        thresholdField.Value = binaryThreshold;
        % Do not modify the active slider's Value during native dragging.
        if ~isDragging
            thresholdSlider.Value = binaryThreshold;
        end
        refreshTask4Output();
    end

    function refreshTask4Output()
        % Strict comparison implements the course's global threshold formula.
        task4BinaryDisplay.CData = task4InputImage > binaryThreshold;
        window.UserData.Task4Settings = getTask4Settings();
        drawnow limitrate nocallbacks;
    end

    function settings = getTask4Settings()
        settings = struct('Threshold', binaryThreshold, 'InputPath', task4InputPath, ...
            'InputLoaded', ~isempty(task4InputImage), 'InputSize', size(task4InputImage), ...
            'Comparison', 'r > T', 'BinarizationImplemented', true);
    end

    function changeCropCoordinate(coordinateIndex, value, isChanging)
        if isempty(grayImage)
            return;
        end
        if currentTask ~= 3
            return;
        end
        cancelCropDrag();
        if isfinite(value)
            limits = cropSpinners(coordinateIndex).Limits;
            value = min(max(round(value), limits(1)), limits(2));
            switch coordinateIndex
                case 1
                    value = min(value, cropBounds(3));
                case 2
                    value = min(value, cropBounds(4));
                case 3
                    value = max(value, cropBounds(1));
                case 4
                    value = max(value, cropBounds(2));
            end
            cropBounds(coordinateIndex) = value;
        end
        if isChanging
            refreshTask3Output(cropSpinners(coordinateIndex));
        else
            refreshTask3Output([]);
        end
    end

    function refreshTask3Output(activeSpinner)
        if isempty(grayImage)
            task3ProcessedDisplay.CData = zeros(0, 0, 'uint8');
            window.UserData.Task3Settings = getTask3Settings();
            return;
        end
        x1 = cropBounds(1);
        y1 = cropBounds(2);
        x2 = cropBounds(3);
        y2 = cropBounds(4);
        croppedImage = grayImage(y1:y2, x1:x2);
        task3ProcessedDisplay.CData = croppedImage;
        task3ProcessedDisplay.XData = [1, size(croppedImage, 2)];
        task3ProcessedDisplay.YData = [1, size(croppedImage, 1)];
        task3ProcessedAxes.XLim = [0.5, size(croppedImage, 2) + 0.5];
        task3ProcessedAxes.YLim = [0.5, size(croppedImage, 1) + 0.5];
        % The rectangle follows pixel edges, not the centers of corner pixels.
        left = x1 - 0.5;
        top = y1 - 0.5;
        right = x2 + 0.5;
        bottom = y2 + 0.5;
        cropOverlay.XData = [left, right, right, left];
        cropOverlay.YData = [top, top, bottom, bottom];
        centerX = (left + right) / 2;
        centerY = (top + bottom) / 2;
        handlePositions = [left, top; centerX, top; right, top; right, centerY; ...
            right, bottom; centerX, bottom; left, bottom; left, centerY];
        for handleIndex = 1:numel(cropHandles)
            cropHandles(handleIndex).XData = handlePositions(handleIndex, 1);
            cropHandles(handleIndex).YData = handlePositions(handleIndex, 2);
        end
        for coordinateIndex = 1:4
            if isempty(activeSpinner) || ~isequal(cropSpinners(coordinateIndex), activeSpinner)
                cropSpinners(coordinateIndex).Value = cropBounds(coordinateIndex);
            end
        end
        window.UserData.Task3Settings = getTask3Settings();
        drawnow limitrate nocallbacks;
    end

    function settings = getTask3Settings()
        settings = struct('Bounds', cropBounds, 'x1', cropBounds(1), 'y1', cropBounds(2), ...
            'x2', cropBounds(3), 'y2', cropBounds(4), ...
            'CoordinateConvention', '1-based inclusive pixel indices', ...
            'OutputSize', [cropBounds(4) - cropBounds(2) + 1, ...
                cropBounds(3) - cropBounds(1) + 1], ...
            'Dragging', cropDrag.Active, 'CroppingImplemented', true);
    end

    function point = getCropPointer()
        % Window IntersectionPoint can belong to the processed image or UI.
        % Use one coordinate system for press, motion and release, including
        % when the pointer leaves the original image or crosses another axes.
        position = task3OriginalAxes.CurrentPoint;
        point = position(1, 1:2);
    end

    function beginCropDrag(mode, ~)
        if currentTask ~= 3 || isempty(grayImage) || ~strcmp(window.SelectionType, 'normal')
            return;
        end
        point = getCropPointer();
        if any(~isfinite(point))
            return;
        end
        cropDrag.Active = true;
        cropDrag.Mode = mode;
        cropDrag.StartPoint = point;
        cropDrag.StartBounds = cropBounds;
        if strcmp(mode, 'move')
            window.Pointer = 'fleur';
        else
            window.Pointer = 'crosshair';
        end
        window.UserData.Task3Settings = getTask3Settings();
    end

    function continueCropDrag(~)
        if currentTask ~= 3 || ~cropDrag.Active
            return;
        end
        point = getCropPointer();
        if any(~isfinite(point))
            return;
        end
        delta = round(point - cropDrag.StartPoint);
        bounds = cropDrag.StartBounds;
        mode = cropDrag.Mode;
        if strcmp(mode, 'move')
            delta = min(max(delta, [1 - bounds(1), 1 - bounds(2)]), ...
                [imageWidth - bounds(3), imageHeight - bounds(4)]);
            bounds = bounds + delta([1, 2, 1, 2]);
        else
            if contains(mode, 'w')
                bounds(1) = min(max(bounds(1) + delta(1), 1), bounds(3));
            elseif contains(mode, 'e')
                bounds(3) = max(min(bounds(3) + delta(1), imageWidth), bounds(1));
            end
            if contains(mode, 'n')
                bounds(2) = min(max(bounds(2) + delta(2), 1), bounds(4));
            elseif contains(mode, 's')
                bounds(4) = max(min(bounds(4) + delta(2), imageHeight), bounds(2));
            end
        end
        if ~isequal(cropBounds, bounds)
            cropBounds = bounds;
            refreshTask3Output([]);
        end
    end

    function endCropDrag(event)
        if cropDrag.Active
            continueCropDrag(event);
            cancelCropDrag();
        end
    end

    function cancelCropDrag()
        cropDrag.Active = false;
        window.Pointer = 'arrow';
        if isstruct(window.UserData)
            window.UserData.Task3Settings = getTask3Settings();
        end
    end

    function changeTask(taskIndex)
        cancelCropDrag();
        currentTask = taskIndex;
        applyTaskWindowSize();
        task4Content.Visible = 'off';
        task5Content.Visible = 'off';
        task6Content.Visible = 'off';
        if currentTask == 1
            exportButton.Enable = visibility(~isempty(grayImage));
            exportButton.Tooltip = 'Save the current grayscale result to Task1-6_Output.';
            placeholder.Visible = 'off';
            task2Content.Visible = 'off';
            task3Content.Visible = 'off';
            task1Content.Visible = 'on';
            configureParameters();
            refreshOutput([]);
        elseif currentTask == 2
            exportButton.Enable = visibility(~isempty(grayImage));
            exportButton.Tooltip = 'Save the current grayscale result to Task1-6_Output.';
            task1Content.Visible = 'off';
            task3Content.Visible = 'off';
            placeholder.Visible = 'off';
            task2Content.Visible = 'on';
            window.UserData.CurrentTask = currentTask;
            window.UserData.TaskImplemented = true;
            window.UserData.GUIImplemented = true;
            syncTask2Controls(false);
            refreshTask2Output();
        elseif currentTask == 3
            exportButton.Enable = visibility(~isempty(grayImage));
            exportButton.Tooltip = 'Save the current grayscale result to Task1-6_Output.';
            task1Content.Visible = 'off';
            task2Content.Visible = 'off';
            placeholder.Visible = 'off';
            task3Content.Visible = 'on';
            window.UserData.CurrentTask = currentTask;
            window.UserData.TaskImplemented = true;
            window.UserData.GUIImplemented = true;
            refreshTask3Output([]);
        elseif currentTask == 4
            exportButton.Tooltip = 'Save the current binary result to Task1-6_Output/Task4_Binary.png.';
            task1Content.Visible = 'off';
            task2Content.Visible = 'off';
            task3Content.Visible = 'off';
            placeholder.Visible = 'off';
            task4Content.Visible = 'on';
            window.UserData.CurrentTask = currentTask;
            window.UserData.TaskImplemented = true;
            window.UserData.GUIImplemented = true;
            thresholdField.Value = binaryThreshold;
            thresholdSlider.Value = binaryThreshold;
            loadTask4Input();
        elseif currentTask == 5
            exportButton.Tooltip = 'Save the current binary edge result to Task1-6_Output.';
            task1Content.Visible = 'off';
            task2Content.Visible = 'off';
            task3Content.Visible = 'off';
            placeholder.Visible = 'off';
            task5Content.Visible = 'on';
            window.UserData.CurrentTask = currentTask;
            window.UserData.TaskImplemented = true;
            window.UserData.GUIImplemented = true;
            loadTask5Source();
            syncTask5Layout();
        else
            exportButton.Enable = 'off';
            exportButton.Tooltip = 'Save the current region matrices, labeled image and character crops.';
            task1Content.Visible = 'off';
            task2Content.Visible = 'off';
            task3Content.Visible = 'off';
            placeholder.Visible = 'off';
            task6Content.Visible = 'on';
            window.UserData.CurrentTask = currentTask;
            window.UserData.TaskImplemented = true;
            window.UserData.GUIImplemented = true;
            loadTask6Input();
            syncTask6Layout();
        end
        window.UserData.DefaultWindowSize = getTaskDefaultWindowSize(currentTask, task5State);
    end

    function changeFilter(filterIndex)
        if currentTask ~= 2
            return;
        end
        currentFilter = filterIndex;
        syncTask2Controls(false);
        refreshTask2Output();
    end

    function changeNeighborhoodWidth(value, isSlider, isDragging)
        if currentTask ~= 2
            return;
        end
        if ~isfinite(value)
            syncTask2Controls(false);
            return;
        end
        if isSlider
            width = 1 + 2 * round(value);
        else
            width = 1 + 2 * round((value - 1) / 2);
        end
        neighborhoodWidth = min(max(width, neighborhoodLimits(1)), neighborhoodLimits(2));
        syncTask2Controls(isDragging);
        refreshTask2Output();
    end

    function syncTask2Controls(isDragging)
        minimumWidth = 1;
        if currentFilter == 2
            minimumWidth = 5;
        end
        neighborhoodWidth = max(minimumWidth, neighborhoodWidth);
        filterSelector.Value = currentFilter;
        % Set a valid value before raising the lower numeric-field limit.
        neighborhoodField.Limits = neighborhoodLimits;
        neighborhoodField.Value = neighborhoodWidth;
        neighborhoodField.Limits = [minimumWidth, neighborhoodLimits(2)];
        if neighborhoodSlider.Value < (minimumWidth - 1) / 2
            neighborhoodSlider.Value = (minimumWidth - 1) / 2;
        end
        neighborhoodSlider.Limits = [(minimumWidth - 1) / 2, ...
            (neighborhoodLimits(2) - 1) / 2];
        if ~isDragging
            neighborhoodSlider.Value = (neighborhoodWidth - 1) / 2;
        end
        window.UserData.Task2Settings = getTask2Settings();
    end

    function settings = getTask2Settings()
        settings = struct('FilterIndex', currentFilter, ...
            'Filter', filterNames{currentFilter}, 'NeighborhoodWidth', neighborhoodWidth, ...
            'Padding', 'replicate', 'FilteringImplemented', true);
        if currentFilter == 2
            settings.MaskWidth = getRotatingMaskWidth(neighborhoodWidth);
        end
    end

    function refreshTask2Output()
        if isempty(grayImage)
            task2ProcessedDisplay.CData = zeros(0, 0, 'uint8');
            window.UserData.Task2Settings = getTask2Settings();
            return;
        end
        % Repeated slider events within the same odd width reuse the preview.
        if lastTask2Filter ~= currentFilter || lastTask2Width ~= neighborhoodWidth
            task2ProcessedDisplay.CData = applyImageSmoothing( ...
                grayImage, currentFilter, neighborhoodWidth);
            lastTask2Filter = currentFilter;
            lastTask2Width = neighborhoodWidth;
        end
        window.UserData.Task2Settings = getTask2Settings();
        drawnow limitrate nocallbacks;
    end

    function applyTaskWindowSize()
        if ~strcmp(window.WindowState, 'normal')
            window.WindowState = 'normal';
            drawnow nocallbacks;
        end
        position = window.Position;
        center = position(1:2) + position(3:4) / 2;
        monitors = get(groot, 'MonitorPositions');
        onMonitor = center(1) >= monitors(:, 1) ...
            & center(1) < monitors(:, 1) + monitors(:, 3) ...
            & center(2) >= monitors(:, 2) ...
            & center(2) < monitors(:, 2) + monitors(:, 4);
        monitorIndex = find(onMonitor, 1);
        if isempty(monitorIndex)
            monitorCenters = monitors(:, 1:2) + monitors(:, 3:4) / 2;
            [~, monitorIndex] = min(sum((monitorCenters - center).^2, 2));
        end
        monitor = monitors(monitorIndex, :);
        sizePixels = min(getTaskDefaultWindowSize(currentTask, task5State), ...
            max([1, 1], monitor(3:4) - [60, 100]));
        left = center(1) - sizePixels(1) / 2;
        bottom = position(2) + position(4) - sizePixels(2);
        left = min(max(left, monitor(1) + 30), ...
            monitor(1) + monitor(3) - sizePixels(1) - 30);
        bottom = min(max(bottom, monitor(2) + 50), ...
            monitor(2) + monitor(4) - sizePixels(2) - 50);
        window.Position = [left, bottom, sizePixels];
    end

    function exportCurrentImage()
        if (currentTask <= 3 && isempty(grayImage)) ...
                || (currentTask == 4 && isempty(task4InputImage)) ...
                || (currentTask == 5 && isempty(task5SourceImage)) ...
                || (currentTask == 6 && isempty(task6InputImage))
            return;
        end
        try
            if currentTask == 6
                refreshTask6Output();
                outputFolder = fullfile(projectFolder, 'Task1-6_Output');
                outputPath = exportTask6Bundle(outputFolder, ...
                    getTask6OutputFolderName(task6State), task6LabelMatrix, ...
                    task6BoundingBoxes, task6LabeledImage, task6InputImage);
                exportButton.UserData = outputPath;
                exportButton.Tooltip = sprintf('Saved: %s', outputPath);
                fprintf('Saved segmentation bundle: %s\n', outputPath);
                return;
            end
            if currentTask == 1
                outputImage = processedDisplay.CData;
                fileName = getTask1OutputFileName(methodNames{currentMethod}, ...
                    parameterDefinition.Names, parameters, slicePreserveBackground);
            elseif currentTask == 2
                refreshTask2Output();
                outputImage = task2ProcessedDisplay.CData;
                fileName = sprintf('Task2_%s_n_%d.png', ...
                    regexprep(filterNames{currentFilter}, '\s+', '_'), neighborhoodWidth);
            elseif currentTask == 3
                outputImage = task3ProcessedDisplay.CData;
                % One stable downstream input, independent of crop coordinates.
                fileName = 'Task3_Sub-image.png';
            elseif currentTask == 4
                refreshTask4Output();
                outputImage = task4BinaryDisplay.CData;
                fileName = 'Task4_Binary.png';
            else
                refreshTask5Output();
                outputImage = task5FinalImage;
                fileName = getTask5OutputFileName(task5State, edgeMethodNames, filterNames);
            end
            if currentTask >= 4
                if ~islogical(outputImage) || ~ismatrix(outputImage) || isempty(outputImage)
                    error('ME5411:InvalidOutput', 'The output must be a logical binary image.');
                end
                bitDepth = 1;
                imageType = 'binary';
            elseif ~isa(outputImage, 'uint8') || ~ismatrix(outputImage)
                error('ME5411:InvalidOutput', 'The output must be an 8-bit grayscale image.');
            else
                bitDepth = 8;
                imageType = 'grayscale';
            end
            outputFolder = fullfile(projectFolder, 'Task1-6_Output');
            if ~isfolder(outputFolder)
                [created, message] = mkdir(outputFolder);
                if ~created
                    error('ME5411:OutputFolder', 'Cannot create output folder: %s', message);
                end
            end
            outputPath = fullfile(outputFolder, fileName);
            imwrite(outputImage, outputPath, 'png', 'BitDepth', bitDepth);
            exportButton.UserData = outputPath;
            exportButton.Tooltip = sprintf('Saved: %s', outputPath);
            fprintf('Saved %s image: %s\n', imageType, outputPath);
        catch exception
            uialert(window, exception.message, 'Image Export Failed');
        end
    end

    function changeMethod(methodIndex)
        if currentTask ~= 1
            return;
        end
        methodParameters{currentMethod} = parameters;
        currentMethod = methodIndex;
        parameters = methodParameters{currentMethod};
        configureParameters();
        refreshOutput([]);
    end

    function configureParameters()
        parameterDefinition = methodDefinitions{currentMethod};
        rowHeights = {32, 0, 0, 0, 0, 0, '1x'};
        sliceBackgroundToggle.Value = slicePreserveBackground;
        if currentMethod == 2
            sliceBackgroundToggle.Visible = 'on';
            rowHeights{5} = 24;
        else
            sliceBackgroundToggle.Visible = 'off';
        end
        for parameterIndex = 1:4
            parameterRow = parameterIndex + 1 + (parameterIndex == 4);
            if parameterIndex <= numel(parameters)
                parameterName = parameterDefinition.Names{parameterIndex};
                rowHeights{parameterRow} = 26;
                parameterLabels(parameterIndex).Text = parameterName;
                parameterLabels(parameterIndex).Tag = ['Task1Label_', parameterName];
                sliders(parameterIndex).Tag = ['Task1Slider_', parameterName];
                fields(parameterIndex).Tag = ['Task1Field_', parameterName];
                fields(parameterIndex).Limits = parameterDefinition.Limits(parameterIndex, :);
                if parameterDefinition.Integer(parameterIndex)
                    fields(parameterIndex).RoundFractionalValues = 'on';
                    fields(parameterIndex).ValueDisplayFormat = '%.0f';
                else
                    fields(parameterIndex).RoundFractionalValues = 'off';
                    fields(parameterIndex).ValueDisplayFormat = '%.6g';
                end
                visible = 'on';
                if currentMethod == 2 && parameterIndex == 4 && slicePreserveBackground
                    rowHeights{parameterRow} = 0;
                    visible = 'off';
                end
            else
                parameterLabels(parameterIndex).Text = '';
                parameterLabels(parameterIndex).Tag = sprintf('Task1Label_Unused%d', parameterIndex);
                sliders(parameterIndex).Tag = sprintf('Task1Slider_Unused%d', parameterIndex);
                fields(parameterIndex).Tag = sprintf('Task1Field_Unused%d', parameterIndex);
                visible = 'off';
            end
            sliders(parameterIndex).Visible = visible;
            fields(parameterIndex).Visible = visible;
            parameterLabels(parameterIndex).Visible = visible;
        end
        controlGrid.RowHeight = rowHeights;
        formulaLabel.Text = getEnhancementFormula(currentMethod, slicePreserveBackground);
    end

    function changeSliceBackground(preserveBackground)
        if currentTask ~= 1 || currentMethod ~= 2
            return;
        end
        slicePreserveBackground = logical(preserveBackground);
        configureParameters();
        refreshOutput([]);
    end

    function changeParameter(parameterIndex, newValue, source, isDragging)
        if currentTask ~= 1 || parameterIndex > numel(parameters)
            return;
        end
        if currentMethod == 2 && parameterIndex == 4 && slicePreserveBackground
            return;
        end
        if ~isfinite(newValue)
            refreshOutput([]);
            return;
        end
        limits = parameterDefinition.Limits(parameterIndex, :);
        if parameterDefinition.Integer(parameterIndex)
            newValue = round(newValue);
        end
        value = min(max(newValue, limits(1)), limits(2));
        if currentMethod == 1
            switch parameterIndex
                case 1
                    value = min(value, parameters(2) - 1);
                case 2
                    value = max(value, parameters(1) + 1);
                case 3
                    value = min(value, parameters(4));
                case 4
                    value = max(value, parameters(3));
            end
        elseif currentMethod == 2
            if parameterIndex == 1
                value = min(value, parameters(2));
            elseif parameterIndex == 2
                value = max(value, parameters(1));
            end
        end
        parameters(parameterIndex) = value;
        methodParameters{currentMethod} = parameters;
        if isDragging
            refreshOutput(source);
        else
            refreshOutput([]);
        end
    end

    function refreshOutput(activeSlider)
        [lookupTable, curveX, curveY, useSteps] = makeEnhancementLookupTable( ...
            currentMethod, parameters, inputCounts, slicePreserveBackground);
        processedImage = reshape(lookupTable(inputIndices), size(grayImage));
        outputCounts = accumarray(double(lookupTable) + 1, inputCounts, [256, 1]);
        for parameterIndex = 1:numel(parameters)
            if isempty(activeSlider) || ~isequal(sliders(parameterIndex), activeSlider)
                sliderLimits = parameterDefinition.Limits(parameterIndex, :);
                if isinf(sliderLimits(2))
                    sliderLimits(2) = max(100, parameters(parameterIndex));
                end
                sliders(parameterIndex).Limits = sliderLimits;
                sliders(parameterIndex).Value = parameters(parameterIndex);
            end
            fields(parameterIndex).Value = parameters(parameterIndex);
        end
        processedDisplay.CData = processedImage;
        histogramBars.YData = outputCounts.';
        configureHistogramAxes(histogramAxes);
        histogramAxes.YLim = [0, max(1, max(outputCounts) * 1.08)];
        if useSteps
            transferLine.Visible = 'off';
            transferSteps.XData = curveX;
            transferSteps.YData = curveY;
            transferSteps.Visible = 'on';
        else
            transferSteps.Visible = 'off';
            transferLine.XData = curveX;
            transferLine.YData = curveY;
            transferLine.Marker = 'none';
            transferLine.Visible = 'on';
        end
        if isempty(parameters)
            namedParameters = struct();
        else
            namedParameters = cell2struct(num2cell(parameters), parameterDefinition.Names, 2);
        end
        window.UserData = struct('InterfaceVersion', interfaceVersion, ...
            'CurrentTask', currentTask, ...
            'DefaultWindowSize', getTaskDefaultWindowSize(currentTask, task5State), ...
            'TaskImplemented', currentTask <= 6, 'MethodIndex', currentMethod, ...
            'GUIImplemented', currentTask <= 6, 'Task2Settings', getTask2Settings(), ...
            'Task3Settings', getTask3Settings(), 'Task4Settings', getTask4Settings(), ...
            'Task5Settings', getTask5Settings(), ...
            'Task6Settings', getTask6Settings(), ...
            'Method', methodNames{currentMethod}, 'Parameters', parameters, ...
            'ParameterNames', {parameterDefinition.Names}, 'NamedParameters', namedParameters, ...
            'MethodParameters', {methodParameters}, ...
            'SlicePreserveBackground', slicePreserveBackground, ...
            'GrayImage', grayImage, 'InputHistogram', inputCounts, ...
            'LookupTable', lookupTable, 'ImagePath', imagePath);
        drawnow limitrate;
    end
end

function [labels, boxes, centroids, areas, totalCount] = labelTask6Components(binaryImage, connectivity)
    [height, width] = size(binaryImage);
    labels = zeros(height, width, 'uint32');
    boxes = zeros(0, 4);
    centroids = zeros(0, 2);
    areas = zeros(0, 1);
    totalCount = 0;
    if ~any(binaryImage(:))
        return;
    end
    provisional = zeros(height, width, 'uint32');
    parents = zeros(nnz(binaryImage), 1, 'uint32');
    nextLabel = 0;
    neighbors = zeros(1, 4, 'uint32');
    % First pass: assign provisional labels and union equivalent neighbors.
    for row = 1:height
        for column = 1:width
            if ~binaryImage(row, column)
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
    % Second pass: resolve every equivalence before measuring components.
    roots = zeros(nextLabel, 1, 'uint32');
    for index = 1:nextLabel
        root = uint32(index);
        while parents(root) ~= root
            root = parents(root);
        end
        roots(index) = root;
    end
    foreground = find(binaryImage);
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

function [labels, boxes, centroids, areas] = splitTask6Regions(initialLabels, initialBoxes, ...
        expectedWidth, tolerance)
    labels = zeros(size(initialLabels), 'uint32');
    accepted = cell(0, 1);
    minimumWidth = expectedWidth - tolerance;
    maximumWidth = expectedWidth + tolerance;
    for index = 1:size(initialBoxes, 1)
        bounds = initialBoxes(index, :);
        mask = initialLabels(bounds(1):bounds(3), bounds(2):bounds(4)) == index;
        [rows, columns] = find(mask);
        pixels = [rows(:) + bounds(1) - 1, columns(:) + bounds(2) - 1];
        width = bounds(4) - bounds(2) + 1;
        if width < minimumWidth
            continue;
        elseif width <= maximumWidth
            accepted{end + 1, 1} = pixels; %#ok<AGROW>
            continue;
        end

        % Count and locate all cuts from this original component, never its children.
        partCount = min(width, max(2, round(width / expectedWidth)));
        nominalCuts = (1:partCount - 1)' * width / partCount;
        roundedCuts = round(nominalCuts);
        cellEdges = [0; floor((nominalCuts(1:end - 1) + nominalCuts(2:end)) / 2); width - 1];
        projection = sum(mask, 1)';
        cuts = zeros(partCount - 1, 1);
        for cutIndex = 1:partCount - 1
            % Disjoint cells prevent duplicate/reversed cuts when tolerance is large.
            first = max([1, roundedCuts(cutIndex) - tolerance, cellEdges(cutIndex) + 1]);
            last = min([width - 1, roundedCuts(cutIndex) + tolerance, cellEdges(cutIndex + 1)]);
            candidates = (first:last)';
            [~, order] = sortrows([projection(candidates), ...
                abs(candidates - nominalCuts(cutIndex)), candidates]);
            cuts(cutIndex) = candidates(order(1));
        end
        edges = [0; cuts; width];
        for partIndex = 1:partCount
            selected = columns > edges(partIndex) & columns <= edges(partIndex + 1);
            part = pixels(selected, :);
            if isempty(part)
                continue;
            end
            if max(part(:, 2)) - min(part(:, 2)) + 1 >= minimumWidth
                % One part is one character label even if cutting disconnects strokes.
                accepted{end + 1, 1} = part; %#ok<AGROW>
            end
        end
    end
    count = numel(accepted);
    boxes = zeros(count, 4);
    centroids = zeros(count, 2);
    areas = zeros(count, 1);
    for index = 1:count
        pixels = accepted{index};
        boxes(index, :) = [min(pixels(:, 1)), min(pixels(:, 2)), ...
            max(pixels(:, 1)), max(pixels(:, 2))];
        centroids(index, :) = [mean(pixels(:, 2)), mean(pixels(:, 1))];
        areas(index) = size(pixels, 1);
    end
    [~, order] = sortrows([centroids, boxes(:, 1:2), (1:count)']);
    for index = 1:count
        pixels = accepted{order(index)};
        labels(sub2ind(size(labels), pixels(:, 1), pixels(:, 2))) = uint32(index);
    end
    boxes = boxes(order, :);
    centroids = centroids(order, :);
    areas = areas(order);
end

function colors = getTask6RegionColors()
    colors = uint8([220, 45, 55; 0, 105, 200; 0, 145, 70; 150, 55, 190; ...
        225, 115, 0; 0, 150, 165; 185, 45, 125; 120, 135, 0; ...
        90, 95, 210; 150, 85, 40; 100, 120, 140]);
end

function rgb = renderTask6Labels(labels, boxes)
    palette = [uint8([255, 255, 255]); getTask6RegionColors()];
    [height, width] = size(labels);
    pixels = palette(min(double(labels(:)), 11) + 1, :);
    rgb = reshape(pixels, height, width, 3);
    for index = 1:size(boxes, 1)
        top = boxes(index, 1);
        left = boxes(index, 2);
        bottom = boxes(index, 3);
        right = boxes(index, 4);
        rgb([top, bottom], left:right, :) = 0;
        rgb(top:bottom, [left, right], :) = 0;
    end
    % Raster IDs keep the saved PNG identical to the image displayed in the GUI.
    for index = 1:size(boxes, 1)
        rgb = drawTask6RegionNumber(rgb, index, boxes(index, 1:2));
    end
end

function rgb = drawTask6RegionNumber(rgb, number, position)
    glyphs = {'111101101101111', '010110010010111', '111001111100111', ...
        '111001111001111', '101101111001001', '111100111001111', ...
        '111100111101111', '111001001001001', '111101111101111', '111101111001111'};
    digits = sprintf('%d', number);
    mask = false(5, 4 * numel(digits) - 1);
    for index = 1:numel(digits)
        mask(:, 4 * (index - 1) + (1:3)) = reshape(glyphs{double(digits(index)) - 47} == '1', 3, 5)';
    end
    [height, width, ~] = size(rgb);
    top = max(1, min(position(1) + 1, height - 4));
    left = max(1, min(position(2) + 1, width - size(mask, 2) + 1));
    rows = top:min(height, top + 4);
    columns = left:min(width, left + size(mask, 2) - 1);
    badge = repmat(uint8(~mask(1:numel(rows), 1:numel(columns))) * 255, 1, 1, 3);
    rgb(rows, columns, :) = badge;
end

function name = getTask6OutputFolderName(settings)
    name = sprintf('Task6_VerticalProjection_connectivity_%d_expected_width_%d_tolerance_%d', ...
        settings.Connectivity, settings.ExpectedWidth, settings.Tolerance);
end

function outputPath = exportTask6Bundle(outputRoot, folderName, labels, boxes, rgb, cropImage)
    if ~isfolder(outputRoot)
        [created, message] = mkdir(outputRoot);
        if ~created
            error('ME5411:OutputFolder', 'Cannot create output folder: %s', message);
        end
    end
    outputPath = fullfile(outputRoot, folderName);
    assertTask6OutputTarget(outputRoot, outputPath);
    if isfile(outputPath)
        error('ME5411:OutputFolder', 'A file occupies the output folder path: %s', outputPath);
    end
    stage = tempname(outputRoot);
    assertTask6OutputTarget(outputRoot, stage);
    [created, message] = mkdir(stage);
    if ~created
        error('ME5411:OutputFolder', 'Cannot create staging folder: %s', message);
    end
    cleanup = onCleanup(@() removeTask6StagingDirectory(outputRoot, stage));
    writematrix(labels, fullfile(stage, '01_LabelMatrix.csv'));
    coordinates = array2table(boxes, ...
        'VariableNames', {'TopRow', 'LeftColumn', 'BottomRow', 'RightColumn'});
    writetable(coordinates, fullfile(stage, '02_BoundingBoxes.csv'));
    imwrite(rgb, fullfile(stage, '03_LabeledImage.png'));
    for index = 1:size(boxes, 1)
        bounds = boxes(index, :);
        crop = cropImage(bounds(1):bounds(3), bounds(2):bounds(4));
        filename = sprintf('%02d_Character_%02d.png', index + 3, index);
        imwrite(crop, fullfile(stage, filename), 'BitDepth', 1);
    end
    backup = '';
    if isfolder(outputPath)
        backup = tempname(outputRoot);
        assertTask6OutputTarget(outputRoot, backup);
        [moved, message] = movefile(outputPath, backup);
        if ~moved
            error('ME5411:OutputReplace', 'Cannot preserve the previous output: %s', message);
        end
    end
    try
        [moved, message] = movefile(stage, outputPath);
        if ~moved
            error('ME5411:OutputReplace', 'Cannot publish the output bundle: %s', message);
        end
    catch exception
        if ~isempty(backup) && isfolder(backup)
            [restored, message] = movefile(backup, outputPath);
            if ~restored
                error('ME5411:OutputRestore', ...
                    'Previous output remains at [%s]. Restore failed: %s', backup, message);
            end
        end
        rethrow(exception);
    end
    if ~isempty(backup)
        removeTask6StagingDirectory(outputRoot, backup);
    end
end

function assertTask6OutputTarget(outputRoot, target)
    root = char(java.io.File(outputRoot).getCanonicalPath());
    resolved = char(java.io.File(target).getCanonicalPath());
    if ~startsWith(resolved, [root, filesep], 'IgnoreCase', ispc)
        error('ME5411:UnsafeOutputTarget', 'Output target must remain inside [%s].', root);
    end
end

function removeTask6StagingDirectory(outputRoot, target)
    if isfolder(target)
        assertTask6OutputTarget(outputRoot, target);
        rmdir(target, 's');
    end
end

function edges = detectTwoPassEdges(binaryImage)
    edges = false(size(binaryImage));
    edges(:, 2:end) = binaryImage(:, 2:end) ~= binaryImage(:, 1:end-1);
    edges(2:end, :) = edges(2:end, :) ...
        | binaryImage(2:end, :) ~= binaryImage(1:end-1, :);
end

function response = correlateImage3x3(pixels, kernel)
    [height, width] = size(pixels);
    rowIndices = [1, 1:height, height];
    columnIndices = [1, 1:width, width];
    padded = pixels(rowIndices, columnIndices);
    response = conv2(padded, rot90(kernel, 2), 'valid');
end

function [magnitude, direction] = computeSobelGradient(inputImage)
    pixels = double(inputImage);
    pixelScale = 1;
    if ~islogical(inputImage)
        pixelScale = 255;
    end
    rowDerivative = correlateImage3x3(pixels, [-1, -2, -1; 0, 0, 0; 1, 2, 1]);
    columnDerivative = correlateImage3x3(pixels, [-1, 0, 1; -2, 0, 2; -1, 0, 1]);
    magnitude = min(1, hypot(rowDerivative, columnDerivative) / (4 * sqrt(2) * pixelScale));
    direction = atan2d(columnDerivative, rowDerivative);
end

function edges = detectLaplacianZeroCrossings(response, minimumDifference)
    [height, width] = size(response);
    edges = false(height, width);
    % Each undirected 8-neighbor pair is visited once, without wrapping borders.
    offsets = [0, 1; 1, -1; 1, 0; 1, 1];
    for offsetIndex = 1:size(offsets, 1)
        deltaRow = offsets(offsetIndex, 1);
        deltaColumn = offsets(offsetIndex, 2);
        rows = max(1, 1 - deltaRow):min(height, height - deltaRow);
        columns = max(1, 1 - deltaColumn):min(width, width - deltaColumn);
        first = response(rows, columns);
        second = response(rows + deltaRow, columns + deltaColumn);
        opposite = ((first < 0 & second > 0) | (first > 0 & second < 0)) ...
            & abs(first - second) > minimumDifference;
        firstIsNearer = abs(first) <= abs(second);
        edges(rows, columns) = edges(rows, columns) | (opposite & firstIsNearer);
        edges(rows + deltaRow, columns + deltaColumn) = ...
            edges(rows + deltaRow, columns + deltaColumn) | (opposite & ~firstIsNearer);
        % An exact zero is an edge only when opposite neighbors bracket it.
        centerRows = (1 + abs(deltaRow)):(height - abs(deltaRow));
        centerColumns = (1 + abs(deltaColumn)):(width - abs(deltaColumn));
        before = response(centerRows - deltaRow, centerColumns - deltaColumn);
        after = response(centerRows + deltaRow, centerColumns + deltaColumn);
        bracketed = ((before < 0 & after > 0) | (before > 0 & after < 0)) ...
            & abs(before - after) > minimumDifference;
        edges(centerRows, centerColumns) = edges(centerRows, centerColumns) ...
            | (response(centerRows, centerColumns) == 0 & bracketed);
    end
end

function [linked, linkCount] = linkLocalEdges(edges, magnitude, direction, ...
        neighborhoodWidth, magnitudeTolerance, directionTolerance)
    linked = edges;
    linkCount = 0;
    [height, width] = size(edges);
    radius = (neighborhoodWidth - 1) / 2;
    % Frozen input edges prevent recursive growth into unsupported image regions.
    for deltaRow = 0:radius
        for deltaColumn = -radius:radius
            if deltaRow == 0 && deltaColumn <= 0
                continue;
            end
            rows = max(1, 1 - deltaRow):min(height, height - deltaRow);
            columns = max(1, 1 - deltaColumn):min(width, width - deltaColumn);
            if isempty(rows) || isempty(columns)
                continue;
            end
            firstMagnitude = magnitude(rows, columns);
            secondMagnitude = magnitude(rows + deltaRow, columns + deltaColumn);
            angleDifference = abs(direction(rows, columns) ...
                - direction(rows + deltaRow, columns + deltaColumn));
            angleDifference = min(angleDifference, 360 - angleDifference);
            accepted = edges(rows, columns) & edges(rows + deltaRow, columns + deltaColumn) ...
                & firstMagnitude > 0 & secondMagnitude > 0 ...
                & abs(firstMagnitude - secondMagnitude) <= magnitudeTolerance ...
                & angleDifference <= directionTolerance;
            linkCount = linkCount + nnz(accepted);
            if max(abs([deltaRow, deltaColumn])) == 2
                % A two-step 8-connected line has exactly one intermediate pixel.
                [localRows, localColumns] = find(accepted);
                middleRows = localRows + rows(1) - 1 + round(deltaRow / 2);
                middleColumns = localColumns + columns(1) - 1 + round(deltaColumn / 2);
                linked(sub2ind([height, width], middleRows, middleColumns)) = true;
            end
        end
    end
end

function fileName = getTask5OutputFileName(settings, edgeMethodNames, filterNames)
    methodToken = regexprep(edgeMethodNames{settings.MethodIndex}, '\s+', '_');
    inputToken = '';
    if settings.MethodIndex ~= 1
        if settings.UseBinaryImage
            inputToken = '_input_binary';
        else
            inputToken = '_input_gray';
        end
    end
    smoothingToken = 'smooth_off';
    if settings.MethodIndex ~= 1 && ~settings.UseBinaryImage && settings.SmoothingEnabled
        filterToken = regexprep(filterNames{settings.SmoothingFilterIndex}, '\s+', '_');
        smoothingToken = sprintf('smooth_%s_n_%d', filterToken, settings.SmoothingWidth);
    end
    thresholdToken = '';
    if settings.MethodIndex == 2
        thresholdToken = ['_threshold_', formatImageParameter(settings.EdgeThreshold)];
    elseif settings.MethodIndex == 3
        thresholdToken = ['_threshold_', formatImageParameter(settings.LaplacianThreshold)];
    end
    linkingToken = 'link_off';
    if settings.LinkingEnabled
        linkingToken = sprintf('link_on_n_%d_magnitude_%s_direction_%d', ...
            settings.LinkNeighborhoodWidth, formatImageParameter(settings.MagnitudeDifference), ...
            settings.DirectionDifference);
    end
    fileName = sprintf('Task5_%s%s_%s%s_%s.png', ...
        methodToken, inputToken, smoothingToken, thresholdToken, linkingToken);
end

function token = formatImageParameter(value)
    % Shortest round-trip-safe decimal prevents collisions from rounded filenames.
    for precision = 1:17
        token = sprintf('%.*g', precision, value);
        if str2double(token) == value
            return;
        end
    end
end

function message = getMissingImageMessage(projectFolder, inputPath)
    relativePath = extractAfter(inputPath, numel(projectFolder) + 1);
    [relativeFolder, fileName, extension] = fileparts(relativePath);
    relativeFolder = strrep(relativeFolder, '\', '/');
    message = sprintf('Please ensure [%s%s] exists in [%s].', fileName, extension, relativeFolder);
end

function value = visibility(flag)
    if flag
        value = 'on';
    else
        value = 'off';
    end
end

function outputImage = applyImageSmoothing(inputImage, filterIndex, width)
    % All methods operate on the original image, with replicated borders.
    if width == 1
        outputImage = inputImage;
        return;
    end
    [height, imageWidth] = size(inputImage);
    radius = (width - 1) / 2;
    rows = min(max((1 - radius):(height + radius), 1), height);
    columns = min(max((1 - radius):(imageWidth + radius), 1), imageWidth);
    paddedImage = inputImage(rows, columns);
    switch filterIndex
        case 1
            summedArea = makeSummedArea(double(paddedImage));
            outputImage = uint8(round(squareWindowSums(summedArea, width) / width^2));
        case 2
            maskWidth = getRotatingMaskWidth(width);
            offset = (width - maskWidth) / 2;
            offsets = [offset, offset; ... % Central mask wins exact variance ties.
                0, 0; 0, offset; 0, 2 * offset; ...
                offset, 0; offset, 2 * offset; ...
                2 * offset, 0; 2 * offset, offset; 2 * offset, 2 * offset];
            pixels = double(paddedImage);
            sums = squareWindowSums(makeSummedArea(pixels), maskWidth);
            squaredSums = squareWindowSums(makeSummedArea(pixels.^2), maskWidth);
            bestScore = inf(height, imageWidth);
            bestSum = zeros(height, imageWidth);
            maskArea = maskWidth^2;
            for maskIndex = 1:size(offsets, 1)
                maskRows = (1:height) + offsets(maskIndex, 1);
                maskColumns = (1:imageWidth) + offsets(maskIndex, 2);
                candidateSum = sums(maskRows, maskColumns);
                % Integer-valued variance numerator avoids floating-point tie noise.
                score = maskArea * squaredSums(maskRows, maskColumns) - candidateSum.^2;
                selected = score < bestScore;
                bestScore(selected) = score(selected);
                bestSum(selected) = candidateSum(selected);
            end
            outputImage = uint8(round(bestSum / maskArea));
        case 3
            outputImage = slidingHistogramMedian(paddedImage, width, height, imageWidth);
        otherwise
            error('ME5411:UnsupportedFilter', 'Unknown smoothing filter.');
    end
end

function maskWidth = getRotatingMaskWidth(width)
    % 5 -> 3, 7 -> 5, 9 -> 5, ...; each odd square contains the target pixel.
    maskWidth = 2 * floor((width + 1) / 4) + 1;
end

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

function outputImage = slidingHistogramMedian(paddedImage, width, height, imageWidth)
    % Exact 2-D median: horizontal row histograms plus vertical cumulative sums.
    minimumGray = double(min(paddedImage(:)));
    maximumGray = double(max(paddedImage(:)));
    numberOfBins = maximumGray - minimumGray + 1;
    numberOfRows = size(paddedImage, 1);
    rowIndices = (1:numberOfRows).';
    % Counts and cumulative counts are integers below 2^24 for widths <= 31.
    % Single precision is exact here and halves intermediate memory traffic.
    rowHistograms = zeros(numberOfRows, numberOfBins, 'single');
    for column = 1:width
        indices = rowIndices + numberOfRows * (double(paddedImage(:, column)) - minimumGray);
        rowHistograms(indices) = rowHistograms(indices) + 1;
    end
    medianRank = (width^2 + 1) / 2;
    outputImage = zeros(height, imageWidth, 'uint8');
    for column = 1:imageWidth
        verticalSums = [zeros(1, numberOfBins, 'single'); cumsum(rowHistograms, 1)];
        windowHistograms = verticalSums((width + 1):end, :) ...
            - verticalSums(1:(end - width), :);
        cumulativeCounts = cumsum(windowHistograms, 2);
        outputImage(:, column) = uint8(minimumGray + sum(cumulativeCounts < medianRank, 2));
        if column < imageWidth
            outgoing = rowIndices + numberOfRows * ...
                (double(paddedImage(:, column)) - minimumGray);
            incoming = rowIndices + numberOfRows * ...
                (double(paddedImage(:, column + width)) - minimumGray);
            rowHistograms(outgoing) = rowHistograms(outgoing) - 1;
            rowHistograms(incoming) = rowHistograms(incoming) + 1;
        end
    end
end

function sizePixels = getTaskDefaultWindowSize(taskIndex, task5Settings)
    taskSizes = [1240, 900; ... % Task 1: images, histograms, controls and formulas
                 1100, 960; ... % Task 2: two full-width images and one control row
                 1240, 380; ... % Task 3: compact images and crop Spinners
                 1240, 260; ... % Task 4: compact sub-image and threshold
                 1240, 300; ... % Task 5: base layout, before optional controls
                 1240, 660];    % Task 6: original, initial labels and processed labels
    sizePixels = taskSizes(taskIndex, :);
    if taskIndex == 5 && nargin > 1
        smoothingVisible = task5Settings.MethodIndex ~= 1 && ~task5Settings.UseBinaryImage ...
            && task5Settings.SmoothingEnabled;
        thresholdVisible = task5Settings.MethodIndex ~= 1;
        sizePixels(2) = sizePixels(2) + 32 * smoothingVisible ...
            + 32 * thresholdVisible + 126 * task5Settings.LinkingEnabled;
    end
end

function group = createHorizontalRadioGroup(parent, names, values, value, tag, callback)
    group = uibuttongroup(parent, 'BorderType', 'none', 'Tag', tag, ...
        'SelectionChangedFcn', callback, 'AutoResizeChildren', 'off');
    % R2024a requires radio buttons to be direct children of a ButtonGroup.
    % Only these internal controls use positions; group layout is grid-managed.
    for index = 1:numel(values)
        uiradiobutton(group, 'Text', names{index}, 'UserData', values(index), ...
            'Tag', sprintf('%s_%d', tag, values(index)), ...
            'Position', [8 + (index - 1) * 120, 0, 120, 22]);
    end
    group.SizeChangedFcn = @(~, ~) layoutHorizontalRadioButtons(group, values);
    selectHorizontalRadioValue(group, value);
end

function layoutHorizontalRadioButtons(group, values)
    leftInset = 8;
    width = min(120, max(1, (group.InnerPosition(3) - leftInset) / numel(values)));
    height = min(22, group.InnerPosition(4));
    bottom = max(0, (group.InnerPosition(4) - height) / 2);
    for index = 1:numel(values)
        button = findall(group, 'Tag', sprintf('%s_%d', group.Tag, values(index)));
        button.Position = [leftInset + (index - 1) * width, bottom, width, height];
    end
end

function selectHorizontalRadioValue(group, value)
    buttons = group.Children;
    selected = arrayfun(@(button) isequal(button.UserData, value), buttons);
    group.SelectedObject = buttons(find(selected, 1));
end

function fileName = getTask1OutputFileName(methodName, parameterNames, ...
        parameters, slicePreserveBackground)
    parts = [{'Task1', regexprep(methodName, '\s+', '_')}, ...
        cell(1, 2 * numel(parameters))];
    for parameterIndex = 1:numel(parameters)
        parameterName = parameterNames{parameterIndex};
        if strcmp(parameterName, 's_out') && slicePreserveBackground
            valueText = 'r';
        else
            valueText = sprintf('%.17g', parameters(parameterIndex));
        end
        parts{2 * parameterIndex + 1} = parameterName;
        parts{2 * parameterIndex + 2} = valueText;
    end
    fileName = [strjoin(parts, '_'), '.png'];
end

function formula = getEnhancementFormula(methodIndex, slicePreserveBackground)
    switch methodIndex
        case 1
            formula = ['$s(r)=\left\{\begin{array}{ll}', ...
                '\displaystyle\frac{s_1}{r_1}r, & 0\le r\le r_1\\[6pt]', ...
                '\displaystyle s_1+\frac{s_2-s_1}{r_2-r_1}(r-r_1), & r_1<r\le r_2\\[6pt]', ...
                '\displaystyle s_2+\frac{255-s_2}{255-r_2}(r-r_2), & r_2<r\le255', ...
                '\end{array}\right.$'];
        case 2
            if slicePreserveBackground
                outside = 'r';
            else
                outside = 's_{\mathrm{out}}';
            end
            formula = ['$s(r)=\left\{\begin{array}{ll}', ...
                's_{\mathrm{in}}, & A\le r\le B\\[6pt]', ...
                outside, ', & \mathrm{otherwise}', ...
                '\end{array}\right.$'];
        case 3
            formula = {'$s(r)=c\ln(1+r)$'; ...
                '$s_{\mathrm{out}}(r)=\mathrm{round}(\min(255,s(r)))$'};
        case 4
            formula = {'$s(r)=\mathrm{round}\left[\frac{G-1}{NM}\,H_c(r)\right]$'; ...
                '$H_c(r)=\sum_{k=0}^{r}H(k),\qquad G=256$'};
        otherwise
            error('ME5411:UnsupportedMethod', 'Unknown enhancement method.');
    end
end

function grayImage = readGrayscaleImage(imagePath)
    originalImage = imread(imagePath);
    if ~isa(originalImage, 'uint8')
        error('ME5411:UnsupportedImage', 'The source image must use uint8 pixels.');
    end
    if ndims(originalImage) == 3 && size(originalImage, 3) == 3
        rgb = double(originalImage);
        grayImage = uint8(round(0.298936021293775 * rgb(:, :, 1) + ...
            0.587043074451121 * rgb(:, :, 2) + ...
            0.114020904255103 * rgb(:, :, 3)));
    elseif ismatrix(originalImage)
        grayImage = originalImage;
    else
        error('ME5411:UnsupportedImage', 'Use an 8-bit grayscale or RGB image.');
    end
end

function configureImageAxes(axesHandle, imageTitle)
    axis(axesHandle, 'image');
    colormap(axesHandle, gray(256));
    axesHandle.CLim = [0, 255];
    axesHandle.YDir = 'reverse';
    axesHandle.XTick = [];
    axesHandle.YTick = [];
    axesHandle.Box = 'on';
    axesHandle.Toolbar.Visible = 'off';
    title(axesHandle, imageTitle);
end

function configureHistogramAxes(axesHandle)
    axesHandle.XLim = [-0.5, 255.5];
    axesHandle.XTick = [0, 64, 128, 192, 255];
    axesHandle.XTickLabel = {'0', '64', '128', '192', '255'};
    axesHandle.XTickLabelRotation = 0;
    axesHandle.XScale = 'linear';
    axesHandle.XDir = 'normal';
    axesHandle.FontSize = 12;
    axesHandle.Units = 'pixels';
    axesHandle.LooseInset = [40, 24, 16, 28];
    axesHandle.Box = 'on';
    axesHandle.Toolbar.Visible = 'off';
    grid(axesHandle, 'on');
end

function definitions = getEnhancementParameterDefinitions()
    definitions = {
        struct('Names', {{'r1', 'r2', 's1', 's2'}}, ...
            'Limits', [1, 253; 2, 254; 0, 255; 0, 255], ...
            'Integer', true(1, 4), 'DefaultValues', [80, 140, 30, 220]);
        struct('Names', {{'A', 'B', 's_in', 's_out'}}, ...
            'Limits', repmat([0, 255], 4, 1), ...
            'Integer', true(1, 4), 'DefaultValues', [80, 140, 255, 0]);
        struct('Names', {{'c'}}, 'Limits', [0, Inf], ...
            'Integer', false, 'DefaultValues', 255 / log(256));
        struct('Names', {cell(1, 0)}, 'Limits', zeros(0, 2), ...
            'Integer', false(1, 0), 'DefaultValues', zeros(1, 0))
        };
end

function [lookupTable, curveX, curveY, useSteps] = makeEnhancementLookupTable( ...
        methodIndex, parameters, inputCounts, slicePreserveBackground)
    inputLevels = (0:255).';
    useSteps = false;
    switch methodIndex
        case 1
            r1 = parameters(1);
            r2 = parameters(2);
            s1 = parameters(3);
            s2 = parameters(4);
            low = inputLevels <= r1;
            middle = inputLevels > r1 & inputLevels <= r2;
            high = inputLevels > r2;
            outputLevels = zeros(256, 1);
            outputLevels(low) = s1 * inputLevels(low) / r1;
            outputLevels(middle) = s1 + ...
                (s2 - s1) * (inputLevels(middle) - r1) / (r2 - r1);
            outputLevels(high) = s2 + ...
                (255 - s2) * (inputLevels(high) - r2) / (255 - r2);
            curveX = [0, r1, r2, 255];
            curveY = [0, s1, s2, 255];
        case 2
            A = parameters(1);
            B = parameters(2);
            sIn = parameters(3);
            sOut = parameters(4);
            if slicePreserveBackground
                outputLevels = inputLevels;
            else
                outputLevels = repmat(sOut, 256, 1);
            end
            selected = inputLevels >= A & inputLevels <= B;
            outputLevels(selected) = sIn;
            curveX = inputLevels.';
            curveY = outputLevels.';
            useSteps = true;
        case 3
            c = parameters(1);
            outputLevels = c * log1p(inputLevels);
            curveX = inputLevels.';
            curveY = min(max(outputLevels, 0), 255).';
        case 4
            outputLevels = 255 * cumsum(inputCounts) / max(1, sum(inputCounts));
            curveX = inputLevels.';
            curveY = round(outputLevels).';
            useSteps = true;
        otherwise
            error('ME5411:UnsupportedMethod', 'Unknown enhancement method.');
    end
    lookupTable = uint8(round(min(max(outputLevels, 0), 255)));
end
