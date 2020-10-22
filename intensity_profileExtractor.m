% close all; clear all
format bank
%--------------------------------------------------------------------------
% Select b/g subtracted .tiff image files for each colour for which intensity
% will be extracted.
%--------------------------------------------------------------------------

[red_data, red_files, blue_data, blue_files, num_imgs] = intensity_selectFiles();

img_data = red_data{1}; % Use this one for Hough transform
figure(1)
imshow(img_data)

%--------------------------------------------------------------------------
% Settings for circular Hough transform. Want same center to be used for
% all radial intensity averaging, so perform for one image then set
% constant
%--------------------------------------------------------------------------

[center] = intensity_houghTransform(img_data);

% Use a for loop here to go through pairs of red-blue images and save
% output
save = 1;

for ii = 1:num_imgs
    red_img = red_data{ii};
    blue_img = blue_data{ii};
    red_file = red_files{ii};
    blue_file = blue_files{ii};
    [dimp_h_red] = profile(red_img, blue_img,...
        red_file, blue_file, center, save);
end    
    
function [dimp_h_red] = profile(red_img, blue_img, red_file, blue_file, center,save)
%--------------------------------------------------------------------------
% Perform radial intensity average for all data using above center value.
%--------------------------------------------------------------------------
ang_min = 180; % angle in degrees
ang_max = 270;

[pix_red, red_int, r_max_red] = intensity_radialAverage(red_img,...
    center, ang_min, ang_max);
[pix_blue, blue_int, r_max_blue] = intensity_radialAverage(blue_img,...
    center, ang_min, ang_max);

%--------------------------------------------------------------------------
% Find points of max/min ie. constructive/destructive interference
%--------------------------------------------------------------------------

[ind_red,  sp_red, save_maxMin_red] = intensity_maxMin(pix_red, red_int);
[ind_blue,  sp_blue, save_maxMin_blue] = intensity_maxMin(pix_blue, blue_int);

%--------------------------------------------------------------------------
% Normalise radially averaged data branch-wise using max/min
%--------------------------------------------------------------------------

figure(5)
plot(pix_red, red_int, 'red', 'LineWidth', 2)
hold on
scatter(pix_red(ind_red), red_int(ind_red), 200, 'black', 'filled')
hold off
    
