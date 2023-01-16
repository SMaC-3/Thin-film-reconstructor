close all
clearvars -except folder

%--------------------------------------------------------------
%% Input settings - USER TO MODIFY
%--------------------------------------------------------------

% Main branch for data
folder = "/Volumes/T7/Thin films/MultiCam/SDS/100mM_SDS/100mM_SDS_run4/";

% Timestamps + files details csv
csvFile = "100mM_SDS_run4_TimeStamps.csv";

% Image and film source sub-folders and paths
red_img_folder = "red-surfFit-WBcor-tiff/";

red_film_folder = "thin-films-2D/";
identifier = "-thin-films-2D";
video_descriptor = "";

red_img_path = fullfile(folder, red_img_folder);
red_film_path = fullfile(folder, red_film_folder);

% Image files to be included in video
selected = [340:10:650].';

% Info re line extraction for line plot overlay

center = [261	258	]; 
max_rad = 186;

%--------------------------------------------------------------
% End User defined input settings
%--------------------------------------------------------------

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

% Make folder for videos

if exist(fullfile(folder,"videos"),'dir') == 0
    mkdir(fullfile(folder, "videos"));
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%% Define table info and import image data
%--------------------------------------------------------------------------
nameID = T.Index;
red_names = T.red_file_names;
num_imgs = length(selected);
choose = zeros(num_imgs,1);
for i = 1:length(selected)
    choose(i) = find(nameID==selected(i));
end
red_img_files = {red_names{choose}};
red_img_data = cell(num_imgs,1);
parfor i =1:num_imgs
   red_img_data{i} = imread(fullfile(red_img_path, red_img_files{i})); 
end

%% Import film data

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

%% Prepare video object

video_name = strcat(folder,'videos/',folder_parts{end-1},identifier,video_descriptor, ".mp4");
writerObj = VideoWriter(video_name, 'MPEG-4');
writerObj.FrameRate = 5;
open(writerObj);

%% Plot and make video

timeStamps = T.cumulStamps;
% fileNums = T.fileNum;
% red_fileNum_convert = cellfun(@str2num, red_fileNum);
% [~, fileNums_I] = ismember(red_fileNum_convert, fileNums);
% timeStamps_select = round(timeStamps(fileNums_I),2);
% timeStamps_str = cellstr(num2str(timeStamps_select));

alpha = [0.2, 0.5, 0.8];
rgb_control = linspace(0,1,max(size(red_files)));

for i = 2:max(size(red_files))-1
%         figure('visible','off')
    colormap turbo
    subplot(1,2,1)
    imshow(red_img_data{i})
    hold on

    subplot(1,2,2)
    film_plot = films_data{i};
    film_plot(~log_rad) = nan;
%     contour3(xx,512-yy,film_plot,50);
    sf = surf(xx,512-yy,film_plot);
    sf.LineStyle = "none";
%     colormap jet
    cb = colorbar;
    cb.Box = 'off';
    cb.TickDirection = 'out';
    cb.FontSize = 12;
    cb.FontWeight = 'bold';
    cb.Limits = [0, 120];
    cb.Label.String = "h / nm";

%     scatter(radius{i}, red_film{i},'filled','MarkerFaceColor',...
%         [rgb_control(i),0,1-rgb_control(i)])
    
    hold on
    fig = gcf;
    fig.Units = 'centimeters';
    fig.Position = [6 56 40 20];
    fig.Color = 'white';

    ax = gca;

    ax.CLim = [0,120];
   
    ax.Units = 'centimeters';
    ax.Position = [20 2.5 15 15];
    
    ax.View = [0,80]; % Sets orientation of view
    ax.XColor = 'none';
    ax.YColor = 'none';
    ax.ZColor = 'none';
    ax.XGrid = 'off';
    ax.YGrid = 'off';
    ax.ZGrid = 'off';

%     ax.ZLim = [0,120];
%     ax.LineWidth = 1.5;
%     ax.XColor = 'k';
%     ax.YColor = 'k';
%     ax.FontName = 'Helvetica';
%     ax.FontSize = 18;
%     ax.FontWeight = 'bold';
    ax.Box= 'off';
%     ax.YLim = [0, 120];


%     xlabel('Film radius (\mum)','FontWeight','bold');
%     ylabel('Film thickness (nm)','FontWeight','bold');

    %     plot(radius{i}, red_int{i}, 'red','LineWidth',1.5)

%     dim = [0.8 0.51 0.3 0.3];
% %     textBox = strcat("frame num = ", red_fileNum{i});
%     textBox = strcat("Timestamp: ", timeStamps_str(i), " s");
%     an = annotation('textbox',dim,'String',textBox,'FitBoxToText','on');
%     an.FontSize = 16;
%     an.FontWeight = 'bold';
%     an.LineStyle = 'none';
    hold off

    frame = getframe(gcf);
    writeVideo(writerObj, frame);
    delete(findall(gcf,'type','annotation'))
    if mod(i, 50) == 0
        disp(strcat("frame ", string(i), " of ", string(max(size(red_files)))));
    end
    %     close(figure(1))
end

close(writerObj);




