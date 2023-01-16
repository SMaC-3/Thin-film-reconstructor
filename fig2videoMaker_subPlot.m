close all
clearvars -except folder

%--------------------------------------------------------------
%% Input settings - USER TO MODIFY
%--------------------------------------------------------------

% Main branch for data
folder = "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_run3/";

% Image and film source sub-folders and paths
red_img_folder = "red-surfFit-WBcor-tiff/";

red_film_folder = "thin-films-line/";
identifier = "-lineInt-0";
video_descriptor = "";

red_img_path = fullfile(folder, red_img_folder);
red_film_path = strcat(folder,red_film_folder,"red-1D",identifier,...
    "-films/");

% Timestamps + files details csv
csvFile = "150mM_SDS_run3_TimeStamps.csv";

% Image files to be included in video
selected = [120:420].';

% Info re line extraction for line plot overlay

center = [257, 255];
max_rad = 250;
angle = 0;
angle_adjust = 360-angle;

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

% Point for line overlay
x = [center(1), center(1) + max_rad * cosd(angle_adjust)];
y = [center(2), center(2) + max_rad * sind(angle_adjust)];

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
all_films_struct = dir(fullfile(red_film_path, '*.txt'));
all_films_cell = struct2cell(all_films_struct).';
all_films_names = all_films_cell(:,1);
file_parts = split(all_films_names, {'-'});
file_num = str2double(file_parts(:,4));
[~, selected_I] = ismember(selected, file_num);

red_files = all_films_names(selected_I);

% disp("Select red thin film data");
% [red_files, red_img_path] = uigetfile(strcat(folder,'*.txt'),...
%     'Select the subtracted red-files', 'MultiSelect','on');

if iscell(red_files) == 0
    red_files = {red_files};
end

radius = cell(size(red_files,2),1);
red_film = cell(size(red_files,2),1);
red_fileNum = cell(size(red_files,2),1);

% %% Import data

for i = 1:max(size(red_files))
    % red correction
    T_red = importdata(strcat(red_film_path, red_files{i}),'\t',1);
    radius{i} = T_red.data(:,1);
    red_film{i} = T_red.data(:,2);
    red_parts = split(red_files{i}, '-');
    red_fileNum{i} = red_parts{4};

end

%% Prepare video object

video_name = strcat(folder,'videos/',folder_parts{end-1},identifier,video_descriptor, ".mp4");
writerObj = VideoWriter(video_name, 'MPEG-4');
writerObj.FrameRate = 5;
open(writerObj);

%% Plot and make video

timeStamps = T.cumulStamps;
fileNums = T.fileNum;
red_fileNum_convert = cellfun(@str2num, red_fileNum);
[~, fileNums_I] = ismember(red_fileNum_convert, fileNums);
timeStamps_select = round(timeStamps(fileNums_I),2);
timeStamps_str = cellstr(num2str(timeStamps_select));

alpha = [0.2, 0.5, 0.8];
rgb_control = linspace(0,1,max(size(red_files)));

for i = 2:max(size(red_files))-1
%         figure('visible','off')
    
    subplot(1,2,1)
    imshow(red_img_data{i})
    hold on
    lh = plot(x,y,'LineWidth',5,'Color',...
        [rgb_control(i),0,1-rgb_control(i)]);
    lh.Color = [lh.Color, 0.1];

    subplot(1,2,2)

    scatter(radius{i}, red_film{i},'filled','MarkerFaceColor',...
        [rgb_control(i),0,1-rgb_control(i)])
    
    hold on
    fig = gcf;
    fig.Units = 'centimeters';
    fig.Position = [6.5617 55.7742 35.7364 20.0731];
    fig.Color = 'white';

    ax = gca;
    ax.Units = 'centimeters';
    ax.Position = [20.0378 5.0447 14.7108 10.9783];
    ax.LineWidth = 1.5;
    ax.XColor = 'k';
    ax.YColor = 'k';
    ax.FontName = 'Helvetica';
    ax.FontSize = 18;
    ax.FontWeight = 'bold';
    ax.Box= 'off';
    ax.YLim = [0, 120];


    xlabel('Film radius (\mum)','FontWeight','bold');
    ylabel('Film thickness (nm)','FontWeight','bold');

    %     plot(radius{i}, red_int{i}, 'red','LineWidth',1.5)

    dim = [0.8 0.51 0.3 0.3];
%     textBox = strcat("frame num = ", red_fileNum{i});
    textBox = strcat("Timestamp: ", timeStamps_str(i), " s");
    an = annotation('textbox',dim,'String',textBox,'FitBoxToText','on');
    an.FontSize = 16;
    an.FontWeight = 'bold';
    an.LineStyle = 'none';
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




