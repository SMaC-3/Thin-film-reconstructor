
%--------------------------------------------------------------------------
%% Info about user input settings
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
% folder = "/Volumes/T7/Thin films/MultiCam/CNC_dialysed/2p7wtCNC/2p7wtCNC_run5_globalExtrema_run4/";
% csvFile = "2p7wtCNC_run5_globalExtrema_run4_TimeStamps.csv";
folder = "/Volumes/T7/Thin films/MultiCam/CNC_dialysed/2p7wtCNC/2p7wtCNC_run3/";
csvFile = "2p7wtCNC_run3_TimeStamps.csv";

%--- For import of metrics

metrics_path_2D = fullfile(folder,"thin-films-2D-metrics/");
metrics_path_1D = fullfile(folder,"thin-films-1D-metrics/");

viridis_3 = flip([180, 222, 44; 49, 104, 142; 68, 1, 84]./255);
% plasma_4 = ([247, 148, 31; 184, 46, 101; 83, 0, 152; 4, 0, 117]./255);
plasma_4 = ([247, 148, 31; 184, 46, 101;...
    119, 0, 148; 4, 0, 117]./255);


colour_I = 3;
colour = plasma_4(colour_I,:);

%---Index of files to be procesed-----------------------------
selected_2D = [];
% selected_1D = [130:10:400];
selected_1D = [110,120,130:5:170];
% selected = 0;
save_check = 1; % 1 = save info, 0 = do not save info 
save_descriptor = "";

fit_vol = 1;

%--- Plot fitted metrics 

plot_fit = 1;

 metrics_paths =...
       ["/Volumes/T7/Thin films/MultiCam/CNC_dialysed/3p5wtCNC/3p5wtCNC_ru4/thin-films-metrics-fit/"];

%% Get metrics

% Import from file
if isempty(selected_2D) ~= 1
[T_metrics_2D, metrics_files_2D, ~] =...
    findFile_2D_metrics(metrics_path_2D, selected_2D);
end

if isempty(selected_1D) ~= 1
[T_metrics_1D, metrics_files, num_metrics] =...
    findFile_2D_metrics(metrics_path_1D, selected_1D);
end
%% Plot
 
if isempty(selected_1D) ~= 1
    
    timeStamps_1D = T_metrics_1D.("Time_stamps_(s)");
    rim_h = T_metrics_1D.("Rim_h_(nm)");
    center_h = T_metrics_1D.("Center_h_(nm)");
    dimp_vol_1D = T_metrics_1D.("Dimple_vol_(micron^3)");

else
    timeStamps_1D = [];
    dimp_vol_1D = [];
end

if isempty(selected_2D) ~= 1 
timeStamps_2D = T_metrics_2D.("Time_stamps_(s)");
dimp_vol_2D = T_metrics_2D.("Dimple_vol_(micron^3)");

else
    timeStamps_2D = [];
    dimp_vol_2D = [];
end

%--------------------------------------------------------------
% figure(1)
% hold on
% scatter(timeStamps_1D,center_h,'filled')
% % hold on
% scatter(timeStamps_1D,rim_h,'filled')
% % yyaxis right
% % scatter(timeStamps_1D,dimp_vol_1D,'filled')
% % hold on
% timeStamps = [timeStamps_1D ; timeStamps_2D];
% dimp_vol = [dimp_vol_1D ; dimp_vol_2D];
% yyaxis right
% scatter(timeStamps, dimp_vol,'filled')



% lg = legend;
% lg.String = {"Center h", "Rim h", "Dimple volume"};
% lg.Box = 'off';

% Shifting initial timestamp to zero for relative comparison

% scatter(timeStamps...
%     -min(timeStamps),...
%     center_h, 'filled')

%--------------------------------------------------------------
figure(2)
hold on
scatter(timeStamps_1D, dimp_vol_1D,'filled',...
    'SizeData',50, 'MarkerFaceColor',colour,...
    'MarkerEdgeColor','none')

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
ax.TickDir = 'out';


xlabel('Time / s','FontWeight','bold');
ylabel('Film volume / \mum^3','FontWeight','bold');



%% Fit volume change

if fit_vol == 1

timeStamps = [timeStamps_1D ; timeStamps_2D];
dimp_vol = [dimp_vol_1D ; dimp_vol_2D];

prompt_limit = "Please provide time when step-wise volume change occurs: ";
ub_time = input(prompt_limit);

