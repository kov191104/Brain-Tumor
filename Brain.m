function Brain
    % Create the main figure for the GUI with pastel background color
    fig = uifigure('Name', 'Brain Tumor Detection', 'Position',[100, 100, 1278, 1080]);
    annotation(fig, 'textbox', [0.25, 0.93, 0.6, 0.05], 'String', 'BRAIN TUMOR DETECTION', ...
               'FontSize', 25, 'FontWeight', 'bold', 'EdgeColor', 'none', 'HorizontalAlignment', 'center');

    % Load and display the background image
    ax_bg = axes(fig, 'Position', [0, 0, 1, 1]);
    
    bgImg=imshow(imresize(imread('bg4.jpg'), [NaN, fig.Position(4)]), 'Parent', ax_bg);
    
    
    

% Set the axes to be invisible so it doesn't affect interaction with other components
ax_bg.Visible = 'off';

    % Create Axes for displaying images with adjusted positions
    ax1 = axes(fig, 'Position', [0.3, 0.65, 0.25, 0.25]);
    ax3 = axes(fig, 'Position', [0.3, 0.35, 0.25, 0.25]);
    ax5 = axes(fig, 'Position', [0.3, 0.05, 0.25, 0.25]);
    ax2 = axes(fig, 'Position', [0.67, 0.65, 0.25, 0.25]);
    ax4 = axes(fig, 'Position', [0.67, 0.35, 0.25, 0.25]);
    ax6 = axes(fig, 'Position', [0.67, 0.05, 0.25, 0.25]);
    
    % Initialize variables
    a = []; % Original image
    b = []; % Processed image
    d = []; % Tumor binary mask
    k = []; % Tumor outline

    % Create Buttons 
    browseBtn = uibutton(fig, 'Text', 'Browse', 'Position', [100, 890, 160, 50], ...
    'ButtonPushedFcn', @(btn, event) browseCallback(), 'BackgroundColor',[0.18, 0.31, 0.31], ...
    'FontColor', [1, 1, 1], 'FontSize', 20); 
filterBtn = uibutton(fig, 'Text', 'Filtering', 'Position', [100, 760, 160, 50], ...
    'ButtonPushedFcn', @(btn, event) filterCallback(), 'BackgroundColor',[0.18, 0.31, 0.31], ...
    'FontColor', [1, 1, 1], 'FontSize', 20); 

tumorAloneBtn = uibutton(fig, 'Text', 'Tumor Alone', 'Position', [100, 630, 160, 50], ...
    'ButtonPushedFcn', @(btn, event) tumorAloneCallback(), 'BackgroundColor',[0.18, 0.31, 0.31], ...
    'FontColor', [1, 1, 1], 'FontSize', 20); 

boundingBoxBtn = uibutton(fig, 'Text', 'Bounding Box', 'Position', [100, 500, 160, 50], ...
    'ButtonPushedFcn', @(btn, event) boundingBoxCallback(), 'BackgroundColor',[0.18, 0.31, 0.31], ...
    'FontColor', [1, 1, 1], 'FontSize', 20); 
tumorOutlineBtn = uibutton(fig, 'Text', 'Tumor Outline', 'Position', [100, 370, 160, 50], ...
    'ButtonPushedFcn', @(btn, event) tumorOutlineCallback(), 'BackgroundColor',[0.18, 0.31, 0.31], ...
    'FontColor', [1, 1, 1], 'FontSize', 20); 

locationBtn = uibutton(fig, 'Text', 'Location', 'Position', [100, 240, 160, 50], ...
    'ButtonPushedFcn', @(btn, event) locationCallback(), 'BackgroundColor',[0.18, 0.31, 0.31], ...
    'FontColor', [1, 1, 1], 'FontSize', 20);
tumorCountLabel = uilabel(fig, 'Position', [100, 110, 160, 50], 'Text', ' Tumors Found:0', ...
    'BackgroundColor',[0.18, 0.31, 0.31], 'FontColor', [1, 1, 1], 'FontSize', 20);

