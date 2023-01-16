
%--------------------------------------------------------------------------
%% Info about user input settings
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
folder = "/Volumes/T7/Thin films/MultiCam/SDS/240mM_SDS/240mM_SDS_run14/";
csvFile = "240mM_SDS_run14_TimeStamps.csv";

img_folder = "red-surfFit-WBcor-tiff/";
img_path = fullfile(folder, img_folder);

film_folder  = "thin-films-2D/";
film_path = fullfile(folder, film_folder);

norm_path = fullfile(folder, "data-normalised-2D/");
metrics_path = fullfile(folder, "thin-films-2D-metrics/");

%---Index of files to be procesed-----------------------------
selected = [300:1:650];
% selected = 0;
save_check = 1; % 1 = save info, 0 = do not save info 
save_descriptor = "";

%% Get film data

[norm_data, norm_files, ~] =...
    findFile_2D_norm(norm_path, selected);

% [films_data, film_files, num_films] =...
%     findFile_2D_films(film_path, selected);

%% Metrics - select film region

%TO DO: convert to function with optional input for data and file names
%that way an option to import data later to derive metrics can be built in

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
    film_metrics_2D([], norm_data, radius_circ, center_circ,...
    folder, csvFile, selected, save_check);


% Import from file
% 
% [T_metrics, metrics_files, num_metrics] =...
%     findFile_2D_metrics(metrics_path, selected);

%% Plot
 
figure()
timeStamps = T_metrics.("Time_stamps_(s)");
rim_h = T_metrics.("Rim_h_(nm)");
center_h = T_metrics.("Center_h_(nm)");
dimp_vol = T_metrics.("Dimple_vol_(micron^3)");
ave_h = T_metrics.("Average_h_(nm)");

scatter(timeStamps,center_h,'filled')
hold on
scatter(timeStamps,rim_h,'filled')
scatter(timeStamps,ave_h,'filled')
yyaxis right
scatter(timeStamps,dimp_vol,'filled')

lg = legend;
lg.String = {"Center h", "Rim h", "Ave h","Dimple volume"};
lg.Box = 'off';

% Shifting initial timestamp to zero for relative comparison

% scatter(timeStamps...
%     -min(timeStamps),...
%     center_h, 'filled')



