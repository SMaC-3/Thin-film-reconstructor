function [red_data, red_files, red_path, blue_data, blue_files, blue_path, num_imgs] = findFile(folder, csvFile, selected)
%RELATIVE FILE PATH
% folder = '/Volumes/Z_MS-DOS/Thin films/MultiCam/CNC/6wtCNC/6wtCNC_run2/'; 
red_folder = 'red-tiff/';
blue_folder = 'blue-tiff/';

red_path = strcat(folder, red_folder);
blue_path = strcat(folder, blue_folder);

% csvFile = '6wtCNC_run2_timestamps.csv';
csvRead = strcat(folder, csvFile);
T = readtable(csvRead, 'Delimiter',',');
T(end, :) = [];

nameID = T.Index;
red_names = T.red_file_names;
blue_names = T.blue_file_names;

num_imgs = length(selected);

if selected == 0
    filename = names;

else

    for i = 1:length(selected)
    choose(i) = find(nameID==selected(i));
    end
    red_files = {red_names{choose}};
    blue_files = {blue_names{choose}};
end

red_data = cell(num_imgs,1);
blue_data = cell(num_imgs,1);

for i =1:num_imgs
   red_data{i} = imread(strcat(red_path, red_files{i})); 
   blue_data{i} = imread(strcat(blue_path, blue_files{i}));
end

end