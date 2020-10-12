function [red_data, blue_data, num_imgs] = intensity_selectFiles()

disp('Select red image files');
[red_files, red_path] = uigetfile('*.tiff',...
    'Select the subtracted red-files', 'MultiSelect','on');
disp('Select blue image files');
[blue_files, blue_path] = uigetfile('*.tiff',...
    'Select the subtracted blue-files', 'MultiSelect','on');

if iscell(red_files) == 0 
    red_files = {red_files};
end

if iscell(blue_files) == 0 
    blue_files = {blue_files};
end

% Check red and blue files

if length(red_files) ~= length(blue_files)
    error('Number of red and blue images does not match');
else
    disp(['red' red_files; 'blue' blue_files]);
    check_files = input('Have the correct corresponding files been selected? Y/N [Y]: ','s');
    if isempty(check_files) ~= 1 | check_files ~= 'Y' | check_files ~= 'y'
        error('Failed to verify that correct corresponding files had been selected');
    end     
end

num_imgs = length(red_files);

red_data = cell(num_imgs,1);
blue_data = cell(num_imgs,1);

for i =1:num_imgs
   red_data{i} = imread(red_files{i}); 
   blue_data{i} = imread(blue_files{i});
end
end

