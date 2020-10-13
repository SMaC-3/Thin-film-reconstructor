close all; clear all

%--------------------------------------------------------------------------
% Select b/g subtracted .tiff image files for each colour for which intensity
% will be extracted.
%--------------------------------------------------------------------------

[red_data, blue_data, num_imgs] = intensity_selectFiles();

img_data = red_data{1}; % Use this one for Hough transform
figure(1)
imshow(img_data)

%--------------------------------------------------------------------------
% Settings for circular Hough transform. Want same center to be used for
% all radial intensity averaging, so perform for one image then set
% constant
%--------------------------------------------------------------------------

[center] = intensity_houghTransform(img_data);

%--------------------------------------------------------------------------
% Perform radial intensity average for all data using above center value. 
%--------------------------------------------------------------------------
ang_min = -90; % angle in degrees
ang_max = -10;

pix_red = cell(num_imgs,1);
red_int = cell(num_imgs,1);

pix_blue = cell(num_imgs,1);
blue_int = cell(num_imgs,1);

for i =  1:num_imgs
    % TO DO: convert to  actual loop when more than one file is selected
    [pix_red{i}, red_int{i}, ~] = intensity_radialAverage(red_data{i},...
       center, ang_min, ang_max);
    [pix_blue{i}, blue_int{i}, ~] = intensity_radialAverage(blue_data{i},...
        center, ang_min, ang_max);
end

%--------------------------------------------------------------------------
% Find points of max/min ie. constructive/destructive interference
%--------------------------------------------------------------------------

ind_red = cell(num_imgs,1);
sp_red = cell(num_imgs,1);

ind_blue = cell(num_imgs,1);
sp_blue = cell(num_imgs,1);

for i = 1:num_imgs
    [ind_red{i},  sp_red{i}] = intensity_maxMin(pix_red{i}, red_int{i});
    [ind_blue{i},  sp_blue{i}] = intensity_maxMin(pix_blue{i}, blue_int{i});
end

%--------------------------------------------------------------------------
% Normalise radially averaged data branch-wise using max/min
%--------------------------------------------------------------------------

norm_red = cell(num_imgs,1);
norm_blue = cell(num_imgs,1);

for i = 1:num_imgs
    [norm_red{i}] = intensity_normalise(sp_red{i}, ind_red{i}, red_int{i});
    [norm_blue{i}] = intensity_normalise(sp_blue{i}, ind_blue{i}, blue_int{i});
end

figure(4)
plot(pix_red{i}, norm_red{i}, 'red', 'LineWidth', 2)
hold on
plot(pix_blue{i},  norm_blue{i}, 'blue', 'LineWidth', 2)
hold off

%--------------------------------------------------------------------------
% Identifty absolute height from red/blue intensity ratio with reference
% to ideal, normalised curve
%--------------------------------------------------------------------------

dimp_h_red = cell(num_imgs,1);
dimp_h_blue = cell(num_imgs,1);

for i = 1:num_imgs
    [dimp_h_red{i}, dimp_h_blue{i}] = intensity_abs_h_ID([pix_red{i} pix_blue{i}],...
        [norm_red{i} norm_blue{i}], {ind_red{i} ind_blue{i}});
end


