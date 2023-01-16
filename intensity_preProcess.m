% Code written by Joshua P. King, SMaCLab, Monash University, Australia
% Last updated: August, 2022

%   ________  ___      ___       __       ______   ___            __       _______   
%  /"       )|"  \    /"  |     /""\     /" _  "\ |"  |          /""\     |   _  "\  
% (:   \___/  \   \  //   |    /    \   (: ( \___)||  |         /    \    (. |_)  :) 
%  \___  \    /\\  \/.    |   /' /\  \   \/ \     |:  |        /' /\  \   |:     \/  
%   __/  \\  |: \.        |  //  __'  \  //  \ _   \  |___    //  __'  \  (|  _  \\  
%  /" \   :) |.  \    /:  | /   /  \\  \(:   _) \ ( \_|:  \  /   /  \\  \ |: |_)  :) 
% (_______/  |___|\__/|___|(___/    \___)\_______) \_______)(___/    \___)(_______/  
                                                                                   

% SMaCLab website can be found here:
% https://sites.google.com/view/smaclab

%{
INTENSITY_PREPROCESS Radially  averages image files into intensity vs radius
for further processing and film reconstruction with intensity_dataProcessor 

-------------------------------------------------------------
Info about user input settings
-------------------------------------------------------------

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 
blue-tiff, red-tiff, timestamp csv are created using IMGCONVERTER script
Please convert .raw files using IMGCONVERTER script before running INTENSITY_PREPROCESS

After running INTENSITY_PREPROCESS, use INTENSITY_DATAPROCESSOR to
reduce/normalise intensity data and reconstruct film profile
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 

Folder --> path to main branch that should contain sub-directories
blue-tiff and red-tiff

csvFile --> csv file containing index, blue and red filenames, timestamps

selected --> list of index values corresponding to red and blue image 
files that will be radially averaged

save_check --> set to 1 in order to save radially averaged data, any
other value and the data will not be saved

User can set angle bounds between which data will be radially averaged 
(ie. ang_min, ang_max)
An angle of 0 degrees is defined as positive x-axis and angle increases
clock-wise. Counter clock-wise direction is possible by providing a
negative angle 
-------------------------------------------------------------

Functions used in this script:

1) findFile
2) intensity_houghTransform
3) preProcess
    3a) intensity_radialAverage
-------------------------------------------------------------
%}

% close all; clear all
format default

%% Input settings - USER TO MODIFY
%---Main branch directory info--------------------------------
clc
close all
clear all

tic
folder = "/Volumes/T7/Thin films/MultiCam/CNC_dialysed/0p95wtCNC/0p95wtCNC_run2/";
csvFile = "0p95wtCNC_run2_TimeStamps.csv";

red_img_folder = "red-flatField-tiff";
blue_img_folder = "blue-flatField-tiff";
red_img_path = fullfile(folder, red_img_folder);
blue_img_path = fullfile(folder, blue_img_folder);
%-------------------------------------------------------------

%---Index of files to be procesed-----------------------------
% selected = [5:5:900];
selected = 3900;
save_check = 1; % 1 = save info, 0 = do not save info 
save_descriptor = "-flatField";
%-------------------------------------------------------------

%---Define angle limits for data reduction--------------------
ang_min = 0;
ang_max = 360;

%-------------------------------------------------------------
% END Input settings
%-------------------------------------------------------------

% Load path & name info
[blue_data, blue_files, ~]...
    = findFile(folder, blue_img_path, csvFile, selected, "blue");
[red_data, red_files, num_imgs]...
    = findFile(folder, red_img_path, csvFile, selected, "red");

%-------------------------------------------------------------
toc
%% Circular Hough transform
%{ 
Want same center to be used for all radial intensity averaging, 
so perform for one image then set constant
%}
houghFile = input('Select index of red file to be used for Hough transform: ');
img_data = red_data{houghFile}; % Use this one for Hough transform
figure(1)
imshow(img_data)

[center, radius] = intensity_houghTransform(img_data);

%-------------------------------------------------------------

figure(1)
hold on
imshow(img_data)
viscircles(center, radius);
scatter(center(1,1), center(1,2),100,'x', 'red')
hold off

%% Radial average
%---Prepare for loop------------------------------------------
tic
if isempty(gcp('nocreate'))
    parpool;
end

%---Use for single segment reduction--------------------------
parfor ii = 1:num_imgs
    red_img = red_data{ii};
    blue_img = blue_data{ii};
    red_file = red_files{ii};
    blue_file = blue_files{ii};
    [pix_red, red_int, pix_blue, blue_int] =...
        preProcess(ang_min,ang_max,...
        red_img, blue_img, red_file, blue_file,...
        folder, center, save_check, save_descriptor);
end  
toc

% delete(gcp('nocreate'))
%-------------------------------------------------------------
function [pix_red, red_int, pix_blue, blue_int] = preProcess(ang_min, ang_max,...
    red_img, blue_img, red_file, blue_file, folder, center,save, save_descriptor)

