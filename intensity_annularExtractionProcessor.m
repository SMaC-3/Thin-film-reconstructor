%--------------------------------------------------------------------------
% Input settings - USER TO MODIFY
%--------------------------------------------------------------------------

%---Main branch directory info---------------------------------------------
folder = "/Volumes/T7/Thin films/MultiCam/Xgum/1000ppm_Xgum/1000ppm_Xgum_0p1mMKCl_0p2umF_run9/";

save_data = 0;
% center = [258,257];
% radius_in = [65,66,67,68,69,70,71,72,73,74,75];
radius_in = [67];

thx = 5;                % Sets thickness of annulus 
micron_bin = 3;    % Sets interval between bins in micron

azimuthal_data_path = cell(length(radius_in),1);
if save_data == 1
    for i = 1:length(radius_in)
    azimuthal_data_folder = strcat('azimuthal-intensity/',...
        'azimuthal-intensity-rad-',num2str(radius_in(i)),'/');
    azimuthal_data_path{i} = strcat(folder, azimuthal_data_folder);
    end
end

disp("Select red images");
[red_files, red_path] = uigetfile(strcat(folder,'*.tiff'),...
    'Select the subtracted red-files', 'MultiSelect','on');
% disp("Select blue images");
% [blue_files, blue_path] = uigetfile(strcat(folder,'*.tiff'),...
%     'Select the subtracted blue-files', 'MultiSelect','on');

if iscell(red_files) == 0
    red_files = {red_files};
end

%--------------------------------------------------------------------------
% END Input settings
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Perform Hough transform
%--------------------------------------------------------------------------

img_data = imread(strcat(red_path, red_files{1}));
figure(1)
BW = imbinarize(img_data);
% imshow(img_data)
imshow(BW);
roi = drawcircle;
roi.LineWidth = 0.5;
% [center, radius] = intensity_houghTransform(img_data);
input('Press enter to continue: ');
center = round(roi.Center);

theta = linspace(0,2*pi,100);
x = center(1)+radius_in(1)*cos(theta);
y = center(2)+radius_in(1)*sin(theta);

figure(2)
imshow(img_data);
hold on
plot(x,y,'LineWidth',1.5,'Color','blue');



% if iscell(blue_files) == 0
%     blue_files = {blue_files};
% end

num_imgs = length(red_files);

for i =1:num_imgs
    for j = 1:length(radius_in)
        red_img = imread(strcat(red_path, red_files{i}));
        %     blue_data{i} = imread(strcat(blue_path, blue_files{i}));

        [bins, bins_micron, binaverage] =...
            intensity_annularExtraction(red_img, center, radius_in(j),...
            thx, micron_bin);

        processing_info = {'Center (pixels) ',num2str(center),'';...
            'Annulus inner radius ',num2str(radius_in(j)),'';...
            'Annulus thickness ',num2str(thx),'';...
            'Microns per bin',num2str(micron_bin),'';
            '','',''};

        varNames = {'azimuthal_degrees', 'azimuthal_dimension', 'raw_intensity'};
        T_azimuthal = table(round(bins,3), round(bins_micron,3),...
            round(binaverage,3),'VariableNames',varNames);

        cellTab = table2cell(T_azimuthal);
        cell_azimuthal = [processing_info; varNames; cellTab];

        if save_data ==1
            file_split = split(red_files{i},'-');
            file_save = strcat(file_split{1},'-',file_split{2},'-',...
                file_split{3},'-AzimuthalInt-rad',num2str(radius_in(j)));
            saveData(cell_azimuthal, azimuthal_data_path{j}, file_save);
        end
    end
end







