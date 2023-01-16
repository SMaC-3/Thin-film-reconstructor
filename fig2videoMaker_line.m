close all
clearvars -except folder

%--------------------------------------------------------------
%% Input settings - USER TO MODIFY
%--------------------------------------------------------------

folder = "/Volumes/T7/Thin films/MultiCam/SDS/100mM_SDS/100mM_SDS_run4/";
csvFile = "100mM_SDS_run4_TimeStamps.csv";
csvRead = strcat(folder,csvFile);
T = readtable(csvRead, 'Delimiter',',');

folder_parts = split(folder, '/');
identifier = "-lineInt-228_V2";

% TO DO: add timestamps via csv

%--------------------------------------------------------------
% Input settings - USER TO MODIFY
%--------------------------------------------------------------

%% Select data
if ~exist(folder,'dir')
    folder = pwd;
end

disp("Select red thin film data");
[red_files, red_path] = uigetfile(strcat(folder,'*.txt'),...
    'Select the subtracted red-files', 'MultiSelect','on');

if iscell(red_files) == 0
    red_files = {red_files};
end

radius = cell(size(red_files,2),1);
red_film = cell(size(red_files,2),1);
red_fileNum = cell(size(red_files,2),1);

%% Import data

for i = 1:size(red_files,2)
    % red correction
    T_red = importdata(strcat(red_path, red_files{i}),'\t',1);
    radius{i} = T_red.data(:,1);
    red_film{i} = T_red.data(:,2);
    red_parts = split(red_files{i}, '-');
    red_fileNum{i} = red_parts{4};

end

%% Prepare video object

video_name = strcat(folder,'videos/',folder_parts{end-1},identifier, ".mp4");
writerObj = VideoWriter(video_name, 'MPEG-4');
writerObj.FrameRate = 10;
open(writerObj);

%% Plot and make video

timeStamps = T.cumulStamps;
fileNums = T.fileNum;
red_fileNum_convert = cellfun(@str2num, red_fileNum);
[~, fileNums_I] = ismember(red_fileNum_convert, fileNums);
timeStamps_select = round(timeStamps(fileNums_I),2);
timeStamps_str = cellstr(num2str(timeStamps_select));

alpha = [0.2, 0.5, 0.8];
rgb_control = linspace(0,1,size(red_files,2));

for i = 2:size(red_files,2)-1
    %     figure('visible','off')

    scatter(radius{i}, red_film{i},'filled','MarkerFaceColor',...
        [rgb_control(i),0,1-rgb_control(i)])

    fig = gcf;
    ax = gca;

    fig.Color = 'white';

    % ax.Units = 'centimeters';
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

    dim = [0.6 0.6 0.3 0.3];
%     textBox = strcat("frame num = ", red_fileNum{i});
    textBox = strcat("Timestamp = ", timeStamps_str(i), " s");
    an = annotation('textbox',dim,'String',textBox,'FitBoxToText','on');
    an.FontSize = 14;
    hold off

    frame = getframe(gcf);
    writeVideo(writerObj, frame);
    delete(findall(gcf,'type','annotation'))
    if mod(i, 50) == 0
        disp(strcat("frame ", string(i), " of ", string(size(red_files,2))));
    end
    %     close(figure(1))
end

close(writerObj);




