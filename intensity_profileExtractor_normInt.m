% close all
clear all
format bank

%--------------------------------------------------------------------------
% Input settings - USER TO MODIFY
%--------------------------------------------------------------------------

%---Index of files to be procesed------------------------------------------
selected = [250];
save_check = 1; % 1 = save info, 0 = do not save info 
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
conc = '4p5wt';
sample = 'CNC';
expNum = 'run10';
branch = '/Volumes/ZIGGY/Thin films/MultiCam/';

data_folder = 'data-normalised/';

folder = fullfile(branch, sample, strcat(conc,sample),...
    strcat(conc,sample,'_',expNum,'/')); 
data_path = strcat(folder, data_folder);

csvFile = strcat(conc,sample,'_',expNum,'_TimeStamps.csv');
%--------------------------------------------------------------------------

% %---define file identifiers------------------------------------------------
% red_fodler_parts = split(red_folder,{'-','/'});
% ang_min = red_fodler_parts{end-2};
% ang_max = red_fodler_parts{end-1};
% name = '-int-1D';
% type = '.txt';
% %--------------------------------------------------------------------------

%---load csv data----------------------------------------------------------
csvRead = strcat(folder, csvFile);
T = readtable(csvRead, 'Delimiter',',');
T(end, :) = [];
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% END user input settings
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

%---Select files manually-------------------------------------
[data_files, data_path] = uigetfile(strcat(data_path,'*.txt'),...
    'Select the subtracted red-files', 'MultiSelect','on');

if iscell(data_files) == 0 
    data_files = {data_files};
end

%--------------------------------------------------------------------------

for ii = 1:size(data_files,2)
    data_file = data_files{ii};
    [dimp_h_blue, dimp_h_red] =...
        intensity_buildFilm(data_file, data_path, folder, save_check);
end    
    
function [dimp_h_blue, dimp_h_red] =...
    intensity_buildFilm(data_file, data_path, folder, save)

%--------------------------------------------------------------------------
% Import 1D intensity data
%--------------------------------------------------------------------------

T_data = readtable(strcat(data_path, data_file));
disp(data_file);
%--------------------------------------------------------------------------
% Smooth data
%--------------------------------------------------------------------------

% blue_int = smooth(blue_int);

%--------------------------------------------------------------------------
% Identify absolute height from red/blue intensity ratio with reference
% to ideal, normalised curve
%--------------------------------------------------------------------------

[radius, dimp_h_red, dimp_h_blue, save_abs_h] =...
    intensity_abs_h_ID(T_data);

dimp_h_red = real(dimp_h_red);
dimp_h_blue = real(dimp_h_blue);

% pixels_mm = 1792/2; % Conversion from 2048 x 2048 image at 10x magnification -- need to divide by 2
% pixels_um = pixels_mm/1000;

figure(8)
scatter([-radius;radius], [dimp_h_blue;dimp_h_blue], 'blue','filled')
hold on

scatter([-radius;radius], [dimp_h_red;dimp_h_red], 'red','filled')
xlabel('Radius (\mu m)');
ylabel('Film thickness (nm)');

%--------------------------------------------------------------------------
% Save film data
%--------------------------------------------------------------------------

if save == 1   
    append_prompt = 'input unique file descriptor: ';
    append = input(append_prompt,'s');

    if ~exist(strcat(folder, 'red-film'),'dir')
        mkdir(folder, 'red-film');
    end
    
    if ~exist(strcat(folder, 'blue-film'),'dir')
        mkdir(folder, 'blue-film');
    end

%--------------------------------------------------------------------------
%Save red film thickness data
%--------------------------------------------------------------------------    

    name_film = '_red_film';
    type = '.txt';
    full_red = strcat(folder, 'red-film/',red_file(1:end-4), name_film,'_',append, type);
    
    varNames_film = {'radius_microMeter', 'film thickness_nanoMeter'};
    cellSave_film = [varNames_film; table2cell(table(round(radius,3), round(dimp_h_red,3)))];
    writecell(cellSave_film, full_red, 'Delimiter', '\t');

%--------------------------------------------------------------------------
% Save blue film thickness data
%--------------------------------------------------------------------------    
    
    name_film = '_blue_film';
    type = '.txt';
    full_blue = strcat(folder, 'blue-film/',blue_file(1:end-4), name_film, '_',append, type);
    varNames_film = {'radius_microMeter', 'film thickness_nanoMeter'};
    cellSave_film = [varNames_film; table2cell(table(round(radius,3), round(dimp_h_blue,3)))];
    writecell(cellSave_film, full_blue, 'Delimiter', '\t');
    
end

end