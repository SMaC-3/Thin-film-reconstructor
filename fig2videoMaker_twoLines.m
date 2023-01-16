close all
clearvars -except folder

%--------------------------------------------------------------
% Input settings - USER TO MODIFY
%--------------------------------------------------------------

folder = "/Volumes/T7/Thin films/MultiCam/SDS/100mM_SDS/100mM_SDS_run4/";

folder_parts = split(folder, '/');
identifier = "-azimuthal";



if ~exist(folder,'dir')
    folder = pwd;
end

disp("Select red thin film data");
[red_files, red_path] = uigetfile(strcat(folder,'*.txt'),...
    'Select the subtracted red-files', 'MultiSelect','on');

disp("Select red thin film data");
[red_files_2, red_path_2] = uigetfile(strcat(folder,'*.txt'),...
    'Select the subtracted red-files', 'MultiSelect','on');


if iscell(red_files) == 0
    red_files = {red_files};
end


    radius = cell(size(red_files,2),1);
    red_film = cell(size(red_files,2),1);
    red_fileNum = cell(size(red_files,2),1);

    radius_2 = cell(size(red_files,2),1);
    red_film_2 = cell(size(red_files,2),1);
    

video_name = strcat(folder,folder_parts{end-1},identifier, ".mp4");
writerObj = VideoWriter(video_name, 'MPEG-4');
writerObj.FrameRate = 10;
open(writerObj);


for i = 1:size(red_files,2)
        % red correction
        T_red = importdata(strcat(red_path, red_files{i}),'\t',1);
        radius{i} = T_red.data(:,1);
        red_film{i} = T_red.data(:,2);
        red_parts = split(red_files{i}, '-');
        red_fileNum{i} = red_parts{4};
        
        T_red_2 = importdata(strcat(red_path_2, red_files_2{i}),'\t',1);
        radius_2{i} = T_red_2.data(:,1);
        red_film_2{i} = T_red_2.data(:,2);
        % blue correction
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

for i = 2:size(red_files,2)-1
%     figure('visible','off')
    scatter(radius{i-1}, red_film{i-1},'filled','MarkerFaceColor',...
        [rgb_control(i-1),0,1-rgb_control(i-1)],'MarkerFaceAlpha',alpha(1))
    hold on
    scatter(radius_2{i}, red_film_2{i},'filled','MarkerFaceColor',...
        [rgb_control(i),0,1-rgb_control(i)],'MarkerFaceAlpha',alpha(2))
%     scatter(radius{i+1}, red_film{i+1},'filled','MarkerFaceColor',...
%         [rgb_control(i+1),0,1-rgb_control(i+1)],'MarkerFaceAlpha',alpha(3))
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
    ax.YLim = [0, 200];
    
    
    xlabel('Film radius (\mum)','FontWeight','bold');
    ylabel('Film thickness (nm)','FontWeight','bold');
    
%     plot(radius{i}, red_int{i}, 'red','LineWidth',1.5)
    
    dim = [0.6 0.6 0.3 0.3];
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












