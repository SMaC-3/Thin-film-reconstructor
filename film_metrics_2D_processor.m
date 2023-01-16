
%--------------------------------------------------------------------------
%% Info about user input settings
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
folder = "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_run1/";
csvFile = "150mM_SDS_run1_TimeStamps.csv";

img_folder = "red-surfFit-WBcor-tiff/";
img_path = fullfile(folder, img_folder);

film_folder  = "thin-films-2D/";
film_path = fullfile(folder, film_folder);

norm_path = fullfile(folder, "data-normalised-2D/");

% For import of metrics

metrics_path = "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_run1/thin-films-2D-metrics";

%---Index of files to be procesed-----------------------------
selected = [240:1:600];
% selected = 0;
save_check = 1; % 1 = save info, 0 = do not save info 
save_descriptor = "";

% Loop through multiple paths for comparison across concs &/or velocities 

loop_metrics = 1;

metrics_paths =...
   ["/Volumes/T7/Thin films/MultiCam/SDS/50mM_SDS/50mM_SDS_run2/thin-films-2D-metrics";...
    "/Volumes/T7/Thin films/MultiCam/SDS/100mM_SDS/100mM_SDS_run4/thin-films-2D-metrics";...
    "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_run2/thin-films-2D-metrics";...
    "/Volumes/T7/Thin films/MultiCam/SDS/240mM_SDS/240mM_SDS_run14/thin-films-2D-metrics"];

%    metrics_paths =...
%        ["/Volumes/T7/Thin films/MultiCam/SDS/240mM_SDS/240mM_SDS_run19/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/240mM_SDS/240mM_SDS_run14/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/240mM_SDS/240mM_SDS_run15/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/240mM_SDS/240mM_SDS_run16/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/240mM_SDS/240mM_SDS_run17/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/240mM_SDS/240mM_SDS_run18/thin-films-2D-metrics"];

%    metrics_paths =...
%        ["/Volumes/T7/Thin films/MultiCam/SDS/50mM_SDS/50mM_SDS_run1/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/50mM_SDS/50mM_SDS_run2/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/50mM_SDS/50mM_SDS_run3/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/50mM_SDS/50mM_SDS_run4/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/50mM_SDS/50mM_SDS_run5/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/50mM_SDS/50mM_SDS_run6/thin-films-2D-metrics"];

%    metrics_paths =...
%        ["/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_run1/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_run2/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_run3/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_run4/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_run5/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_run6/thin-films-2D-metrics"];

%    metrics_paths =...
%        ["/Volumes/T7/Thin films/MultiCam/SDS/100mM_SDS/100mM_SDS_run5/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/100mM_SDS/100mM_SDS_run4/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/100mM_SDS/100mM_SDS_run1/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/100mM_SDS/100mM_SDS_run7/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/100mM_SDS/100mM_SDS_run6/thin-films-2D-metrics";...
%        "/Volumes/T7/Thin films/MultiCam/SDS/100mM_SDS/100mM_SDS_run2/thin-films-2D-metrics"];


%% Get img data

[img_data, img_files, num_imgs] =...
    findFile(folder, img_path, csvFile, selected(end), "red");

%% Get film data

[norm_data, norm_files, ~] =...
    findFile_2D_norm(norm_path, selected);

[films_data, film_files, num_films] =...
    findFile_2D_films(film_path, selected);



%% Metrics - select film region

%TO DO: convert to function with optional input for data and file names
%that way an option to import data later to derive metrics can be built in

% % Find center of film
% BW = imbinarize(img_data{end});
% % BW = imbinarize(red_data{round(end/2)});
% imshow(BW);
% roi = drawcircle;
% roi.LineWidth = 0.5;
% input('Press enter to continue: ');
% center_circ = round(roi.Center);
% radius_circ = round(roi.Radius);

% Find center of film

disp('1: Accept center and radius')
disp('2: Draw circle')
disp('3: Manually supply center and radius')

action_input = 'Please select an option: ';
action_select = input(action_input);
while isempty(action_select)
    action_select = input(action_input);
end

while action_select~=1

    if action_select == 2

        BW = imbinarize(img_data{end});
        % BW = imbinarize(red_data{round(end/2)});
        imshow(BW);
        roi = drawcircle;
        roi.LineWidth = 0.5;
        input('Press enter to continue: ');
        center_circ = round(roi.Center);
        radius_circ = round(roi.Radius);

    elseif action_select == 3

        center_input = 'Please enter center co-ordinates: ';
        center_circ = input(center_input);
        while isempty(center_circ)
            center_circ = input(center_input);
        end

        radius_input = 'Please enter radius: ';
        radius_circ = input(radius_input);
        while isempty(radius_circ)
            radius_circ = input(radius_input);
        end

%             figure()
%         BW = imbinarize(img_data{end});
%         % BW = imbinarize(red_data{round(end/2)});
%         imshow(BW);
%         viscircles(center_circ, radius_circ);
    end
    
    disp('1: Accept center and radius')
    disp('2: Draw circle')
    disp('3: Manually supply center and radius')

    action_input = 'Please select an option: ';
    action_select = input(action_input);
    while isempty(action_select)
        action_select = input(action_input);
    end
end

%% Get metrics

% Calculate from data and save (optional)

[T_metrics] =...
    film_metrics_2D(films_data, norm_data, radius_circ, center_circ,...
    folder, csvFile, selected, save_check);


% Import from file

% [T_metrics, metrics_files, num_metrics] =...
%     findFile_2D_metrics(metrics_path, selected);

%% Plot
 
