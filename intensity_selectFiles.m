function [red_data, red_files, red_path, blue_data, blue_files, blue_path, num_imgs] = intensity_selectFiles()
% intensity_selectFiles.m Loads image data from red and blue channels (from
% debayered images)
%   This function prompts the user to select image files corresponding to
%   red and blue colour channels from previously debayered interferometry
%   images. Files should be in .tiff format. Image file data is then read
%   by the function
%   
%   Inputs:
%       Nill
%   Outputs:
%       red_data: intensity at each pixel for all selected red image files
%       red_files: file paths for all selected red image files
%       blue_data: intensity at each pixel for all selected blue image files
%       blue_files: file paths for all selected blue image files
%       num_imgs: number of images slected per colour channel (eg. at
%       distinct time points)

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
   red_data{i} = imread(strcat(red_path, red_files{i})); 
   blue_data{i} = imread(strcat(blue_path, blue_files{i}));
end
end

