function [T_metrics] =...
    film_metrics_1D(T_film, radius_dimp_I,...
    folder,csvFile, selected, save_check)

%% Determine radius from center of film (as set above)
h_ave = mean(T_film.red_film(1:radius_dimp_I));

dimp_vol = (h_ave/1000)*pi*T_film.radius(radius_dimp_I)^2;
center_h = mean(T_film.red_film(1:15));
rim_h = T_film.red_film(radius_dimp_I);

csvRead = strcat(folder,csvFile);
T = readtable(csvRead, 'Delimiter',',');

nameID = T.Index;
timeStamps = T.cumulStamps;
% fileNums = T.fileNum;
all_red_files = T.red_file_names;

[~, choose] = ismember(selected, nameID);

timeStamps_select = timeStamps(choose);
red_files = all_red_files(choose);

T_metrics = table(timeStamps_select, rim_h, center_h, dimp_vol, h_ave,...
    'VariableNames',["Time_stamps_(s)", "Rim_h_(nm)",...
    "Center_h_(nm)",...
    "Dimple_vol_(micron^3)",...
    "Average_h_(nm)"]);

% figure()
% 
% scatter(timeStamps_select,center_h,'filled')
% hold on
% scatter(timeStamps_select,rim_h,'filled')
% yyaxis right
% scatter(timeStamps_select,dimp_vol,'filled')
% 
% lg = legend;
% lg.String = {"Center h", "Rim h", "Dimple volume"};
% lg.Box = 'off';

%%
if save_check == 1
    
    metrics_data_folder = 'thin-films-1D-metrics/';

    if exist(fullfile(folder,metrics_data_folder),"dir") == 0
        mkdir(fullfile(folder,metrics_data_folder));
    end

    metrics_path = fullfile(folder, metrics_data_folder);
%     parfor i = 1:max(size(red_files))
        general_info =...
            {'Date/time: ', string(datetime), '','','';...
            'File: ', red_files{1},'','','';...
            '', '','', '','';...
            'Radius (pixels): ', num2str(radius_dimp_I),'', '','';...
            '','' ,'','','';...
            'Conversion factor (pixels/micron): ', 0.896, '','','';...
%             '','','','';...
            'timeStamps','center_h_nm','rim_h_nm',...
            'dimp_vol_micron^3', 'ave_h_nm'};

        file_name_split = split(red_files,'-');
        
        file_name_metrics = strcat(file_name_split{1},'-',...
            file_name_split{2}, '-',file_name_split{3},...
            '-metrics.txt');

        full_metrics = fullfile(metrics_path,...
            file_name_metrics);

        cellSave = [general_info; ...
            {round(timeStamps_select,4), round(center_h,4),...
            round(rim_h,4) , round(dimp_vol,8), round(h_ave,4)}];
       
        writecell(cellSave, full_metrics, 'Delimiter', '\t');

%     end

end