figure()
timeStamps = T_metrics.("Time_stamps_(s)");
rim_h = T_metrics.("Rim_h_(nm)");
center_h = T_metrics.("Center_h_(nm)");
dimp_vol = T_metrics.("Dimple_vol_(micron^3)");

scatter(timeStamps,center_h,'filled')
hold on
scatter(timeStamps,rim_h,'filled')
yyaxis right
scatter(timeStamps,dimp_vol,'filled')

lg = legend;
lg.String = {"Center h", "Rim h", "Dimple volume"};
lg.Box = 'off';

% Shifting initial timestamp to zero for relative comparison

% scatter(timeStamps...
%     -min(timeStamps),...
%     center_h, 'filled')


%% Loop


if loop_metrics == 1


for j = 1:length(metrics_paths)


    [T_metrics, metrics_files, num_metrics] =...
        findFile_2D_metrics(metrics_paths(j), 0);
    all_metrics{j} = T_metrics;
    path_split = split(metrics_paths(j),'/');
    sample_split = split(path_split{end-1},'_');


    label_string{j} = strcat(sample_split(1), " ",...
        sample_split(2));



end
% cmap = turbo;
% colors = cmap([1:floor(length(cmap)/length(metrics_paths)):256],:);
colors = magma(length(metrics_paths));
figure()
hold on

for j = 1:length(metrics_paths)
    center_h_mod = all_metrics{j}.("Center_h_(nm)");
    A = center_h_mod > 80;
    [~,B] = min(abs(center_h_mod-80));
    center_h_mod(A) = nan;


%     if j~=3
% scatter(all_metrics{j}.("Time_stamps_(s)")...
%         -min(all_metrics{j}.("Time_stamps_(s)"))+ 0*(j-1),...
%         center_h_mod, 'filled', 'MarkerFaceColor',colors(j,:),...
%         'MarkerEdgeColor','none')

% scatter(all_metrics{j}.("Time_stamps_(s)"),...
%         center_h_mod, 'filled', 'MarkerFaceColor',colors(j,:),...
%         'MarkerEdgeColor','none')
% %     else
% scatter(all_metrics{j}.("Time_stamps_(s)")...
%         -min(all_metrics{j}.("Time_stamps_(s)"))+ 150*(j-1),...
%         center_h_mod, 'filled', 'MarkerFaceColor',colors(j,:),...
%         'MarkerEdgeColor','none')
% 
%     end

% 
% 
%     scatter(all_metrics{j}.("Time_stamps_(s)")...
%         -min(all_metrics{j}.("Time_stamps_(s)"))+ 100*(j-1),...
%         all_metrics{j}.("Center_h_(nm)"), 'filled')

%         scatter(all_metrics{j}.("Time_stamps_(s)"),...
%         all_metrics{j}.("Center_h_(nm)"), 'filled')
scatter(all_metrics{j}.("Time_stamps_(s)")...
        -min(all_metrics{j}.("Time_stamps_(s)")(B)),...
        center_h_mod, 'filled', 'MarkerFaceColor',colors(j,:),...
        'MarkerEdgeColor','none')

end

lg = legend;
lg.String = label_string;
lg.Box = 'off';

hold on
ax = gca;
fig = gcf;

% Axis scaling

ax.XScale = 'linear';
ax.YScale = 'linear';

ax.XLim = [0,400];
ax.YLim = [0,80];

% Axis title
ax.XLabel.String = "Time / s";
ax.YLabel.String = "Center thickness / nm";


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
% fig.Position(3:4) = [20.8, 27];
title("Center height")

%%% Plot rim h

figure()
hold on

for j = 1:length(metrics_paths)
    center_h_mod = all_metrics{j}.("Rim_h_(nm)");
    A = center_h_mod > 200;
    [~,B] = min(abs(center_h_mod-200));
    center_h_mod(A) = nan;
% 
% 
% %     if j~=3
% % scatter(all_metrics{j}.("Time_stamps_(s)")...
% %         -min(all_metrics{j}.("Time_stamps_(s)"))+ 0*(j-1),...
% %         center_h_mod, 'filled', 'MarkerFaceColor',colors(j,:),...
% %         'MarkerEdgeColor','none')
% 
% scatter(all_metrics{j}.("Time_stamps_(s)")...
%         -min(all_metrics{j}.("Time_stamps_(s)")(B)),...
%         center_h_mod, 'filled', 'MarkerFaceColor',colors(j,:),...
%         'MarkerEdgeColor','none')
%     else
% scatter(all_metrics{j}.("Time_stamps_(s)")...
%         -min(all_metrics{j}.("Time_stamps_(s)"))+ 150*(j-1),...
%         center_h_mod, 'filled', 'MarkerFaceColor',colors(j,:),...
%         'MarkerEdgeColor','none')
% 
%     end

% 
% 
%     scatter(all_metrics{j}.("Time_stamps_(s)")...
%         -min(all_metrics{j}.("Time_stamps_(s)"))+ 100*(j-1),...
%         all_metrics{j}.("Center_h_(nm)"), 'filled')

        scatter(all_metrics{j}.("Time_stamps_(s)"),...
        center_h_mod, 'filled')

end

lg = legend;
lg.String = label_string;
lg.Box = 'off';

hold on
ax = gca;
fig = gcf;

% Axis scaling

ax.XScale = 'linear';
ax.YScale = 'linear';

ax.XLim = [0,400];
ax.YLim = [0,80];

% Axis title
ax.XLabel.String = "Time / s";
ax.YLabel.String = "Rim thickness / nm";


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
% fig.Position(3:4) = [20.8, 27];
title("Rim height")
end




