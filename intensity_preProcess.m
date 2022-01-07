% close all; clear all

format bank
%--------------------------------------------------------------------------
% Input settings - USER TO MODIFY
%--------------------------------------------------------------------------

%---Main branch directory info---------------------------------------------
%
% conc = '';
% sample = 'Ethylene_glycol';
% abbre = 'EG';
% expNum = 'run2';
% branch = '/Volumes/ZIGGY/Thin films/MultiCam/';

% folder = fullfile(branch, sample, strcat(conc,abbre),...
%     strcat(conc,abbre,'_',expNum,'/'));
% folder = fullfile(branch, sample,...
%     strcat(conc,abbre,'_',expNum,'/')); 
% csvFile = strcat(conc, abbre,'_',expNum,'_TimeStamps.csv');
folder = "/Volumes/ZIGGY/Thin films/MultiCam/CNC_dialysed/1p9wtCNC/1p9wtCNC_run4/";
csvFile = "1p9wtCNC_run4_TimeStamps.csv";

%-------------------------------------------------------------------------

%---Index of files to be procesed------------------------------------------
selected = [400:10:3360];
% selected = flip(selected);
save_check = 1; % 1 = save info, 0 = do not save info 
%--------------------------------------------------------------------------

%---Define angle limits for data reduction---------------------------------
ang_min = 0;
ang_max = 360;

sectWidth = 120; 
numSect = 360/sectWidth;
sectBounds = zeros(numSect+1,1);
sectBounds(2:end) = sectWidth*[1:numSect].';
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% END Input settings
%--------------------------------------------------------------------------

%---Load path & name info--------------------------------------------------
[red_data, red_files, red_path, blue_data, blue_files, blue_path, num_imgs]...
    = findFile(folder, csvFile, selected);

% folder_parts = split(folder, '/');
% path_build = fullfile('/',folder_parts{2:end-2}, '/');
%[red_data, red_files, red_path, blue_data, blue_files, blue_path, num_imgs] = intensity_selectFiles();

% red_files = {'researchUpdate/red_TX100-1-00350.tiff'};
% blue_files = {'researchUpdate/blue_TX100-1-00350.tiff'};
% num_imgs = 1;
% red_data = {imread(red_files{1})};
% blue_data = {imread(blue_files{1})};
%--------------------------------------------------------------------------

%---Settings for circular Hough transform----------------------------------
% Want same center to be used for all radial intensity averaging, 
% so perform for one image then set constant
%--------------------------------------------------------------------------
houghFile = input('Select index of red file to be used for Hough transform: ');
img_data = red_data{houghFile}; % Use this one for Hough transform
figure(1)
imshow(img_data)

[center, radius] = intensity_houghTransform(img_data);
% center = [261, 255];
% radius = [0 ];
%--------------------------------------------------------------------------

figure(1)
hold on
imshow(img_data)
viscircles(center, radius);
scatter(center(1,1), center(1,2),100,'x', 'red')
hold off

% if save_check == 1
% 
% if ~exist(strcat(folder, 'red-1D-int'),'dir')
%     mkdir(folder, 'red-1D-int');
% end
% 
% if ~exist(strcat(folder, 'blue-1D-int'),'dir')
%     mkdir(folder, 'blue-1D-int');
% end
% 
% end

%---Prepare for loop-------------------------------------------------------
tic
if isempty(gcp('nocreate'))
    parpool
end

%---Use for single segment reduction---------------------------------------
parfor ii = 1:num_imgs
    red_img = red_data{ii};
    blue_img = blue_data{ii};
    red_file = red_files{ii};
    blue_file = blue_files{ii};
    [pix_red, red_int, pix_blue, blue_int] = preProcess(ang_min,ang_max,red_img, blue_img,...
        red_file, blue_file, folder, center, save_check);
end  

%---Use for multiple segment reduction-------------------------------------
% for ii = 1:num_imgs
%     for i = 1:numSect
%         red_img = red_data{ii};
%         blue_img = blue_data{ii};
%         red_file = red_files{ii};
%         blue_file = blue_files{ii};
%         ang_min = sectBounds(i);
%         ang_max = sectBounds(i+1); 
%         [pix_red, red_int, pix_blue, blue_int] = preProcess(ang_min, ang_max,...
%             red_img, blue_img,red_file, blue_file, folder, center, save_check);
%         figure(2)
%         hold on
% %         plot(pix_blue, (blue_int-min(blue_int(1:100)))./...
% %             (max(blue_int(1:100)) - min(blue_int(1:100))) )
% %         plot(pix_red, (red_int-min(red_int(1:100)))./...
% %             (max(red_int(1:100)) - min(red_int(1:100))))
%         plot(pix_red, red_int)
%     end
% end  

toc

% delete(gcp('nocreate'))
%--------------------------------------------------------------------------

function [pix_red, red_int, pix_blue, blue_int] = preProcess(ang_min, ang_max,...
    red_img, blue_img, red_file, blue_file, folder, center,save)

%--------------------------------------------------------------------------
% Perform radial intensity average for all data using above center value.
%--------------------------------------------------------------------------
% ang_min = 160; % angle in degree
% ang_max = 270;
r_max = 250;
nbs = r_max;
% nbs = round(2*r_max);

[pix_red, red_int, r_max_red] = intensity_radialAverage(red_img,...
    center, ang_min, ang_max, r_max, nbs);
[pix_blue, blue_int, r_max_blue] = intensity_radialAverage(blue_img,...
    center, ang_min, ang_max, r_max, nbs);

sectWidth = 15; 
numSect = 360/sectWidth;
sectBounds = zeros(numSect+1,1);
sectBounds(2:end) = sectWidth*[1:numSect].';

% [pix_red, red_int, r_max_red] = intensity_radialAverage_slices(red_img,...
%     center, sectBounds, r_max, nbs);
% [pix_blue, blue_int, r_max_blue] = intensity_radialAverage_slices(blue_img,...
%     center, sectBounds, r_max, nbs);



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
    
    % Define save folders here b/c ang_min/_max change if looping through a range of segments
    red_folder = strcat('red-int-sectors/red-1D-int-',num2str(ang_min),'-',num2str(ang_max));
    blue_folder = strcat('blue-int-sectors/blue-1D-int-',num2str(ang_min),'-',num2str(ang_max));
    
    if ~exist(strcat(folder, red_folder),'dir')
        mkdir(folder, red_folder);
    end
    
    if ~exist(strcat(folder, blue_folder),'dir')
        mkdir(folder, blue_folder);
    end
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
%Save blue intensity data
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


