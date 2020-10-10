close all; clear all
% Select b/g subtracted .tiff image files for each colour for which intensity
% will be extracted.

% [red_files, red_path] = uigetfile('*.tiff','Select the subtracted red-files', 'MultiSelect','on');
% [blue_files, blue_path] = uigetfile('*.tiff','Select the subtracted blue-files', 'MultiSelect','on');
red_files = 'red_img100.tiff';
blue_files = 'blue_img100.tiff';

% Load one test file for now
if iscell(red_files) == 0 
    red_files = {red_files};
end
% 
% if iscell(blue_files) == 0 
%     blue_files = {blue_files};
% end

red_test = imread(red_files{1});
blue_test = imread(blue_files);
img_data = red_test; % TEST: use this one for Hough transform. Change in non-test code
figure(1)
imshow(img_data)

% Settings for circular Hough transform. Want same center to be used for
% all radial intensity averaging.

object = 'bright';
sensitivity = 0.985;

r1 = 120;
r2 = 180;

[centers, radii] = imfindcircles(img_data, [r1, r2],...
    'ObjectPolarity',object, 'Sensitivity',sensitivity);

while isempty(radii) == 1
    prompt = 'No circles detected. Adjust sensitivity to try again. Sensitivity: ';
    p1 = input(prompt);
    [centers, radii] = imfindcircles(img_data, [r1, r2],...
    'ObjectPolarity',object, 'Sensitivity',p1); 
end
disp('circle detected. Showing overlay');
% viscircles(centers, radii);
hold on
scatter(centers(:,1), centers(:,2))
disp(centers);
prompt2 = 'Select the index corresponding a correct circle: ';
p2 = input(prompt2);

% Perform radial intensity average for all data using above  center value. 

% for i =  1:length(blue_test) 
    % TO DO: convert to  actual loop when more than one file is selected
    [pix_red, red_int] = intensity_radialAverage(img_data, centers(p2,:));
    [pix_blue, blue_int] = intensity_radialAverage(blue_test, centers(p2,:));
% end

% Find points of max/min ie. constructive/destructive interference

[ind_red,  sp_red] = intensity_maxMin(pix_red, red_int);
[ind_blue,  sp_blue] = intensity_maxMin(pix_blue, blue_int);

% minPeak = (nanmean(red_int) - nanmin(red_int))*0.5;
% [min_pks, I_min_pks] = findpeaks(-red_int, 'MinPeakProminence',minPeak,'MinPeakDistance',10);
% min_pks = -min_pks;
% [max_pks, I_max_pks] = findpeaks(red_int, 'MinPeakProminence',minPeak,'MinPeakDistance',10);
% 
% figure(4)
% hold on
% scatter(pix_red(I_min_pks), min_pks,200, 'red', 'filled')
% scatter(pix_red(I_max_pks), max_pks,200, 'black', 'filled')
% 
% I_merge = [I_min_pks, I_max_pks];
% sp_merge = [min_pks, max_pks]; %stationary points
% 
% [ind_sort, I_merge_sorted] = sort(I_merge);
% sp_sorted = sp_merge(I_merge_sorted);

% Normalise radially averaged data branch-wise using max/min

[norm_red] = intensity_normalise(sp_red, ind_red, red_int);
[norm_blue] = intensity_normalise(sp_blue, ind_blue, blue_int);

% norm_int_red = zeros(length(red_int),1);
% for i = 1:length(sp_red)-1
%     if i == 1
%         norm_int_red(1:ind_red(i+1)) =... 
%             (red_int(1:ind_red(i+1)) - min(sp_red(i:i+1)))./(max(sp_red(i:i+1)) - min(sp_red(i:i+1)));
%         
%     elseif i~= 1 && i~= length(sp_red)-1
%         norm_int_red(ind_red(i):ind_red(i+1)) = ...
%             (red_int(ind_red(i):ind_red(i+1)) - min(sp_red(i:i+1)))./(max(sp_red(i:i+1)) - min(sp_red(i:i+1)));
%         
%     else
%         norm_int_red(ind_red(i):end) =...
%              (red_int(ind_red(i):end) - min(sp_red(i:i+1)))./(max(sp_red(i:i+1)) - min(sp_red(i:i+1)));
%         
%     end
% end

