close all; clear all
format bank
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

% TO DO: Add select sp to use for normalisation

red_dimp_all = cell(num_imgs,1);
blue_dimp_all = cell(num_imgs,1);

for i = 1:num_imgs
    figure(5)
    plot(pix_red{i}, red_int{i}, 'red', 'LineWidth', 2)
    hold on
    scatter(pix_red{i}(ind_red{i}), red_int{i}(ind_red{i}), 200, 'black', 'filled')
    hold off
    
    disp([pix_red{i}(ind_red{i}).' ; 1:length(ind_red{i})])
%     sprintf(' %.2f',pix_red{i}(ind_red{i}).')
%     disp(1:length(ind_red{i}))
    prompt3 = 'Identify index of max/min one *before* red dimple: ';
    p3 = input(prompt3);
    red_dimp_all{i} = p3;
    
    %pix_red{i}(ind_red{i}(p3))
    
    red_dimp_I = ind_red{i}(p3);
    
    % Plot normalised blue intensity and scatter points of ID'd max/min
    
    figure(6)
    plot(pix_blue{i}, blue_int{i}, 'blue', 'LineWidth', 2)
    hold on
    scatter(pix_blue{i}(ind_blue{i}), blue_int{i}(ind_blue{i}), 200, 'black', 'filled')
    hold off
    
    disp([pix_blue{i}(ind_blue{i}).' ; 1:length(ind_blue{i})])
    % disp(1:length(ind_blue{i}))
    prompt4 = 'Identify index of max/min one *before* blue dimple: ';
    p4 = input(prompt4);
    blue_dimp_all{i} = p4;

    [norm_red{i}] = intensity_normalise(sp_red{i}(1:p3), ind_red{i}(1:p3), red_int{i});
    [norm_blue{i}] = intensity_normalise(sp_blue{i}(1:p4), ind_blue{i}(1:p4), blue_int{i});
end

figure(4)
plot(pix_red{i}, norm_red{i}, 'red', 'LineWidth', 2)
hold on
plot(pix_blue{i},  norm_blue{i}, 'blue', 'LineWidth', 2)
hold off

%--------------------------------------------------------------------------
% Identify absolute height from red/blue intensity ratio with reference
% to ideal, normalised curve
%--------------------------------------------------------------------------

dimp_h_red = cell(num_imgs,1);
dimp_h_blue = cell(num_imgs,1);

for i = 1:num_imgs
    [dimp_h_red{i}, dimp_h_blue{i}] = intensity_abs_h_ID([pix_red{i} pix_blue{i}],...
        [norm_red{i} norm_blue{i}], {ind_red{i} ind_blue{i}},...
        [red_dimp_all{i} blue_dimp_all{i}]);
end


% SAVE center, pix_red{i}, red_int{i}, pix_blue{i}, blue_int{i},
% ind_red{i},  sp_red{i}, ind_blue{i},  sp_blue{i}, norm_red{i},
% norm_blue{i},dimp_h_red, dimp_h_blue