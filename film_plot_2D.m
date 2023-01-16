close all
% Main branch for data
folder = "/Volumes/T7/Thin films/MultiCam/SDS/50mM_SDS/50mM_SDS_run4/";

% Timestamps + files details csv
csvFile = "50mM_SDS_run4_TimeStamps.csv";

plot_rgb = 1;

red_scale = 1;
blue_scale = 1.3;
green_scale = 0;

plot_3d = 1;

timestamp_fig = 1;
save_fig = 1;

% Image and film source sub-folders and paths
% red_img_folder = "red-surfFit-WBcor-tiff/";
red_img_folder = "rgb-tiff/";
red_img_path = fullfile(folder, red_img_folder);

red_film_folder = "thin-films-2D/";
% fig_type = "3Dimg_subplot";
identifier = "-50mM_run4";
save_folder = "/Volumes/T7/Thin films/MultiCam/SDS/SDS_figures/";

% red_img_path = fullfile(folder, red_img_folder);
red_film_path = fullfile(folder, red_film_folder);

% Image files to be included in video
% selected = [340:10:650].'; 
selected = [800];
 
% Info re line extraction for line plot overlay

center = [260	258];
max_rad = 190;

%--------------------------------------------------------------
% End User defined input settings
%--------------------------------------------------------------
%% Import 
if plot_rgb == 1
[red_data, red_files, num_imgs]...
    = findFile(folder, red_img_path, csvFile, selected, "rgb");



% TO DO: Add ability to make subplot (should make it more efficient for
% figure making)
subplot(1,num_imgs,1)
hold on

for i = 1:num_imgs
    subplot(1,num_imgs,i)
    img_plot = red_data{i};
    img_plot(:,:,1) = img_plot(:,:,1)*red_scale;
    img_plot(:,:,2) = img_plot(:,:,2)*green_scale;
    img_plot(:,:,3) = img_plot(:,:,3)*blue_scale; 
    imshow(img_plot)
   
    hold on
    fig = gcf;
    fig.Units = 'centimeters';
    fig.Position = [10 10 (5*num_imgs)+3 5.1];
    fig.Color = 'white';

    ax = gca;
    ax.Units = 'centimeters';
    ax.XLim= [0.5 512.5];
    ax.YLim= [0.5 512.5];
    ax.Position = [5*(i-1)+0.1 0.1 4.9 4.9];

end
fig.Position = [10 10 (5*num_imgs)+0.1 5.1];
hold off
figure(1)
end


%% Determine radius from center of film (as set above)

[films_data, red_files, num_films] =...
    findFile_2D_films(red_film_path, selected);

rows = 512;
cols = rows;

x = 1:rows;
y = x;

[xx, yy] = meshgrid(x,y);
xx = xx - 1;
yy = yy - 1;

radius = sqrt((xx - center(1)).^2 + (yy - center(2)).^2);

% Find points within film radius
log_rad = radius < max_rad;

% Define conversion factor from pixels to micron

pixels_mm = 1792/2;
% Conversion from 2048 x 2048 image at 10x magnification -- need to divide by 2
pixels_um = pixels_mm/1000;

%% Notes for 3D contour
if plot_3d == 1
 
% Import timestamps csv
csvRead = strcat(folder,csvFile);
T = readtable(csvRead, 'Delimiter',',');
folder_parts = split(folder, '/');

Tend = find(isnan(T.Index),1);
if ~isempty(Tend)
    T = T(1:Tend-1,1:15);
else
    T = T(1:end,1:15);
end

nameID = T.Index;
% timeStamps = T.cumulStamps_offset;
timeStamps = T.cumulStamps;
% fileNums = T.fileNum;
% all_red_files = T.red_file_names;

[~, choose] = ismember(selected, nameID);

timeStamps_select = round(timeStamps(choose),1);
timeStamps_select = timeStamps_select - min(timeStamps_select);
timeStamps_str = cellstr(num2str(timeStamps_select));

% Make subplot

% TO DO: Add ability to make subplot (should make it more efficient for
% figure making)
figure(2)
subplot(1,num_films,1)
% hold on
colormap turbo

for i = 1:num_films
    subplot(1,num_films,i)
    film_plot = films_data{i};
    film_plot(~log_rad) = nan;
%     xx_box = xx < 0-max_rad & xx > max_rad;
%     yy_box = yy < 0-max_rad & yy > max_rad;
    yy_plot = 512-yy;
    
    sf = surf(xx(0-max_rad+center(1):0+max_rad+center(1),0-max_rad+center(1):0+max_rad+center(1)),...
        yy_plot(0-max_rad+center(1):0+max_rad+center(1),0-max_rad+center(1):0+max_rad+center(1)),...
        film_plot(0-max_rad+center(1):0+max_rad+center(1), 0-max_rad+center(1):0+max_rad+center(1)));
    sf.LineStyle = "none";

% Timestamp

if timestamp_fig == 1
    dim = [0.8 0.51 0.3 0.3];
%     textBox = strcat("frame num = ", red_fileNum{i});
if i == 1
    textBox = strcat("\Deltat =",timeStamps_str(i), " s");
else
    textBox = strcat(timeStamps_str(i), " s");
end
    an = annotation('textbox',dim,'String',textBox,'FitBoxToText','on');
    an.Units = 'centimeters';

    an.Position = [5*(i-1)+0.7 4.1 4 .8];
    an.FontSize = 14;
    an.FontWeight = 'bold';
    an.LineStyle = 'none';
end

    
    fig = gcf;
    fig.Units = 'centimeters';
    fig.Position = [10 10 (5*num_films)+3 5.1];
    fig.Color = 'white';

    ax = gca;

    ax.CLim = [0,120];

    ax.Units = 'centimeters';
    ax.Position = [5*(i-1) 0 5 5];

    ax.View = [0,80]; % Sets orientation of view
    ax.XColor = 'none';
    ax.YColor = 'none';
    ax.ZColor = 'none';
    ax.XGrid = 'off';
    ax.YGrid = 'off';
    ax.ZGrid = 'off';

    if i == num_films
        cb = colorbar;
        cb.Box = 'off';
        cb.TickDirection = 'out';
        cb.TickLength = 0.03;
        cb.FontSize = 14;
        cb.FontWeight = 'bold';
        cb.Limits = [0, 120];
        cb.Label.String = "h / nm";
        cb.Units = 'centimeters';
        cb.Position(1) = cb.Position(1)+ 2;
        cb.Position(2) = cb.Position(2)+ 0.5;
        cb.Position(3) = 0.3;
        cb.Position(4) = 4;
        cb.Ticks = [0 30 60 90 120];
    end
hold on

end
hold off
figure(1)
end

%% Save figure

if save_fig == 1

fig_type = "2Dimg_subplot";
print('-f1', '-r500','-dpng',...
strcat(save_folder,fig_type,identifier, ".png"));

fig_type = "3Dsurf_subplot";
print('-f2', '-r500','-dpng',...
strcat(save_folder,fig_type,identifier, ".png"));


end

