%--------------------------------------------------------------------------
% intensity_profileExtractor perfroms the following sequence of functions:
% - Reads image data of selected *.tiff files (2048x2048)
% - Takes Hough transform of 1st red image to ID centre of interference
%   pattern
%
% Then, looping through pairs of blue & red images
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
% Select b/g subtracted .tiff image files for each colour for which intensity
% will be extracted.
%--------------------------------------------------------------------------

[red_data, red_files, blue_data, blue_files, num_imgs] = intensity_selectFiles();


% red_files = {'researchUpdate/red_TX100-1-00350.tiff'};
% blue_files = {'researchUpdate/blue_TX100-1-00350.tiff'};
% num_imgs = 1;
% red_data = {imread(red_files{1})};
% blue_data = {imread(blue_files{1})};

img_data = red_data{1}; % Use this one for Hough transform
figure(1)
imshow(img_data)

%--------------------------------------------------------------------------
% Settings for circular Hough transform. Want same center to be used for
% all radial intensity averaging, so perform for one image then set
% constant
%--------------------------------------------------------------------------

[center, radius] = intensity_houghTransform(img_data);
% center = [472,531];

figure(1)
hold on
imshow(img_data)
viscircles(center, radius);
scatter(center(1,1), center(1,2),100,'x', 'red')
hold off

% Use a for loop here to go through pairs of red-blue images and save
% output
save = 1;

for ii = 1:num_imgs
    red_img = red_data{ii};
    blue_img = blue_data{ii};
    red_file = red_files{ii};
    blue_file = blue_files{ii};
    [norm_red, norm_blue, pix_red, pix_blue, dimp_h_blue, dimp_h_red] = profile(red_img, blue_img,...
        red_file, blue_file, center, save);
end    
    
function [norm_red, norm_blue, pix_red, pix_blue, dimp_h_blue, dimp_h_red] = profile(red_img, blue_img, red_file, blue_file, center,save)
%--------------------------------------------------------------------------
% Perform radial intensity average for all data using above center value.
%--------------------------------------------------------------------------
ang_min = 90; % angle in degrees
ang_max = 270;

[pix_red, red_int, r_max_red] = intensity_radialAverage(red_img,...
    center, ang_min, ang_max);
[pix_blue, blue_int, r_max_blue] = intensity_radialAverage(blue_img,...
    center, ang_min, ang_max);
%pix_blue = pix_blue+5;
%--------------------------------------------------------------------------
% Find points of max/min ie. constructive/destructive interference
%--------------------------------------------------------------------------

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
p3a = input(prompt3a);

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
p4a = input(prompt4a);

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
    
%--------------------------------------------------------------------------
%Save red intensity data
%--------------------------------------------------------------------------    
    
    name = '_intensity_info';
    type = '.txt';
    full_red = strcat(red_file(1:end-5), name, type);
    
    convert = {'Conversion factor from pixels to micro-meter (pixels/micro meter): ',num2str(pixels_um),''};
    hough = {'Circular Hough transform center (pixels): ', num2str(center),''};
    radAve = {'Max radius used for radial averaging: ', strcat('pixels: ',num2str(r_max_red)),strcat('radius (micro meter): ',num2str(r_max_red/pixels_um));...
        'Angular integration limits: ', num2str([ang_min, ang_max]),''};
    maxMin = {'Minimum peak prominence required for stationary point allocation: ', num2str(save_maxMin_red(1)),'';...
        'Region included in max/min ID: ', strcat('pixels: ', strcat(num2str(save_maxMin_red(2)),' ? ', num2str(save_maxMin_red(3)))),...
        strcat('radius (micro meter): ', strcat(num2str(save_maxMin_red(2)/pixels_um),' ? ', num2str(save_maxMin_red(3)/pixels_um)));...
        'Stationary point one *before* dimple rim: ', strcat('radius (micro meter): ', num2str(radius_red(ind_red(p3)))), strcat('intensity: ', num2str(red_int(ind_red(p3))))};
    
    maxMin_varNames = {'index', 'radius', 'intensity'};
    mxaMin_tab = table2cell(table(round(ind_red,3), round(radius_red(ind_red),3), round(sp_red,3), 'VariableNames', maxMin_varNames));
    
    
    abs_h = {'Red wavelength (nm): ', num2str(save_abs_h(1)),'';...
        'Blue wavelength (nm): ', num2str(save_abs_h(2)),'';...
        'Refractive index: ', num2str(save_abs_h(3)),'';...
        'Number of stationary points used to determine absolute height: ', num2str(save_abs_h(4)),''};
    varNames = {'radius', 'raw_intensity', 'normalised_intensity'};
    dataTable = table(round(radius_red,3), round(red_int,3), round(norm_red,3), 'VariableNames', varNames);
    cellTab = table2cell(dataTable);
    cellSave = [convert; hough; radAve; maxMin; {'','',''};...
        {'Stationary points','',''};maxMin_varNames;mxaMin_tab;{'','',''};...
        {'Radially averaged intensity','',''};abs_h;{'','',''};varNames;cellTab];
    
    writecell(cellSave, full_red, 'Delimiter', '\t');
    