[~, ub_time_I] = min(abs(timeStamps - ub_time));

f_dimp =...
    fit(timeStamps(2:ub_time_I), dimp_vol(2:ub_time_I),'exp1');

% f_dimp =...
%     fit(timeStamps(2:end), dimp_vol(2:end),'exp1');


figure(3)
hold on
plot(f_dimp, timeStamps, dimp_vol)

if save_check == 1

     metrics_fit_folder = 'thin-films-metrics-fit/';

    if exist(fullfile(folder,metrics_fit_folder),"dir") == 0
        mkdir(fullfile(folder,metrics_fit_folder));
    end

    metrics_path = fullfile(folder, metrics_fit_folder);

    % General fit detail
    fit_detail = {'Metrics data folder: ',folder,'';
        'Model:',type(f_dimp),formula(f_dimp);
        'min/max time',timeStamps(1),timeStamps(end);
        'coefficients','95% confidence int lower','95% confidence int upper'};

    % Red fit info
    covals_dimp = coeffvalues(f_dimp).';
    conint_dimp = confint(f_dimp).';
    fit_tab_dimp = table(covals_dimp, conint_dimp(:,1),conint_dimp(:,2),...
        'VariableNames',{'covals','conint_1','conint_2'});
    cellSave_dimp = [fit_detail; table2cell(fit_tab_dimp)];
    writecell(cellSave_dimp,fullfile(metrics_path,...
        "dimp_vol_fit_info.txt") , 'Delimiter', '\t');
    
    print('-f2', '-r300','-dpng', fullfile(metrics_path,"vol_fit.png"));


    vol_f = f_dimp(timeStamps);
    T_vol = table(timeStamps, round(dimp_vol,4), round(vol_f,4),'VariableNames',...
        ["Timestamps", "Dimple_volume", "Fitted_volume"]);
    writetable(T_vol, fullfile(metrics_path, "dimp_vol_data.txt"),...
        'Delimiter','\t')

end

end

%% Plot fitted metrics


if plot_fit == 1

T_vol = cell(length(metrics_paths),1);

for j = 1:length(metrics_paths)

T_vol{j} = readtable(fullfile(metrics_paths(j), "dimp_vol_data.txt"));

end


% Colour blind palette
pal = {'#000000','#004949','#009292','#ff6db6','#ffb6db','#490092',...
    '#006ddb','#b66dff','#6db6ff','#b6dbff','#920000',...
    '#924900','#db6d00','#24ff24','#ffff6d'};

pal_line = {'#00ff00','#ffb3b3', '#b366ff','#000000'};
figure(4)
hold on

for j = 1:length(metrics_paths)
str = pal{j*2};
color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
if j==2
scatter(T_vol{j}.Timestamps-36, T_vol{j}.Dimple_volume,'filled',...
    'MarkerFaceColor',color, 'SizeData',70)
else
    scatter(T_vol{j}.Timestamps, T_vol{j}.Dimple_volume,'filled',...
    'MarkerFaceColor',color, 'SizeData',70)
end
end

for j = 1:length(metrics_paths)
[~,lim] = min(abs(T_vol{j}.Fitted_volume - 2950));
str = pal_line{j};
color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
if j == 2
plot(T_vol{j}.Timestamps(1:lim)-36, T_vol{j}.Fitted_volume(1:lim),...
    'Color',color, 'LineWidth', 2)
else 
    plot(T_vol{j}.Timestamps(1:lim), T_vol{j}.Fitted_volume(1:lim),...
    'Color',color, 'LineWidth', 2)
end
end

ax = gca;
fig = gcf;

% Axis scaling

ax.XScale = 'linear';
ax.YScale = 'linear';

% ax.XLim = [0,400];
% ax.YLim = [0,80];

% Axis title
ax.XLabel.String = "Time / s";
ax.YLabel.String = "Dimple volume / \mu m^3";


% Axis Line
ax.LineWidth = 1.5;

% Axis font
ax.FontSize = 16;
ax.FontWeight = 'bold';
ax.FontName = 'Arial';

ax.TickDir = "out";

ax.Box = 'off';

% fig color
fig.Color = 'white';
fig.Units = 'centimeters';

   
lg = legend;
% lg.String = {"100 \mum/s", "50 \mum/s", "20 \mum/s"};
lg.String = {"50 mM", "100 mM", "150 mM"};
lg.Box = 'off';

end
