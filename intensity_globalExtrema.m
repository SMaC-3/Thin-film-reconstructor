function [red_int_min, red_int_max, blue_int_min, blue_int_max] =...
    intensity_globalExtrema(folder, red_dir, blue_dir)
%--------------------------------------------------------------------------
% Info about user input settings
%--------------------------------------------------------------------------

%close all
%clearvars -except folder
format bank

%--------------------------------------------------------------------------
% Input settings - USER TO MODIFY
%--------------------------------------------------------------------------

%---Index of files to be procesed------------------------------------------
% save_check = 0; % 1 = save info, 0 = do not save info 
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
% folder = "/Volumes/T7/Thin films/MultiCam/SDS/100mM_SDS/100mM_SDS_globalExtrema_run2/";
% csvFile = "150mM_SDS_run2_TimeStamps.csv";
% selected = 1:1200;

% red_dir = "red-int-sectors/red-1D-int-0-360-surfFit-WBcor/";
% red_img_path = fullfile(folder,"red-tiff/");
red_path = fullfile(folder, red_dir);

% blue_dir = "blue-int-sectors/blue-1D-int-0-360-surfFit-WBcor/";
% blue_img_path = fullfile(folder,"blue-tiff/");
blue_path = fullfile(folder, blue_dir);

%--------------------------------------------------------------------------
% END Input settings
%--------------------------------------------------------------------------

if ~exist(folder,'dir')
    folder = pwd;
end

%--------------------------------------------------------------------------
% Find global max & min for blue and red intensity data
%--------------------------------------------------------------------------

% [red_data, red_files, red_path_imgs, blue_data, blue_files, blue_path_imgs, num_imgs] =...
% findFile(folder, csvFile, selected);
% 
% [red_max, red_max_I] =...
%     max(double(cell2mat(cellfun(@max,cellfun(@max, red_data,'UniformOutput',false),'UniformOutput',false))));


% Make sure that only actual red intensity data is used
red_files_struct = dir(fullfile(red_path, '*.txt'));
red_Allfiles = struct2cell(red_files_struct).';
red_Allfiles = red_Allfiles(:,1);
red_check = zeros(size(red_Allfiles));

for j = 1:max(size(red_Allfiles))
    check_val = red_Allfiles{j}(1:3);
    if check_val=='red'
        red_check(j) = 1;
    else
        red_check(j) = 0;
    end
end

red_check = logical(red_check);
red_Allfiles = red_Allfiles(red_check);

% Make sure that only actual blue intensity data is used
blue_files_struct = dir(fullfile(blue_path, '*.txt'));
blue_Allfiles = struct2cell(blue_files_struct).';
blue_Allfiles = blue_Allfiles(:,1);
blue_check = zeros(size(blue_Allfiles));


for j = 1:max(size(blue_Allfiles))
    check_val = blue_Allfiles{j}(1:4);
    if check_val=='blue'
        blue_check(j) = 1;
    else
        blue_check(j) = 0;
    end
end

blue_check = logical(blue_check);
blue_Allfiles = blue_Allfiles(blue_check);

red_allData = cell(size(red_Allfiles));
blue_allData = cell(size(red_Allfiles));

% Only use data within dimple region, so set this as cutoff radius

T_red = importdata(strcat(red_path, red_Allfiles{end}),'\t',8);
radius = T_red.data(:,2);
red_int = T_red.data(:,3);

% Import blue data
T_blue = importdata(strcat(blue_path, blue_Allfiles{end}),'\t',8);
blue_int = T_blue.data(:,3);

figure(1)
plot(radius,red_int,'LineWidth',1.5,'Color','red')
hold on
plot(radius,blue_int,'LineWidth',1.5,'Color','blue')
hold off

trim = 'Enter upper bound for data: ';
cutoff = input(trim);
while isempty(cutoff)
    cutoff = input(trim);
end

[~, I_cutoff] = min(abs(radius - cutoff));

red_max_dimp_ind = I_cutoff;
blue_max_dimp_ind = I_cutoff;

lb_cutoff = 5;

% Import all red and blue intensity data
for i = 1:max(size(red_Allfiles))
    T_red = importdata(strcat(red_path, red_Allfiles{i}),'\t',8);
    red_allData{i} = T_red.data(lb_cutoff:red_max_dimp_ind,3);
    T_blue = importdata(strcat(blue_path, blue_Allfiles{i}),'\t',8);
    blue_allData{i} = T_blue.data(lb_cutoff:blue_max_dimp_ind,3);
end

% Find global maximum and minimum in red and blue data
red_int_max = max(cellfun(@max, red_allData));
blue_int_max = max(cellfun(@max, blue_allData));

red_int_min = min(cellfun(@min, red_allData));
blue_int_min = min(cellfun(@min, blue_allData));

end