figure()
plot(pix_red, norm_red, 'red', 'LineWidth', 2)
hold on
plot(pix_blue,  norm_blue,'blue', 'LineWidth', 2)

% Identifty absolute height from red/blue intensity ratio with reference
% to ideal, normalised curve

figure()
plot(pix_red, norm_red, 'red', 'LineWidth', 2)
hold on
scatter(pix_red(ind_red), norm_red(ind_red), 200, 'black', 'filled')

disp(pix_red(ind_red))
disp(1:length(ind_red))
prompt3 = 'Identify index of max/min one *before* red dimple: ';
p3 = input(prompt3);

figure()
plot(pix_blue, norm_blue, 'blue', 'LineWidth', 2)
hold on
scatter(pix_blue(ind_blue), norm_blue(ind_blue), 200, 'black', 'filled')

disp(pix_blue(ind_blue))
disp(1:length(ind_blue))
prompt4 = 'Identify index of max/min one *before* blue dimple: ';
p4 = input(prompt4);

lamb_red = 630;
lamb_blue = 450;
n1 = 1.33; % refractive index of water

numb = 20;
red_sp_h = (1:numb).'*(lamb_red/(n1*4));
blue_sp_h = (1:numb).'*(lamb_blue/(n1*4));

red_at_blue_sp = (cos(4*pi*n1*blue_sp_h/lamb_red)+1)./(2);
blue_at_red_sp = (cos(4*pi*n1*red_sp_h/lamb_blue)+1)./(2);

seq_n = 3;
find_abs_h_rab = zeros(length(red_sp_h)-seq_n,1);
find_abs_h_bar = zeros(length(blue_sp_h)-seq_n,1);

red_at_blue_exp = flip(norm_red(ind_blue(1:p4)));
blue_at_red_exp = flip(norm_blue(ind_red(1:p3)));

for ii = 1:length(find_abs_h_rab)
   
    find_abs_h_rab(ii) = abs(red_at_blue_exp(1)-red_at_blue_sp(ii))+...
        abs(red_at_blue_exp(2)-red_at_blue_sp(ii+1))+...
        abs(red_at_blue_exp(3)-red_at_blue_sp(ii+2));    
end

for ii = 1:length(find_abs_h_bar)
   
    find_abs_h_bar(ii) = abs(blue_at_red_exp(1)-blue_at_red_sp(ii))+...
        abs(blue_at_red_exp(2)-blue_at_red_sp(ii+1))+...
        abs(blue_at_red_exp(3)-blue_at_red_sp(ii+2));
end

find_abs_h_rab = round(find_abs_h_rab, 4);
find_abs_h_bar = round(find_abs_h_bar, 4);

[seq_min_rab, I_seq_min_rab] = min(find_abs_h_rab);
[seq_min_bar, I_seq_min_bar] = min(find_abs_h_bar);

blue_sp_h(I_seq_min_rab)
red_sp_h(I_seq_min_bar)

dimp_h_red = red_sp_h(I_seq_min_bar:p3+I_seq_min_bar-1); % bar is blue at red  SP. It refers to max/min in red spectra
dimp_h_blue = blue_sp_h(I_seq_min_rab:p4+I_seq_min_rab-1); % rab is red at blue  SP. It refers to max/min in blue spectra

dimp_h_red = flip(dimp_h_red);
dimp_h_blue = flip(dimp_h_blue);

% dimp_h = 
% dimp_I = 

figure()
scatter(pix_red(ind_red(1:p3)), dimp_h_red, 100, 'red', 'filled')
hold on
scatter(pix_blue(ind_blue(1:p4)), dimp_h_blue, 100, 'blue', 'filled')
scatter(-pix_red(ind_red(1:p3)), dimp_h_red, 100, 'red', 'filled')
scatter(-pix_blue(ind_blue(1:p4)), dimp_h_blue, 100, 'blue', 'filled')