% --- Browse Button Callback
    function browseCallback()
        [I, path] = uigetfile('*.*', 'Select an input image');
        if isequal(I, 0) || isequal(path, 0)
            disp('User pressed cancel');
        else
            str = strcat(path, I);
            a = imread(str);
            imshow(a, 'Parent', ax1);
        end
    end

    % --- Filtering Button Callback
    
function filterCallback()
    if isempty(a)
        msgbox('Please load an image first!', 'Error', 'error');
        return;
    end
    if size(a, 3) > 1
        grayscaleImage = rgb2gray(a); 
    else
        grayscaleImage = a;     end
    f = imdiffusefilt(grayscaleImage);
    inp = uint8(f);
    inp = imresize(inp, [256, 256]);
    
    imshow(inp, 'Parent', ax2);
    b = inp; 
end


    % --- Tumor Alone Button Callback
    function tumorAloneCallback()
        sout = b;
        sout = imbinarize(sout, 0.7);
        label = bwlabel(sout);
        stats = regionprops(logical(sout), 'Solidity', 'Area', 'BoundingBox');
        density = [stats.Solidity];
        area = [stats.Area];
        high_dense_area = density > 0.6;
        max_area = max(area(high_dense_area));
        tumor_label = find(area == max_area);
        tumor = ismember(label, tumor_label);
        if max_area > 100
            imshow(tumor, 'Parent', ax3);
            d = tumor;
            % Count the number of tumors
            numTumors = sum(area > 100); % Adjust the threshold as necessary
            tumorCountLabel.Text = ['Tumors Found: ', num2str(numTumors)];
        else
            msgbox('No Tumor!!', 'Status');
            return;
        end
    end
   
     % --- Bounding box Button Callback
     function boundingBoxCallback()
    if isempty(b)
        % Ensure the processed image exists
        msgbox('Please process the image first!', 'Error', 'error');
        return;
    end

    % Perform binarization
    sout1 = imbinarize(b, 0.7);

    % Perform morphological operation
    label = bwlabel(sout1);
    stats = regionprops(logical(sout1), 'Solidity', 'Area', 'BoundingBox');
    density = [stats.Solidity];
    area = [stats.Area];

    % Find the tumor region
    high_dense_area = density > 0.6; % Areas with >60% solidity
    max_area = max(area(high_dense_area));
    tumor_label = find(area == max_area);

    if ~isempty(tumor_label)
        % Extract bounding box of the detected tumor
        box = stats(tumor_label);
        wantedBox = box.BoundingBox;

        % Display the image and bounding box on GUI axes
        imshow(b, 'Parent', ax4); % Ensure image is displayed on ax4
        hold(ax4, 'on');          % Hold current plot on ax4
        rectangle(ax4, 'Position', wantedBox, 'EdgeColor', 'g', 'LineWidth', 2); % Add bounding box
        hold(ax4, 'off');         % Release hold for ax4

        % Update GUI label with bounding box dimensions
        boundingBoxLabel.Text = sprintf('Bounding Box: [%.2f, %.2f, %.2f, %.2f]', ...
                                        wantedBox(1), wantedBox(2), wantedBox(3), wantedBox(4));
    else
        % No tumor detected
        msgbox('No Tumor Found!', 'Bounding Box Status', 'warn');
    end
end




    % --- Tumor Outline Button Callback
    function tumorOutlineCallback()
        E = d;
        filledImage = imfill(E, 'holes');
        se = strel('square', 11);
        erodedImage = imerode(filledImage, se);
        tumorOutline = E;
        tumorOutline(erodedImage) = 0;
        imshow(tumorOutline, 'Parent', ax5);
        k = tumorOutline;
    end

    % --- Location Button Callback
    function locationCallback()
        new = b;
        Ou = k;
        rgb = new(:, :, [1 1 1]);
        red = rgb(:, :, 1);
        red(Ou) = 255;
        green = rgb(:, :, 2);
        green(Ou) = 0;
        blue = rgb(:, :, 3);
        blue(Ou) = 0;
        tumorOutlineInserted = cat(3, red, green, blue);
        imshow(tumorOutlineInserted, 'Parent', ax6);
    end
end


