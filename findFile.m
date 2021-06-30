function [red_data, red_files, red_path, blue_data, blue_files, blue_path, num_imgs] = findFile(folder, csvFile, selected)

%--------------------------------------------------------------------------
% Build relative file path
%--------------------------------------------------------------------------

red_folder = 'red-tiff/';
blue_folder = 'blue-tiff/';

red_path = strcat(folder, red_folder);
blue_path = strcat(folder, blue_folder);

%---load csv data----------------------------------------------------------
csvRead = strcat(folder, csvFile);
T = readtable(csvRead, 'Delimiter',',');
% T(end, :) = [];
Tend = find(isnan(T.Index),1);
T = T(1:Tend-1,1:15);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Define table info
%--------------------------------------------------------------------------
nameID = T.Index;
red_names = T.red_file_names;
blue_names = T.blue_file_names;
sample = T.sample;
cam = T.camera;
fileNum = T.fileNum;
secs = T.secs;
cyCount = T.cyCount;
cyOff = T.cyOff;

%--------------------------------------------------------------------------
num_imgs = length(selected);
%--------------------------------------------------------------------------
if selected == 0
    % select all files
    red_files = red_names;
    blue_files = blue_names;
    
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