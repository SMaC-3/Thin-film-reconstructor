% Code written by Joshua P. King, SMaCLab, Monash University, Australia
% 2022

%   ________  ___      ___       __       ______   ___            __       _______   
%  /"       )|"  \    /"  |     /""\     /" _  "\ |"  |          /""\     |   _  "\  
% (:   \___/  \   \  //   |    /    \   (: ( \___)||  |         /    \    (. |_)  :) 
%  \___  \    /\\  \/.    |   /' /\  \   \/ \     |:  |        /' /\  \   |:     \/  
%   __/  \\  |: \.        |  //  __'  \  //  \ _   \  |___    //  __'  \  (|  _  \\  
%  /" \   :) |.  \    /:  | /   /  \\  \(:   _) \ ( \_|:  \  /   /  \\  \ |: |_)  :) 
% (_______/  |___|\__/|___|(___/    \___)\_______) \_______)(___/    \___)(_______/  
                                                                                   

% SMaCLab website can be found here:
% https://sites.google.com/view/smaclab

%--------------------------------------------------------------------------

% function [red_data, red_files, blue_data, blue_files, num_imgs] =...
%     findFile(folder, red_path, blue_path, csvFile, selected)
function [img_data, img_files, num_imgs] =...
    findFile(folder, img_path, csvFile, selected, channel)

%--------------------------------------------------------------------------
% FINDFILE read blue and red tiff image data 
 % return data, path, filenames, and number of selected images for further
 % processing
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Build relative file path
%--------------------------------------------------------------------------

% red_folder = '';
% blue_folder = '';

% red_folder = 'red-globalExtrema-tiff/';
% blue_folder = 'blue-globalExtrema-tiff/';

% red_path = strcat(folder, red_folder);
% blue_path = strcat(folder, blue_folder);

%---load csv data----------------------------------------------------------
csvRead = strcat(folder, csvFile);
T = readtable(csvRead, 'Delimiter',',');
% T(end, :) = [];
Tend = find(isnan(T.Index),1);
if ~isempty(Tend)
    T = T(1:Tend-1,1:15);
else
    T = T(1:end,1:15);
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Define table info
%--------------------------------------------------------------------------
nameID = T.Index;
if channel == "red"
    img_names = T.red_file_names;
elseif channel == "blue"
    img_names = T.blue_file_names;
elseif channel == "rgb"
    img_names_red = T.red_file_names;
    img_split = cellfun(@split, split(img_names_red,'red_'));
    img_names = img_split(:,2);
else
    error("colour channel not recognised");
end
% sample = T.sample;
% cam = T.camera;
% fileNum = T.fileNum;
% secs = T.secs;
% cyCount = T.cyCount;
% cyOff = T.cyOff;

%--------------------------------------------------------------------------
num_imgs = length(selected);
%--------------------------------------------------------------------------
if selected == 0
    % select all files
    img_files = img_names;
    
else
    for i = 1:length(selected)
    choose(i) = find(nameID==selected(i));
    end
    img_files = {img_names{choose}};
end

img_data = cell(num_imgs,1);

parfor i =1:num_imgs
   img_data{i} = imread(fullfile(img_path, img_files{i})); 
end

end