disp([pix_red(ind_red).' ; 1:length(ind_red)])
%     sprintf(' %.2f',pix_red(ind_red).')
%     disp(1:length(ind_red))
prompt3 = 'Identify index of max/min one *before* red dimple: ';
p3 = input(prompt3);
red_dimp_all = p3;
    
 %pix_red(ind_red(p3))
    
red_dimp_I = ind_red(p3);
 
 % Plot normalised blue intensity and scatter points of ID'd max/min
   
figure(6)
plot(pix_blue, blue_int, 'blue', 'LineWidth', 2)
hold on
scatter(pix_blue(ind_blue), blue_int(ind_blue), 200, 'black', 'filled')
hold off
disp([pix_blue(ind_blue).' ; 1:length(ind_blue)])
% disp(1:length(ind_blue))
prompt4 = 'Identify index of max/min one *before* blue dimple: ';
p4 = input(prompt4);
blue_dimp_all = p4;

[norm_red] = intensity_normalise(sp_red(1:p3), ind_red(1:p3), red_int);
[norm_blue] = intensity_normalise(sp_blue(1:p4), ind_blue(1:p4), blue_int);


figure(4)
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
    [red_dimp_all blue_dimp_all]);

dimp_pix_red = pix_red(ind_red(1:p3));
dimp_pix_blue = pix_blue(ind_blue(1:p4));

% How should points at common periodicity be handled?
% Average of both colours?

dimp_pix  = [dimp_pix_red; dimp_pix_blue];
[dimp_pix, I_dimp_pix] = sort(dimp_pix);
dimp_h = [dimp_h_red; dimp_h_blue];
dimp_h = dimp_h(I_dimp_pix);

% figure()
% plot(dimp_pix, dimp_h)


% SAVE center, pix_red, red_int, pix_blue, blue_int,
% ind_red,  sp_red, ind_blue,  sp_blue, norm_red,
% norm_blue,dimp_h_red, dimp_h_blue

if save == 1
    
%--------------------------------------------------------------------------
%Save red data
%--------------------------------------------------------------------------    
    
    name = '_intensity_info';
    type = '.txt';
    full_red = strcat(red_file(1:end-5), name, type);
    
    hough = {'Circular Hough transform center: ', num2str(center),''};
    radAve = {'Max radius used for radial averaging: ', num2str(r_max_red),'';...
        'Angular integration limits: ', num2str([ang_min, ang_max]),''};
    maxMin = {'Minimum peak prominence required for stationary point allocation: ', num2str(save_maxMin_red(1)),'';...
        'Radial cutoff region excluded from max/min ID: ', num2str(save_maxMin_red(2)),'';...
        'Stationary point one *before* dimple rim: ', strcat('pixel: ', num2str(pix_red(ind_red(p3)))), strcat('intensity: ', num2str(red_int(ind_red(p3))))};
    
    maxMin_varNames = {'index', 'pixels', 'intensity'};
    mxaMin_tab = table2cell(table(ind_red, pix_red(ind_red), sp_red, 'VariableNames', maxMin_varNames));
    
    
    abs_h = {'Red wavelength (nm): ', num2str(save_abs_h(1)),'';...
        'Blue wavelength (nm): ', num2str(save_abs_h(2)),'';...
        'Refractive index: ', num2str(save_abs_h(3)),'';...
        'Number of stationary points used to determine absolute height: ', num2str(save_abs_h(4)),''};
    varNames = {'pixels', 'raw_intensity', 'normalised_intensity'};
    dataTable = table(round(pix_red,3), round(red_int,3), round(norm_red,3), 'VariableNames', varNames);
    cellTab = table2cell(dataTable);
    cellSave = [hough; radAve; maxMin; {'','',''};...
        {'Stationary points','',''};maxMin_varNames;mxaMin_tab;{'','',''};...
        {'Radially averaged intensity','',''};abs_h;{'','',''};varNames;cellTab];
    
    writecell(cellSave, full_red, 'Delimiter', '\t');
    
    

%--------------------------------------------------------------------------
% Save blue data
%--------------------------------------------------------------------------    

    name = '_intensity_info';
    type = '.txt';
    full_blue = strcat(blue_file(1:end-5), name, type);

    hough = {'Circular Hough transform center: ', num2str(center),''};
    radAve = {'Max radius used for radial averaging: ', num2str(r_max_blue),'';...
        'Angular integration limits: ', num2str([ang_min, ang_max]),''};
    maxMin = {'Minimum peak prominence required for stationary point allocation: ', num2str(save_maxMin_blue(1)),'';...
        'Radial cutoff region excluded from max/min ID: ', num2str(save_maxMin_blue(2)),''};
    abs_h = {'Red wavelength (nm): ', num2str(save_abs_h(1)),'';...
        'Blue wavelength (nm): ', num2str(save_abs_h(2)),'';...
        'Refractive index: ', num2str(save_abs_h(3)),'';...
        'Number of stationary points used to determine absolute height: ', num2str(save_abs_h(4)),''};
    varNames = {'pixels', 'raw_intensity', 'normalised_intensity'};
    dataTable = table(round(pix_blue,3), round(blue_int,3), round(norm_blue,3), 'VariableNames', varNames);
    cellTab = table2cell(dataTable);
    cellSave = [hough; radAve; maxMin; abs_h;{'','',''};varNames;cellTab];
    
    writecell(cellSave, full_blue, 'Delimiter', '\t');
    
%--------------------------------------------------------------------------
% Save dimple data
%--------------------------------------------------------------------------    
    name_film = '_red_blue_film';
    type = '.txt';
    full_film = strcat(red_file(5:end-5), name_film, type);
    varNames_film = {'radius (pixels)', 'film thickness (nm)'};
    cellSave_film = [varNames_film; table2cell(table(dimp_pix, dimp_h))];
    writecell(cellSave_film, full_film, 'Delimiter', '\t');
end

end