%-------------------------------------------------------------
% Perform radial intensity average for all data using above center value.
%-------------------------------------------------------------
r_max = 250;
nbs = r_max;


% Quantum efficiency correction parameters

% C1 = 885.1984;
% C2 = 57.2775;
% C3 = 1.0163e+03;
% C4 = 57.8230;


[pix_red, red_int, r_max_red] = intensity_radialAverage(red_img,...
    center, ang_min, ang_max, r_max, nbs);
[pix_blue, blue_int, r_max_blue] = intensity_radialAverage(blue_img,...
    center, ang_min, ang_max, r_max, nbs);

% blue_rrp_scale = (red_int - (blue_int*C1/C4))/(C2-(C3*C1/C4));
% red_rrp_scale = (red_int - blue_rrp_scale*C2)/C1;
% red_int_cor = red_int-(blue_rrp_scale*C2);
% blue_int_cor = blue_int - (red_rrp_scale*C4);


pixels_mm = 1792/2; 
% Conversion from 2048 x 2048 image at 10x magnification -- need to divide by 2
pixels_um = pixels_mm/1000;

radius_red = pix_red/pixels_um;
radius_blue = pix_blue/pixels_um;

% figure(3)
% plot(pix_red, red_int, 'red', 'LineWidth', 2)
% hold on
% plot(pix_blue, blue_int, 'blue', 'LineWidth', 2)
% hold off

%-------------------------------------------------------------
% Save radially averaged data to txt file
%-------------------------------------------------------------

if save == 1
    
    % Define save folders here b/c ang_min/_max change if looping through a range of segments
    red_folder = strcat('red-int-sectors/red-1D-int-',...
        num2str(ang_min),'-',num2str(ang_max),save_descriptor);
    blue_folder = strcat('blue-int-sectors/blue-1D-int-',...
        num2str(ang_min),'-',num2str(ang_max),save_descriptor);
    
    if ~exist(strcat(folder, red_folder),'dir')
        mkdir(folder, red_folder);
    end
    
    if ~exist(strcat(folder, blue_folder),'dir')
        mkdir(folder, blue_folder);
    end

%--------------------------------------------------------------------------
% General intensity info
%-------------------------------------------------------------------------- 

    convert = {'Conversion factor from pixels to micro-meter (pixels/micro meter): ',num2str(pixels_um),''};
    hough = {'Circular Hough transform center (pixels): ', num2str(center),''};
    radAve = {'Max radius used for radial averaging: ', strcat('pixels: ',num2str(r_max)),strcat('radius (micro meter): ',num2str(r_max/pixels_um));...
        'Angular integration limits: ', num2str([ang_min, ang_max]),'';...
        'Num of bins ', num2str(nbs),''};
    
%--------------------------------------------------------------------------
% Save red intensity data
%--------------------------------------------------------------------------    
    
%     name = '_int_1D';
    type = '.txt';
    
    red_file_split = split(red_file, '-');
    red_file_new = strcat(red_file_split{1},'-',red_file_split{2},'-',...
        red_file_split{3},'-','int-1D-',num2str(ang_min),'-',num2str(ang_max),type);
    
%     full_red = strcat(folder, red_folder,'/',red_file(1:end-5), name, type);
    full_red = strcat(folder, red_folder,'/',red_file_new);
    
    varNames = {'pixels', 'radius', 'raw_intensity'};
    dataTable = table(round(pix_red(1:end-1),3), round(radius_red(1:end-1),3), round(red_int(1:end-1),3), 'VariableNames', varNames);
    cellTab = table2cell(dataTable);
    cellSave = [convert; hough; radAve; {'','',''};...
        {'Radially averaged intensity','',''};varNames;cellTab];
    
    writecell(cellSave, full_red, 'Delimiter', '\t');
    
    
%--------------------------------------------------------------------------
% Save blue intensity data
%--------------------------------------------------------------------------    
    
%     name = '_int_1D';
%     type = '.txt';
    
    blue_file_split = split(blue_file, '-');
    blue_file_new = strcat(blue_file_split{1},'-',blue_file_split{2},'-',...
        blue_file_split{3},'-','int-1D-',num2str(ang_min),'-',num2str(ang_max),type);
    
    full_blue = strcat(folder, blue_folder,'/',blue_file_new);
    
    varNames = {'pixels', 'radius', 'raw_intensity'};
    dataTable = table(round(pix_blue(1:end-1),3), round(radius_blue(1:end-1),3), round(blue_int(1:end-1),3), 'VariableNames', varNames);
    cellTab = table2cell(dataTable);
    cellSave = [convert; hough; radAve; {'','',''};...
        {'Radially averaged intensity','',''};varNames;cellTab];
              
    writecell(cellSave, full_blue, 'Delimiter', '\t');
end
end


