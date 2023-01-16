format bank
%--------------------------------------------------------------------------
% Define folder and csv file for data import
%--------------------------------------------------------------------------

folder = "/Volumes/T7/Thin films/MultiCam/SDS/240mM_SDS/240mM_SDS_run20/";
csvFile = "240mM_SDS_run20_TimeStamps.csv";

save_check = 1;

% folder_parts = split(folder, '/');
% path_build = fullfile('/',folder_parts{2:end-2}, '/');

% delta T = fps * delata img number

% folder_to_save = '1st_rip';
% folder_to_save = '2nd_rip';
folder_to_save = '3rd_rip';
% folder_to_save = '4th_rip';

selected = [235:5:335]; 

if save_check == 1
 
if ~exist(strcat(folder, folder_to_save),'dir')
    mkdir(folder, folder_to_save);
end
end

copyFile(folder, csvFile, selected,folder_to_save);

function copyFile(folder, csvFile, selected, folder_to_save)
%RELATIVE FILE PATH
% folder = '/Volumes/Z_MS-DOS/Thin films/MultiCam/CNC/6wtCNC/6wtCNC_run2/'; 
img_folder = strcat(folder_to_save,'/');
img_path = strcat(folder, img_folder);

% red_folder = 'red-tiff/';
% blue_folder = 'blue-tiff/';
rgb_folder = 'rgb-tiff/';

% red_path = strcat(folder, red_folder);
% blue_path = strcat(folder, blue_folder);
rgb_path = strcat(folder, rgb_folder);

% csvFile = '6wtCNC_run2_timestamps.csv';
csvRead = strcat(folder, csvFile);
T = readtable(csvRead, 'Delimiter',',');
% T(end, :) = [];

nameID = T.Index;
red_names = T.red_file_names;
blue_names = T.blue_file_names;

rgb_names = cell(max(size(red_names)), 1);

for i =1:max(size(red_names))
   rgb_names{i} = red_names{i}(5:end); 
end

num_imgs = length(selected);

if selected == 0
    filename = names;
else
    
    for i = 1:length(selected)
        choose(i) = find(nameID==selected(i));
    end
    %     red_files = {red_names{choose}};
    %     blue_files = {blue_names{choose}};
    rgb_files = {rgb_names{choose}}.';
end

% red_data = cell(num_imgs,1);
% blue_data = cell(num_imgs,1);

% for i =1:num_imgs
%    red_data{i} = imread(strcat(red_path, red_files{i})); 
%    blue_data{i} = imread(strcat(blue_path, blue_files{i}));
% end

if isempty(gcp('nocreate'))
    parpool;
end

tic
parfor i = 1:length(selected)
    
%     copyfile(strcat(red_path,red_files{i}), img_path);
%     copyfile(strcat(blue_path,blue_files{i}), img_path);
      copyfile(strcat(rgb_path,rgb_files{i}), img_path);
%       ima = imread(strcat(rgb_path,rgb_files{i}))
%       imwrite(ima, strcat(img_path,rgb_files{i}(1:end-4),"jpg"),"BitDepth",16);
end
toc

end