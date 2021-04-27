%--------------------------------------------------------------------------
% intensity_profileExtractor perfroms the following sequence of functions:
% Looping through pairs of blue & red 1D intensity  profiles
% - Extracts radially averaged intensity 
% - Identifies the maxima & minima in intensity profile
% - Identifies dimple region via user prompt
% - Normalises intensity profile branch-wise
% - Assigns absolute film thicknesss by comparison between blue & red
%   intensity
%--------------------------------------------------------------------------

% close all; clear all

format bank
%--------------------------------------------------------------------------
% 
%--------------------------------------------------------------------------

% Use a for loop here to go through pairs of red-blue images and save
% output
save = 1;

[red_files, red_path] = uigetfile('*.txt',...
    'Select the subtracted red-files', 'MultiSelect','on');
[blue_files, blue_path] = uigetfile('*.txt',...
    'Select the subtracted blue-files', 'MultiSelect','on');

if iscell(red_files) == 0 
    red_files = {red_files};
end

if iscell(blue_files) == 0 
    blue_files = {blue_files};
end

for ii = 1:size(red_files,2)
    red_file = red_files{ii};
    blue_file = blue_files{ii};
    [norm_red, norm_blue, pix_red, pix_blue, dimp_h_blue, dimp_h_red] = profile(red_file, red_path,...
        blue_file, blue_path, save);
end    
    
function [norm_red, norm_blue, pix_red, pix_blue, dimp_h_blue, dimp_h_red] = profile(red_file, red_path,blue_file, blue_path, save)

%--------------------------------------------------------------------------
% Find points of max/min ie. constructive/destructive interference
%--------------------------------------------------------------------------

T_red = importdata(strcat(red_path, red_file),'\t',8);
pix_red = T_red.data(:,1);
red_int = T_red.data(:,3);

T_blue = importdata(strcat(blue_path, blue_file),'\t',8);
pix_blue = T_blue.data(:,1);
blue_int = T_blue.data(:,3);

[ind_red,  sp_red, max_min_red, save_maxMin_red] = intensity_maxMin(pix_red, red_int);
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
hold off
disp([pix_red(ind_red).' ; 1:length(ind_red)])
prompt3 = 'Identify index of max/min one *before* red dimple: ';
prompt3a = 'Identify index of max/min one *after* red dimple: ';
p3 = input(prompt3);
while isempty(p3)
    p3 = input(prompt3);
end

p3a = input(prompt3a);
while isempty(p3a)
    p3a = input(prompt3a);
end

% Stationary points corresponding to 1st max/min inside and outside dimple 
red_dimp_all = p3;
red_outer = p3a;
 
%--------------------------------------------------------------------------
% Dimple ID for blue channel
%--------------------------------------------------------------------------
   
figure(4)
plot(pix_blue, blue_int, 'blue', 'LineWidth', 2)
hold on
scatter(pix_blue(ind_blue), blue_int(ind_blue), 200, 'black', 'filled')
hold off
disp([pix_blue(ind_blue).' ; 1:length(ind_blue)])
% disp(1:length(ind_blue))
prompt4 = 'Identify index of max/min one *before* blue dimple: '; 
prompt4a = 'Identify index of max/min one *after* blue dimple: ';
p4 = input(prompt4);
while isempty(p4)
    p4 = input(prompt4);
end
p4a = input(prompt4a);
while isempty(p4a)
    p4a = input(prompt4a);
end

% Stationary points corresponding to 1st max/min inside and outside dimple
blue_dimp_all = p4;
blue_outer = p4a;

%--------------------------------------------------------------------------
% Normalise radially averaged data branch-wise using max/min
%--------------------------------------------------------------------------

[norm_red] = intensity_normalise(sp_red, ind_red, red_int, red_dimp_all, red_outer);
[norm_blue] = intensity_normalise(sp_blue, ind_blue, blue_int, blue_dimp_all, blue_outer);

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

pixels_mm = 1792/2; % Conversion from 2048 x 2048 image at 10x magnification -- need to divide by 2
pixels_um = pixels_mm/1000;

radius_red = pix_red/pixels_um;
radius_blue = pix_blue/pixels_um;

figure(8)
scatter(radius_blue, dimp_h_blue, 100, 'blue', 'filled')
hold on
scatter(-radius_blue, dimp_h_blue, 100, 'blue', 'filled')
xlabel('Radius (\mu m)');
ylabel('Film thickness (nm)');

% SAVE center, pix_red, red_int, pix_blue, blue_int,
% ind_red,  sp_red, ind_blue,  sp_blue, norm_red,
% norm_blue,dimp_h_red, dimp_h_blue

if save == 1
    

if ~exist(strcat(red_path, 'red-film'),'dir')
    mkdir(red_path, 'red-film');
end

if ~exist(strcat(blue_path, 'blue-film'),'dir')
    mkdir(blue_path, 'blue-film');
end

    
%--------------------------------------------------------------------------
%Save red film thickness data
%--------------------------------------------------------------------------    

    name_film = '_red_film';
    type = '.txt';
    full_red = strcat(red_path, 'red-film/',red_file(1:end-5), name_film, type);
    
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
    full_blue = strcat(blue_path, 'blue-film/',blue_file(1:end-5), name_film, type);
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