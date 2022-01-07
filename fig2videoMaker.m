close all
clearvars -except folder

folder = '/Volumes/ZIGGY/Thin films/MultiCam/Xgum/600ppm_Xgum/600ppm_Xgum_0p1mMKCl_0p2umF_run10/';

folder_parts = split(folder, '/');

if ~exist(folder,'dir')
    folder = pwd;
end
disp("Select red intensity data");
[red_files, red_path] = uigetfile(strcat(folder,'*.txt'),...
    'Select the subtracted red-files', 'MultiSelect','on');
disp("Select blue intensity data");
[blue_files, blue_path] = uigetfile(strcat(folder,'*.txt'),...
    'Select the subtracted blue-files', 'MultiSelect','on');

if iscell(red_files) == 0
    red_files = {red_files};
end

if iscell(blue_files) == 0
    blue_files = {blue_files};
end
    radius = cell(size(red_files,2),1);
    red_int = cell(size(red_files,2),1);
    red_fileNum = cell(size(red_files,2),1);
%     red_I_max = cell(size(red_files,2),1);
    blue_int = cell(size(red_files,2),1);
%     blue_I_min = cell(size(red_files,2),1);
%     blue_I_max = cell(size(red_files,2),1);

video_name = strcat(folder,folder_parts{end-1}, ".mp4");
writerObj = VideoWriter(video_name, 'MPEG-4');
writerObj.FrameRate = 10;
open(writerObj);


for i = 1:size(red_files,2)
        % red correction
        T_red = importdata(strcat(red_path, red_files{i}),'\t',8);
        radius{i} = T_red.data(:,2);
        red_int{i} = T_red.data(:,3);
        red_parts = split(red_files{i}, '-');
        red_fileNum{i} = red_parts{3};
        
        % blue correction
        T_blue = importdata(strcat(blue_path, blue_files{i}),'\t',8);
        blue_int{i} = T_blue.data(:,3);
        
end

max_int = round(max([max(cellfun(@max, red_int)); max(cellfun(@max, blue_int))]),-3);
% min_int = 10^(floor( 10* log10(min([min(cellfun(@min, red_int)); min(cellfun(@min, blue_int))])))/10  );

min_int = (floor( (min([min(cellfun(@min, red_int)); min(cellfun(@min, blue_int))]))/1000 ) *1000 );


for i = 1:size(red_files,2)
    figure('visible','off')
    plot(radius{i}, blue_int{i}, 'blue','LineWidth',1.5)
    hold on
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
    ax.YLim = [min_int, max_int];
    
    
    xlabel('Film radius (\mum)','FontWeight','bold');
    ylabel('Intensity (A.U)','FontWeight','bold');
    plot(radius{i}, red_int{i}, 'red','LineWidth',1.5)
    
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












