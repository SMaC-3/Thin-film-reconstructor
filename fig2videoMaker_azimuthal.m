close all
clearvars -except folder

folder = "/Volumes/T7/Thin films/MultiCam/Xgum/1000ppm_Xgum/1000ppm_Xgum_0p1mMKCl_0p2umF_run9/";

folder_parts = split(folder, '/');
identifier = "-azimuthal";

if ~exist(folder,'dir')
    folder = pwd;
end
disp("Select azimuthal intensity data");
[red_files, red_path] = uigetfile(strcat(folder,'*.txt'),...
    'Select azimuthal intensity data', 'MultiSelect','on');
[red_files_2, red_path_2] = uigetfile(strcat(folder,'*.txt'),...
    'Select azimuthal intensity data', 'MultiSelect','on');
[red_files_3, red_path_3] = uigetfile(strcat(folder,'*.txt'),...
    'Select azimuthal intensity data', 'MultiSelect','on');

disp("Select interferometry images");
[red_imgs, red_imgs_path] = uigetfile(strcat(folder,'*.tiff'),...
    'Select interferometry images', 'MultiSelect','on');
% disp("Select blue intensity data");
% [blue_files, blue_path] = uigetfile(strcat(folder,'*.txt'),...
%     'Select the subtracted blue-files', 'MultiSelect','on');

if iscell(red_files) == 0
    red_files = {red_files};
end

radius_in = 70;
center = [261,256];
thx = 5;
theta = linspace(0, 2*pi, 314);
cx = (radius_in)*cos(theta)+center(1);
cy = (radius_in)*sin(theta)+center(2);
cxouter = (radius_in + thx)*cos(theta)+center(1);
cyouter = (radius_in + thx)*sin(theta)+center(2);


radius = cell(size(red_files,2),1);
red_film = cell(size(red_files,2),1);
red_fileNum = cell(size(red_files,2),1);

%     radius_2 = cell(size(red_files,2),1);
red_img = cell(size(red_files,2),1);

video_name = strcat(folder,folder_parts{end-1},identifier, ".mp4");
writerObj = VideoWriter(video_name, 'MPEG-4');
writerObj.FrameRate = 7;
open(writerObj);


for i = 1:size(red_files,2)
    % red correction
    T_red = importdata(strcat(red_path, red_files{i}),'\t',6);
    radius{i} = T_red.data(:,1);
    red_film{i} = T_red.data(:,3);
    red_parts = split(red_files{i}, '-');
    red_fileNum{i} = red_parts{3};

%     T_red_2 = importdata(strcat(red_path_2, red_files_2{i}),'\t',6);
%     radius_2{i} = T_red_2.data(:,1);
%     red_film_2{i} = T_red_2.data(:,3);
% 
%     T_red_3 = importdata(strcat(red_path_3, red_files_3{i}),'\t',6);
%     radius_3{i} = T_red_3.data(:,1);
%     red_film_3{i} = T_red_3.data(:,3);

    red_img{i} = imread(strcat(red_imgs_path, red_imgs{i}));

    %         T_red_2 = importdata(strcat(red_imgs_path, red_imgs{i}),'\t',1);
    %         radius_2{i} = T_red_2.data(:,1);
    %         red_film_2{i} = T_red_2.data(:,2);
    %         blue correction
    %         T_blue = importdata(strcat(blue_path, blue_files{i}),'\t',8);
    %         blue_int{i} = T_blue.data(:,3);

end
%
% max_int = round(max([max(cellfun(@max, red_int)); max(cellfun(@max, blue_int))]),-3);
% % min_int = 10^(floor( 10* log10(min([min(cellfun(@min, red_int)); min(cellfun(@min, blue_int))])))/10  );
%
% min_int = (floor( (min([min(cellfun(@min, red_int)); min(cellfun(@min, blue_int))]))/1000 ) *1000 );

alpha = [0.2, 0.5, 0.8];
rgb_control = linspace(0,1,size(red_files,2));

for i = 1:size(red_files,2)-1
    %     figure('visible','off')
    pos1 = [0, 0.2, 0.48, 0.48];
    subplot('Position',pos1)
%     subplot(1,2,1);
    imshow(red_img{i});
    hold on
    h1 = plot(cx,cy,'white','LineWidth',3); h1.Color(4)=0.5;

    pos2 = [0.5, 0.1, 0.4, 0.7];
    subplot('Position',pos2)
%     subplot(1,2,2)

    plot(radius{i}, red_film{i},'blue', 'LineWidth',2)
    hold on
%     plot(radius_2{i}, red_film_2{i},'red', 'LineWidth',2)
%     plot(radius_3{i}, red_film_3{i},'black', 'LineWidth',2)
    fig = gcf;
    fig.Position(3) = 840;
    fig.Position(4) = 630;
    ax = gca;

    fig.Color = 'white';

    % ax.Units = 'centimeters';
    ax.LineWidth = 1.5;
    ax.XColor = 'k';
    ax.YColor = 'k';
    ax.FontName = 'Helvetica';
    ax.FontSize = 16;
    ax.FontWeight = 'bold';
    ax.Box= 'off';
    ax.YLim = [48000, 58000];
    ax.XLim = [0,360];
    ax.XTick = [0, 90, 180, 270, 360];


    xlabel('Azimuthal angle (degrees)','FontWeight','bold');
    ylabel('Azimuthal intensity (A.U)','FontWeight','bold');

    %     plot(radius{i}, red_int{i}, 'red','LineWidth',1.5)

    dim = [0.7 0.5 0.3 0.3];
    textBox = strcat("frame num = ", red_fileNum{i});
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

