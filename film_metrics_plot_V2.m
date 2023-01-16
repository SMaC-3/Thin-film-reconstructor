
%--------------------------------------------------------------------------
%% Info about user input settings
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
% folder = "/Volumes/T7/Thin films/MultiCam/CNC_dialysed/2p7wtCNC/2p7wtCNC_run5_globalExtrema_run4/";
% csvFile = "2p7wtCNC_run5_globalExtrema_run4_TimeStamps.csv";
% folder = "/Volumes/T7/Thin films/MultiCam/CNC_dialysed/2p7wtCNC/2p7wtCNC_run3/";
% csvFile = "2p7wtCNC_run3_TimeStamps.csv";Z

 metrics_paths =...
       ["/Volumes/T7/Thin films/MultiCam/CNC_dialysed/3p5wtCNC/3p5wtCNC_run4/thin-films-1D-metrics/"];

%--- For import of metrics

% metrics_path_1D = fullfile(folder,"thin-films-1D-metrics/");

viridis_3 = flip([180, 222, 44; 49, 104, 142; 68, 1, 84]./255);
% plasma_4 = ([247, 148, 31; 184, 46, 101; 83, 0, 152; 4, 0, 117]./255);

plasma_3 = ([184, 46, 101;...
    119, 0, 148; 4, 0, 117]./255);
plasma_4 = ([247, 148, 31; 184, 46, 101;...
    119, 0, 148; 4, 0, 117]./255);

% colour_I = 3;
% colour = plasma_4(colour_I,:);

%---Index of files to be procesed-----------------------------
selected_2D = [];
% selected_1D = [130:10:400];
selected_1D = [];
% selected = 0;
save_check = 1; % 1 = save info, 0 = do not save info 
save_descriptor = "";

%% Get metrics

metrics = cell(length(metrics_paths));

for i = 1:length(metrics_paths)
    metrics_path_1D = metrics_paths(i);
    [T_metrics_1D, metrics_files, num_metrics] =...
        findFile_2D_metrics(metrics_path_1D, selected_1D);
    metrics{i} = T_metrics_1D;
end
%% Plot
 for i = 1:length(metrics_paths)

    timeStamps_1D = metrics{i}.("Time_stamps_(s)");
    rim_h = metrics{i}.("Rim_h_(nm)");
    center_h = metrics{i}.("Center_h_(nm)");
    dimp_vol_1D = metrics{i}.("Dimple_vol_(micron^3)");
%--------------------------------------------------------------
figure(1)
fig = gcf;
ax = gca;
set_size = 75;
hold on
yyaxis left
ax.YColor = 'black';
scatter(timeStamps_1D,center_h,'filled',...
    'MarkerFaceColor',[25,56,81]/255,...
    'SizeData',set_size)
% hold on
scatter(timeStamps_1D,rim_h,'filled',...
    'MarkerFaceColor',[44,126,152]/255,...
    'SizeData',set_size)
% yyaxis right
% scatter(timeStamps_1D,dimp_vol_1D,'filled')
% hold on
% timeStamps = [timeStamps_1D ; timeStamps_2D];
% dimp_vol = [dimp_vol_1D ; dimp_vol_2D];
yyaxis right
scatter(timeStamps_1D, dimp_vol_1D,'filled',...
    'MarkerFaceColor',[170,57,37]/255,...
    'SizeData',set_size)



fig.Color = 'white';

% ax.Units = 'centimeters';
ax.LineWidth = 1.5;
ax.XColor = 'k';
ax.YColor = 'k';
ax.FontName = 'Helvetica';
ax.FontSize = 18;
ax.FontWeight = 'bold';
ax.Box= 'off';
ax.TickDir = 'out';
ax.XScale = 'log';
ax.XLim(1) = 30;


xlabel('Time / s','FontWeight','bold');
yyaxis left
ylabel('Film thickness / nm','FontWeight','bold');
yyaxis right
ylabel('Film volume / \mum^3','FontWeight','bold');

lg = legend('Center thickness', 'Rim thickness', 'Film volume');
% lg.String = {"Center h", "Rim h", "Dimple volume"};
lg.Box = 'off';

% Shifting initial timestamp to zero for relative comparison

% scatter(timeStamps...
%     -min(timeStamps),...
%     center_h, 'filled')

%--------------------------------------------------------------
% figure(2)
% hold on
% 
% if length(metrics_paths) == 3
% 
%     colour = plasma_3(i,:);
% 
% else
% 
%     colour = plasma_4(i,:);
% 
% end
% 
% 
% 
% scatter(timeStamps_1D, dimp_vol_1D,'filled',...
%     'SizeData',50, 'MarkerFaceColor',colour,...
%     'MarkerEdgeColor','none')
% 
% fig = gcf;
% ax = gca;
% 
% fig.Color = 'white';
% 
% % ax.Units = 'centimeters';
% ax.LineWidth = 1.5;
% ax.XColor = 'k';
% ax.YColor = 'k';
% ax.FontName = 'Helvetica';
% ax.FontSize = 18;
% ax.FontWeight = 'bold';
% ax.Box= 'off';
% ax.TickDir = 'out';
% 
% 
% xlabel('Time / s','FontWeight','bold');
% ylabel('Film volume / \mum^3','FontWeight','bold');
% 

 end
