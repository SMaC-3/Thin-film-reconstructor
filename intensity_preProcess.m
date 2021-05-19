% close all; clear all

format bank
%--------------------------------------------------------------------------
% Select b/g subtracted .tiff image files for each colour for which intensity
% will be extracted.
%--------------------------------------------------------------------------


folder = '/Users/jkin0004/Documents/PhD_local/3wtCNC_run5/'; 
csvFile = '3wtCNC_run5_TimeStamps.csv';



selected = [170:700];

[red_data, red_files, red_path, blue_data, blue_files, blue_path, num_imgs] = findFile(folder, csvFile, selected);

%[red_data, red_files, red_path, blue_data, blue_files, blue_path, num_imgs] = intensity_selectFiles();

% red_files = {'researchUpdate/red_TX100-1-00350.tiff'};
% blue_files = {'researchUpdate/blue_TX100-1-00350.tiff'};
% num_imgs = 1;
% red_data = {imread(red_files{1})};
% blue_data = {imread(blue_files{1})};

houghFile = input('Select index of red file to be used for Hough transform: ');

img_data = red_data{houghFile}; % Use this one for Hough transform
figure(1)
imshow(img_data)

%--------------------------------------------------------------------------
% Settings for circular Hough transform. Want same center to be used for
% all radial intensity averaging, so perform for one image then set
% constant
%--------------------------------------------------------------------------

% [center, radius] = intensity_houghTransform(img_data);
center = [261.47        ,254.98];
radius = [63.73];

figure(1)
hold on
imshow(img_data)
viscircles(center, radius);
scatter(center(1,1), center(1,2),100,'x', 'red')
hold off

save = 1;


if save == 1

if ~exist(strcat(red_path, 'red-1D-int'),'dir')
    mkdir(red_path, 'red-1D-int');
end

if ~exist(strcat(blue_path, 'blue-1D-int'),'dir')
    mkdir(blue_path, 'blue-1D-int');
end

end

tic
% if isempty(gcp('nocreate'))
%     parpool
% end

parfor ii = 1:num_imgs
    red_img = red_data{ii};
    blue_img = blue_data{ii};
    red_file = red_files{ii};
    blue_file = blue_files{ii};
    [pix_red, red_int, pix_blue, blue_int] = preProcess(red_img, blue_img,...
        red_file, blue_file, red_path, blue_path, center, save);
end    
toc

% delete(gcp('nocreate'))


function [pix_red, red_int, pix_blue, blue_int] = preProcess(red_img, blue_img, red_file, blue_file, red_path, blue_path, center,save)

%--------------------------------------------------------------------------
% Perform radial intensity average for all data using above center value.
%--------------------------------------------------------------------------
ang_min = 170; % angle in degrees
ang_max = 340;
r_max = 250;
% nbs = r_max;
nbs = round(0.75*r_max);

[pix_red, red_int, r_max_red] = intensity_radialAverage(red_img,...
    center, ang_min, ang_max, r_max, nbs);
[pix_blue, blue_int, r_max_blue] = intensity_radialAverage(blue_img,...
    center, ang_min, ang_max, r_max, nbs);

pixels_mm = 1792/2; % Conversion from 2048 x 2048 image at 10x magnification -- need to divide by 2
pixels_um = pixels_mm/1000;

radius_red = pix_red/pixels_um;
radius_blue = pix_blue/pixels_um;

% figure(3)
% plot(pix_red, red_int, 'red', 'LineWidth', 2)
% hold on
% plot(pix_blue, blue_int, 'blue', 'LineWidth', 2)
% hold off

if save == 1
%--------------------------------------------------------------------------
%General intensity info
%-------------------------------------------------------------------------- 

    convert = {'Conversion factor from pixels to micro-meter (pixels/micro meter): ',num2str(pixels_um),''};
    hough = {'Circular Hough transform center (pixels): ', num2str(center),''};
    radAve = {'Max radius used for radial averaging: ', strcat('pixels: ',num2str(r_max)),strcat('radius (micro meter): ',num2str(r_max/pixels_um));...
        'Angular integration limits: ', num2str([ang_min, ang_max]),'';...
        'Num of bins ', num2str(nbs),''};
    
%--------------------------------------------------------------------------
%Save red intensity data
%--------------------------------------------------------------------------    
    
    name = '_int_1D';
    type = '.txt';
    full_red = strcat(red_path, 'red-1D-int/',red_file(1:end-5), name, type);
    
    varNames = {'pixels', 'radius', 'raw_intensity'};
    dataTable = table(round(pix_red(1:end-1),3), round(radius_red(1:end-1),3), round(red_int(1:end-1),3), 'VariableNames', varNames);
    cellTab = table2cell(dataTable);
    cellSave = [convert; hough; radAve; {'','',''};...
        {'Radially averaged intensity','',''};varNames;cellTab];
    
    writecell(cellSave, full_red, 'Delimiter', '\t');
    
    
%--------------------------------------------------------------------------
%Save blue intensity data
%--------------------------------------------------------------------------    
    
    name = '_int_1D';
    type = '.txt';
    full_blue = strcat(blue_path, 'blue-1D-int/',blue_file(1:end-5), name, type);
    
    varNames = {'pixels', 'radius', 'raw_intensity'};
    dataTable = table(round(pix_blue(1:end-1),3), round(radius_blue(1:end-1),3), round(blue_int(1:end-1),3), 'VariableNames', varNames);
    cellTab = table2cell(dataTable);
    cellSave = [convert; hough; radAve; {'','',''};...
        {'Radially averaged intensity','',''};varNames;cellTab];
    
    writecell(cellSave, full_blue, 'Delimiter', '\t');
end
end


