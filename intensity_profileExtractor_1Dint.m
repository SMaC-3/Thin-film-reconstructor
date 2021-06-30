%--------------------------------------------------------------------------
% intensity_profileExtractor perfroms the following sequence of functions:
% Looping through pairs of blue & red 1D intensity  profiles
% - 
% - Identifies the maxima & minima in intensity profile
% - Identifies dimple region via user prompt
% - Normalises intensity profile branch-wise
% - Assigns absolute film thicknesss by comparison between blue & red
%   intensity
%--------------------------------------------------------------------------

% %figures to keep
% figs2keep = [6,7,8];
% 
% % Uncomment the following to 
% % include ALL windows, including those with hidden handles (e.g. GUIs)
% % all_figs = findall(0, 'type', 'figure');
% 
% all_figs = findobj(0, 'type', 'figure');
% delete(setdiff(all_figs, figs2keep));

% close all
clear all
format bank

%--------------------------------------------------------------------------
% Input settings - USER TO MODIFY
%--------------------------------------------------------------------------

%---Index of files to be procesed------------------------------------------
selected = [250];
selected = flip(selected);
save_check = 1; % 1 = save info, 0 = do not save info 
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
conc = '4p5wt';
sample = 'CNC';
expNum = 'run10';
branch = '/Volumes/ZIGGY/Thin films/MultiCam/';

% red_folder = 'red-1D-int/';
% blue_folder = 'blue-1D-int/';
red_folder = 'red-int-sectors/red-1D-int-0-360/';
blue_folder = 'blue-int-sectors/blue-1D-int-0-360/';

folder = fullfile(branch, sample, strcat(conc,sample),...
    strcat(conc,sample,'_',expNum,'/')); 
red_path = strcat(folder, red_folder);
blue_path = strcat(folder, blue_folder);

csvFile = strcat(conc,sample,'_',expNum,'_TimeStamps.csv');
%--------------------------------------------------------------------------

%---define file identifiers------------------------------------------------
red_fodler_parts = split(red_folder,{'-','/'});
ang_min = red_fodler_parts{end-2};
ang_max = red_fodler_parts{end-1};
name = '-int-1D';
type = '.txt';
%--------------------------------------------------------------------------

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

%--------------------------------------------------------------------------
% Build/get file names
%--------------------------------------------------------------------------

