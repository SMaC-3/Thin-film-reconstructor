function [T_metrics] =...
    film_metrics_2D(h_inv_red, norm, radius_circ, center_circ,...
    folder,csvFile, selected, save_check)

lambda = 630;
n1 = 1.33;
factor_red = (4*pi*n1)/lambda; 
%% Determine radius from center of film (as set above)

rows = 512;
cols = rows;

x = 1:rows;
y = x;

[xx, yy] = meshgrid(x,y);
xx = xx - 1;
yy = yy - 1;

radius = sqrt((xx - center_circ(1)).^2 + (yy - center_circ(2)).^2);

% Find points within film radius
log_rad = radius < radius_circ;

% Define conversion factor from pixels to micron

pixels_mm = 1792/2; 
% Conversion from 2048 x 2048 image at 10x magnification -- need to divide by 2
pixels_um = pixels_mm/1000;

% Loop through 2D film data and calculate metrics

rim_annulus = 5; 
offset = 10;
log_rim = radius > (radius_circ - rim_annulus-offset) & radius < radius_circ-offset;

center_rad = 15;
log_center = radius < center_rad;

% Volume, minimum film thickness, center film thickness 

rim_h = zeros(max(size(norm)),1);
center_h = zeros(max(size(norm)),1);
h_ave = zeros(max(size(norm)),1);
dimp_vol = zeros(max(size(norm)),1);

for i = 1:max(size(norm))
%     
%     rim_h(i,1) = mean(h_inv_red{i}(log_rim));
%     center_h(i,1) = mean(h_inv_red{i}(log_center));
%     mean_h(i,1) = mean(h_inv_red{i}(log_rad));
%     dimp_vol(i,1) = sum(h_inv_red{i}(log_rad)/1000)/(pixels_um^2);

    rim_h(i,1) = acos(mean(norm{i}(log_rim)))/factor_red;
    center_h(i,1) = acos(mean(norm{i}(log_center)))/factor_red;
    h_ave(i,1)  = acos(mean(norm{i}(log_rad)))/factor_red;
    dimp_vol(i,1) = (h_ave(i,1)/1000)*pi*(radius_circ/pixels_um)^2;

end

csvRead = strcat(folder,csvFile);
T = readtable(csvRead, 'Delimiter',',');

nameID = T.Index;
timeStamps = T.cumulStamps;
% fileNums = T.fileNum;
all_red_files = T.red_file_names;

[~, choose] = ismember(selected, nameID);

timeStamps_select = timeStamps(choose);
red_files = all_red_files(choose);

T_metrics = table(timeStamps_select, rim_h, center_h,...
    dimp_vol,h_ave,...
    'VariableNames',["Time_stamps_(s)", "Rim_h_(nm)",...
    "Center_h_(nm)",...
    "Dimple_vol_(micron^3)",...
    "Average_h_(nm)"]);

% figure()
% 
% scatter(timeStamps_select,center_h,'filled')
% hold on
% scatter(timeStamps_select,rim_h,'filled')
% yyaxis right
% scatter(timeStamps_select,dimp_vol,'filled')
% 
% lg = legend;
% lg.String = {"Center h", "Rim h", "Dimple volume"};
% lg.Box = 'off';

%%
if save_check == 1
    
    metrics_data_folder = 'thin-films-2D-metrics/';

    if exist(fullfile(folder,metrics_data_folder),"dir") == 0
        mkdir(fullfile(folder,metrics_data_folder));
    end

    metrics_path = fullfile(folder, metrics_data_folder);
    parfor i = 1:max(size(red_files))
        general_info =...
            {'Date/time: ', string(datetime),'', '','';...
            'File: ', red_files{i},'','','';...
            'Center (pixels): ', center_circ(1),...
            center_circ(2), '','';...
            'Radius (pixels): ', num2str(radius_circ),'Radius annulus: ', rim_annulus,'';...
            'Offset :',offset ,'center metrics radius: ',center_rad,'';...
            'Conversion factor (pixels/micron): ', num2str(pixels_um), '','','';...
%             '','','','';...
            'timeStamps','center_h_nm','rim_h_nm','dimp_vol_micron^3', 'average_h_nm'};

        file_name_split = split(red_files{i},'-');
        
        file_name_metrics = strcat(file_name_split{1},'-',...
            file_name_split{2}, '-',file_name_split{3},...
            '-metrics.txt');

        full_metrics = fullfile(metrics_path,...
            file_name_metrics);

        cellSave = [general_info; ...
            {round(timeStamps_select(i),4), round(center_h(i),4),...
            round(rim_h(i),4) , round(dimp_vol(i),8), round(h_ave(i),4)}];
       
        writecell(cellSave, full_metrics, 'Delimiter', '\t');

    end

end