%--------------------------------------------------------------------------
%Save red film thickness data
%--------------------------------------------------------------------------    

    name_film = '_red_film';
    type = '.txt';
    full_film = strcat(red_file(1:end-5), name_film, type);
    varNames_film = {'radius_microMeter', 'film thickness_nanoMeter'};
    cellSave_film = [varNames_film; table2cell(table(round(radius_red,3), round(dimp_h_red,3)))];
    writecell(cellSave_film, full_film, 'Delimiter', '\t');
    

%--------------------------------------------------------------------------
% Save blue intensity data
%--------------------------------------------------------------------------    

    
    name = '_intensity_info';
    type = '.txt';
    full_blue = strcat(blue_file(1:end-5), name, type);
    
    convert = {'Conversion factor from pixels to micro-meter (pixels/micro meter): ',num2str(pixels_um),''};
    hough = {'Circular Hough transform center (pixels): ', num2str(center),''};
    radAve = {'Max radius used for radial averaging: ', strcat('pixels: ',num2str(r_max_blue)),strcat('radius (micro meter): ',num2str(r_max_blue/pixels_um));...
        'Angular integration limits: ', num2str([ang_min, ang_max]),''};
    maxMin = {'Minimum peak prominence required for stationary point allocation: ', num2str(save_maxMin_blue(1)),'';...
        'Region included in max/min ID: ', strcat('pixels: ', strcat(num2str(save_maxMin_blue(2)),' ? ', num2str(save_maxMin_blue(3)))),...
        strcat('radius (micro meter): ', strcat(num2str(save_maxMin_blue(2)/pixels_um),' ? ', num2str(save_maxMin_blue(3)/pixels_um)));...
        'Stationary point one *before* dimple rim: ', strcat('radius (micro meter): ', num2str(radius_blue(ind_blue(p4)))), strcat('intensity: ', num2str(blue_int(ind_blue(p4))))};
    
    maxMin_varNames = {'index', 'radius', 'intensity'};
    mxaMin_tab = table2cell(table(round(ind_blue,3), round(radius_blue(ind_blue),3), round(sp_blue,3), 'VariableNames', maxMin_varNames));
    
    
    abs_h = {'red wavelength (nm): ', num2str(save_abs_h(1)),'';...
        'Blue wavelength (nm): ', num2str(save_abs_h(2)),'';...
        'Refractive index: ', num2str(save_abs_h(3)),'';...
        'Number of stationary points used to determine absolute height: ', num2str(save_abs_h(4)),''};
    varNames = {'radius', 'raw_intensity', 'normalised_intensity'};
    dataTable = table(round(radius_blue,3), round(blue_int,3), round(norm_blue,3), 'VariableNames', varNames);
    cellTab = table2cell(dataTable);
    cellSave = [convert; hough; radAve; maxMin; {'','',''};...
        {'Stationary points','',''};maxMin_varNames;mxaMin_tab;{'','',''};...
        {'Radially averaged intensity','',''};abs_h;{'','',''};varNames;cellTab];
    
    writecell(cellSave, full_blue, 'Delimiter', '\t');
    
%--------------------------------------------------------------------------
% Save blue film thickness data
%--------------------------------------------------------------------------    
    
    name_film = '_blue_film';
    type = '.txt';
    full_film = strcat(blue_file(1:end-5), name_film, type);
    varNames_film = {'radius_microMeter', 'film thickness_nanoMeter'};
    cellSave_film = [varNames_film; table2cell(table(round(radius_blue,3), round(dimp_h_blue,3)))];
    writecell(cellSave_film, full_film, 'Delimiter', '\t');
end

end