%     for i = 1:length(selected)
%     choose(i) = find(nameID==selected(i));
%     end
%     
%     red_files = {red_names{choose}};
%     blue_files = {blue_names{choose}};
%     
%     if length(selected) == 1
%         red_parts = split(red_files.',{'-','_','.'}).';
%         blue_parts = split(blue_files.',{'-','_','.'}).';
%     else
%         red_parts = split(red_files.',{'-','_','.'});
%         blue_parts = split(blue_files.',{'-','_','.'});
%     end
% 
%     for i = 1:length(red_files)
%     red_files{i} = strcat(red_parts{i,1},'_', red_parts{i,2},'-',...
%         red_parts{i,3},'-',red_parts{i,4}, name, '-',...
%         ang_min,'-',ang_max,type);
%     blue_files{i} = strcat(blue_parts{i,1},'_', blue_parts{i,2},'-',...
%         blue_parts{i,3},'-',blue_parts{i,4}, name, '-',...
%         ang_min,'-',ang_max,type);
%     end

%---Uncomment to select files manually-------------------------------------
[red_files, red_path] = uigetfile(strcat(red_path,'*.txt'),...
    'Select the subtracted red-files', 'MultiSelect','on');
[blue_files, blue_path] = uigetfile(strcat(blue_path,'*.txt'),...
    'Select the subtracted blue-files', 'MultiSelect','on');


if iscell(red_files) == 0 
    red_files = {red_files};
end

if iscell(blue_files) == 0 
    blue_files = {blue_files};
end

%---Correct for light field gradient---------------------------------------

% red correction
T_red = importdata(strcat(red_path, red_files{1}),'\t',8);
pix_red = T_red.data(:,1);
red_int = T_red.data(:,3);
[red_P] = intensity_gradCorrect(pix_red, red_int);

% blue correction
T_blue = importdata(strcat(blue_path, blue_files{1}),'\t',8);
pix_blue = T_blue.data(:,1);
blue_int = T_blue.data(:,3);
[blue_P] = intensity_gradCorrect(pix_blue, blue_int);

%--------------------------------------------------------------------------

for ii = 1:size(red_files,2)
    red_file = red_files{ii};
    blue_file = blue_files{ii};
    [norm_red, norm_blue, pix_red, pix_blue, dimp_h_blue, dimp_h_red] =...
        profile(red_file, red_path, red_P,...
        blue_file, blue_path,blue_P, folder, save_check);
end    
    
function [norm_red, norm_blue, pix_red, pix_blue, dimp_h_blue, dimp_h_red]...
    = profile(red_file, red_path,red_P, blue_file, blue_path, blue_P,folder, save)

%--------------------------------------------------------------------------
% Import 1D intensity data
%--------------------------------------------------------------------------

T_red = importdata(strcat(red_path, red_file),'\t',8);
pix_red = T_red.data(:,1);
red_int_raw = T_red.data(:,3);
red_int = red_int_raw./(polyval(red_P,pix_red));

T_blue = importdata(strcat(blue_path, blue_file),'\t',8);
pix_blue = T_blue.data(:,1);
blue_int_raw = T_blue.data(:,3);
blue_int = blue_int_raw./(polyval(blue_P, pix_blue));

disp(red_file);



%--------------------------------------------------------------------------
% Smooth data
%--------------------------------------------------------------------------

% blue_int = smooth(blue_int);


%--------------------------------------------------------------------------
% Identify max/min
%--------------------------------------------------------------------------

% ind_ = sorted indices of max/min
% sp_ = intensity values at max/min in index order
% max_min_ = identifies whether max or min with 1 or 0

[ind_red,  sp_red, max_min_red, save_maxMin_red] = intensity_maxMin(pix_red, red_int);
% [ind_blue,  sp_blue, max_min_blue, save_maxMin_blue] = intensity_maxMin(pix_blue, blue_int);
[ind_blue,  sp_blue, max_min_blue, save_maxMin_blue] = intensity_maxMin(pix_blue, blue_int);

%--------------------------------------------------------------------------
% Identify indices corresponding to 1st max or min inside and outside
% dimple
%--------------------------------------------------------------------------
% Dimple ID for red channel
%--------------------------------------------------------------------------

figure(3)
plot(pix_red, red_int, 'red', 'LineWidth', 2)
hold on
scatter(pix_red(ind_red), red_int(ind_red), 200, 'black', 'filled')
for k = 1:length(ind_red)
   
    text(pix_red(ind_red(k)), mean(red_int) + max_min_red(k)*mean(red_int)*0.75 +(max_min_red(k)-1)*mean(red_int)*0.75  ,num2str(k))
    
end
hold off
disp([pix_red(ind_red).' ; 1:length(ind_red)])

red_dimp_prompt = 'Identify index of red dimple (enter 0 to manually add a sp or -1 to manually remove a sp): ';
red_dimp = input(red_dimp_prompt);
while isempty(red_dimp)
    red_dimp = input(red_dimp_prompt);
end

while red_dimp == 0
    
    man_ID_prompt = 'please select pixel value for SP: ';
    man_ID = input(man_ID_prompt);
    [~, mvI] = min(abs(pix_red - man_ID));
    man_ID_prompt_2 = 'Is this a max or min [enter 1 or 0]: ';
    man_ID_2 = input(man_ID_prompt_2);
    
    ind_red = [ind_red; mvI];
    [ind_red, ind_red_sorted] = sort(ind_red);
    
    sp_red = [sp_red; red_int(mvI)];
    max_min_red = [max_min_red;man_ID_2];
   
    sp_red = sp_red(ind_red_sorted);
    max_min_red = max_min_red(ind_red_sorted);
    
    figure(3)
    plot(pix_red, red_int, 'red', 'LineWidth', 2)
    hold on
    scatter(pix_red(ind_red), red_int(ind_red), 200, 'black', 'filled')
    for k = 1:length(ind_red)
    text(pix_red(ind_red(k)), mean(red_int) + max_min_red(k)*mean(red_int)*0.75 +(max_min_red(k)-1)*mean(red_int)*0.75  ,num2str(k))  
    end
    hold off
    disp([pix_red(ind_red).' ; 1:length(ind_red)])
    
    red_dimp_prompt = 'Identify index of red dimple (enter 0 to manually add a sp or -1 to manually remove a sp): ';
    red_dimp = input(red_dimp_prompt);
    while isempty(red_dimp)
        red_dimp = input(red_dimp_prompt);
    end

end


while red_dimp == -1
    
    man_ID_prompt = 'please select pixel value for SP: ';
    man_ID = input(man_ID_prompt);
    [~, mvI] = min(abs(pix_red - man_ID));
    [~,find_I] = min(abs(ind_red-mvI));
    
    ind_red(find_I) = [];
    sp_red(find_I) = [];
    max_min_red(find_I) = [];
    
    figure(3)
    plot(pix_red, red_int, 'red', 'LineWidth', 2)
    hold on
    scatter(pix_red(ind_red), red_int(ind_red), 200, 'black', 'filled')
    for k = 1:length(ind_red)
    text(pix_red(ind_red(k)), mean(red_int) + max_min_red(k)*mean(red_int)*0.75 +(max_min_red(k)-1)*mean(red_int)*0.75  ,num2str(k))  
    end
    hold off
    disp([pix_red(ind_red).' ; 1:length(ind_red)])
    
    red_dimp_prompt = 'Identify index of red dimple (enter -1 to manually remove a sp): ';
    red_dimp = input(red_dimp_prompt);
    while isempty(red_dimp)
        red_dimp = input(red_dimp_prompt);
    end

end

% prompt3 = 'Identify index of max/min one *before* red dimple: ';
% prompt3a = 'Identify index of max/min one *after* red dimple: ';
% p3 = input(prompt3);
% while isempty(p3)
%     p3 = input(prompt3);
% end
% 
% p3a = input(prompt3a);
% while isempty(p3a)
%     p3a = input(prompt3a);
% end
% 
% % Stationary points corresponding to 1st max/min inside and outside dimple 
% red_dimp_all = p3;
% red_outer = p3a;
 
%--------------------------------------------------------------------------
% Dimple ID for blue channel
%--------------------------------------------------------------------------
   
figure(4)
plot(pix_blue, blue_int, 'blue', 'LineWidth', 2)
hold on
scatter(pix_blue(ind_blue), blue_int(ind_blue), 200, 'black', 'filled')

for k = 1:length(ind_blue)
   
    text(pix_blue(ind_blue(k)),  mean(blue_int) + max_min_blue(k)*mean(blue_int)*0.75 +(max_min_blue(k)-1)*mean(blue_int)*0.75,num2str(k))
    
end
hold off
disp([pix_blue(ind_blue).' ; 1:length(ind_blue)])
% disp(1:length(ind_blue))

blue_dimp_prompt = 'Identify index of blue dimple (enter 0 to manually add a sp): ';
blue_dimp = input(blue_dimp_prompt);
while isempty(blue_dimp)
    blue_dimp = input(blue_dimp_prompt);
end

while blue_dimp == 0
    
    man_ID_prompt = 'please select pixel value for SP: ';
    man_ID = input(man_ID_prompt);
    [~, mvI] = min(abs(pix_blue - man_ID));
    man_ID_prompt_2 = 'Is this a max or min [enter 1 or 0]: ';
    man_ID_2 = input(man_ID_prompt_2);
    
    ind_blue = [ind_blue; mvI];
    [ind_blue, ind_blue_sorted] = sort(ind_blue);
    
    sp_blue = [sp_blue; blue_int(mvI)];
    max_min_blue = [max_min_blue;man_ID_2];
    sp_blue = sp_blue(ind_blue_sorted);
    max_min_blue = max_min_blue(ind_blue_sorted);
    
    figure(4)
    plot(pix_blue, blue_int, 'blue', 'LineWidth', 2)
    hold on
    scatter(pix_blue(ind_blue), blue_int(ind_blue), 200, 'black', 'filled')

    for k = 1:length(ind_blue)
   
        text(pix_blue(ind_blue(k)),  mean(blue_int) + max_min_blue(k)*mean(blue_int)*0.75 +(max_min_blue(k)-1)*mean(blue_int)*0.75,num2str(k))
    
    end
    hold off
    disp([pix_blue(ind_blue).' ; 1:length(ind_blue)])
    
    blue_dimp_prompt = 'Identify index of blue dimple (enter 0 to manually add a sp): ';
    blue_dimp = input(blue_dimp_prompt);
    while isempty(blue_dimp)
        blue_dimp = input(blue_dimp_prompt);
    end
    
end

while blue_dimp == -1
    
    man_ID_prompt = 'please select pixel value for SP: ';
    man_ID = input(man_ID_prompt);
    [~, mvI] = min(abs(pix_blue - man_ID));
    [~,find_I] = min(abs(ind_blue-mvI));
    
    ind_blue(find_I) = [];
    sp_blue(find_I) = [];
    max_min_blue(find_I) = [];
    
    figure(3)
    plot(pix_blue, blue_int, 'blue', 'LineWidth', 2)
    hold on
    scatter(pix_blue(ind_blue), blue_int(ind_blue), 200, 'black', 'filled')
    for k = 1:length(ind_blue)
    text(pix_blue(ind_blue(k)), mean(blue_int) + max_min_blue(k)*mean(blue_int)*0.75 +(max_min_blue(k)-1)*mean(blue_int)*0.75  ,num2str(k))  
    end
    hold off
    disp([pix_blue(ind_blue).' ; 1:length(ind_blue)])
    
    blue_dimp_prompt = 'Identify index of blue dimple (enter -1 to manually remove a sp): ';
    blue_dimp = input(blue_dimp_prompt);
    while isempty(blue_dimp)
        blue_dimp = input(blue_dimp_prompt);
    end

end


% prompt4 = 'Identify index of max/min one *before* blue dimple: '; 
% prompt4a = 'Identify index of max/min one *after* blue dimple: ';
% p4 = input(prompt4);
% while isempty(p4)
%     p4 = input(prompt4);
% end
% p4a = input(prompt4a);
% while isempty(p4a)
%     p4a = input(prompt4a);
% end
% 
% % Stationary points corresponding to 1st max/min inside and outside dimple
% blue_dimp_all = p4;
% blue_outer = p4a;

%--------------------------------------------------------------------------
% Normalise radially averaged data branch-wise using max/min
%--------------------------------------------------------------------------
red_dimp_all = red_dimp-1;
red_outer = red_dimp+1;
blue_dimp_all = blue_dimp-1;
blue_outer = blue_dimp+1;
[norm_red] = intensity_normalise(sp_red, ind_red, pix_red,red_int, red_dimp);
[norm_blue] = intensity_normalise(sp_blue, ind_blue, pix_blue,blue_int, blue_dimp);

figure(5)
plot(pix_red, norm_red, 'red', 'LineWidth', 2)
hold on
plot(pix_blue,  norm_blue, 'blue', 'LineWidth', 2)
hold off

%--------------------------------------------------------------------------
% Identify absolute height from red/blue intensity ratio with reference
% to ideal, normalised curve
%--------------------------------------------------------------------------

[dimp_h_red, dimp_h_blue, save_abs_h] = intensity_abs_h_ID([pix_red pix_blue],...
    [norm_red norm_blue], {ind_red ind_blue},...
    {max_min_red, max_min_blue},...
    [red_dimp_all blue_dimp_all], [red_outer blue_outer]);

dimp_h_red = real(dimp_h_red);
dimp_h_blue = real(dimp_h_blue);

pixels_mm = 1792/2; % Conversion from 2048 x 2048 image at 10x magnification -- need to divide by 2
pixels_um = pixels_mm/1000;

radius_red = pix_red/pixels_um;
radius_blue = pix_blue/pixels_um;

figure(8)
scatter([-radius_blue;radius_blue], [dimp_h_blue;dimp_h_blue], 'blue','filled')
hold on

scatter([-radius_red;radius_red], [dimp_h_red;dimp_h_red], 'red','filled')
xlabel('Radius (\mu m)');
ylabel('Film thickness (nm)');

% SAVE center, pix_red, red_int, pix_blue, blue_int,
% ind_red,  sp_red, ind_blue,  sp_blue, norm_red,
% norm_blue,dimp_h_red, dimp_h_blue

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
    cellSave_film = [varNames_film; table2cell(table(round(radius_red,3), round(dimp_h_red,3)))];
    writecell(cellSave_film, full_red, 'Delimiter', '\t');
    
% %--------------------------------------------------------------------------
% %Save red intensity data
% %--------------------------------------------------------------------------    
%     
%     name = '_intensity_info';
%     type = '.txt';
%     full_red = strcat(red_file(1:end-5), name, type);
%     
%     maxMin = {'Minimum peak prominence required for stationary point allocation: ', num2str(save_maxMin_red(1)),'';...
%         'Region included in max/min ID: ', strcat('pixels: ', strcat(num2str(save_maxMin_red(2)),' ? ', num2str(save_maxMin_red(3)))),...
%         strcat('radius (micro meter): ', strcat(num2str(save_maxMin_red(2)/pixels_um),' ? ', num2str(save_maxMin_red(3)/pixels_um)));...
%         'Stationary point one *before* dimple rim: ', strcat('radius (micro meter): ', num2str(radius_red(ind_red(p3)))), strcat('intensity: ', num2str(red_int(ind_red(p3))))};
%     
%     abs_h = {'Red wavelength (nm): ', num2str(save_abs_h(1)),'';...
%         'Blue wavelength (nm): ', num2str(save_abs_h(2)),'';...
%         'Refractive index: ', num2str(save_abs_h(3)),'';...
%         'Number of stationary points used to determine absolute height: ', num2str(save_abs_h(4)),''};
%     varNames = {'radius', 'raw_intensity', 'normalised_intensity'};
%     dataTable = table(round(radius_red,3), round(red_int,3), round(norm_red,3), 'VariableNames', varNames);
%     cellTab = table2cell(dataTable);
%     cellSave = [convert; hough; radAve; maxMin; {'','',''};...
%         {'Stationary points','',''};maxMin_varNames;mxaMin_tab;{'','',''};...
%         {'Radially averaged intensity','',''};abs_h;{'','',''};varNames;cellTab];
%     
%     writecell(cellSave, full_red, 'Delimiter', '\t');
    

%--------------------------------------------------------------------------
% Save blue film thickness data
%--------------------------------------------------------------------------    
    
    name_film = '_blue_film';
    type = '.txt';
    full_blue = strcat(folder, 'blue-film/',blue_file(1:end-4), name_film, '_',append, type);
    varNames_film = {'radius_microMeter', 'film thickness_nanoMeter'};
    cellSave_film = [varNames_film; table2cell(table(round(radius_blue,3), round(dimp_h_blue,3)))];
    writecell(cellSave_film, full_blue, 'Delimiter', '\t');

%--------------------------------------------------------------------------
% Save blue intensity data
%--------------------------------------------------------------------------    

    
%     name = '_intensity_info';
%     type = '.txt';
%     full_blue = strcat(blue_file(1:end-5), name, type);
% 
%     maxMin = {'Minimum peak prominence required for stationary point allocation: ', num2str(save_maxMin_blue(1)),'';...
%         'Region included in max/min ID: ', strcat('pixels: ', strcat(num2str(save_maxMin_blue(2)),' ? ', num2str(save_maxMin_blue(3)))),...
%         strcat('radius (micro meter): ', strcat(num2str(save_maxMin_blue(2)/pixels_um),' ? ', num2str(save_maxMin_blue(3)/pixels_um)));...
%         'Stationary point one *before* dimple rim: ', strcat('radius (micro meter): ', num2str(radius_blue(ind_blue(p4)))), strcat('intensity: ', num2str(blue_int(ind_blue(p4))))};
%     
%     maxMin_varNames = {'index', 'radius', 'intensity'};
%     mxaMin_tab = table2cell(table(round(ind_blue,3), round(radius_blue(ind_blue),3), round(sp_blue,3), 'VariableNames', maxMin_varNames));
%     
%     
%     abs_h = {'red wavelength (nm): ', num2str(save_abs_h(1)),'';...
%         'Blue wavelength (nm): ', num2str(save_abs_h(2)),'';...
%         'Refractive index: ', num2str(save_abs_h(3)),'';...
%         'Number of stationary points used to determine absolute height: ', num2str(save_abs_h(4)),''};
%     varNames = {'radius', 'raw_intensity', 'normalised_intensity'};
%     dataTable = table(round(radius_blue,3), round(blue_int,3), round(norm_blue,3), 'VariableNames', varNames);
%     cellTab = table2cell(dataTable);
%     cellSave = [convert; hough; radAve; maxMin; {'','',''};...
%         {'Stationary points','',''};maxMin_varNames;mxaMin_tab;{'','',''};...
%         {'Radially averaged intensity','',''};abs_h;{'','',''};varNames;cellTab];
%     
%     writecell(cellSave, full_blue, 'Delimiter', '\t');
    

end

end