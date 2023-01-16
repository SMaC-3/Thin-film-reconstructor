
%--------------------------------------------------------------------------
%% Info about user input settings
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
folder = "/Volumes/T7/Thin films/MultiCam/CNC_dialysed/0p95wtCNC/0p95wtCNC_run4_globalExtrema_run3/";
csvFile = "0p95wtCNC_run4_globalExtrema_run3_TimeStamps.csv";

[film_files, film_path] = uigetfile(strcat(folder,'thin-films/','*.txt'),...
    'Select the film data', 'MultiSelect','on');

if iscell(film_files)~=1
    film_files = {film_files};
end

%% 
T_film = readtable(strcat(film_path, film_files{end}));
[min_h, min_h_I] = min(T_film.red_film);

figure()
hold on

for i = 1:size(film_files,2)
    T_film = readtable(strcat(film_path, film_files{i}));
    scatter(T_film.radius, T_film.red_film, "filled")
end

% Determine radius of dimple rim for metrics calculations

scatter(T_film.radius(min_h_I), T_film.red_film(min_h_I),...
    "filled", 'SizeData',100)

radius_dimp_I = min_h_I;

disp(strcat("radius I from min height is: ", num2str(radius_dimp_I)));

disp('1: Accept all parameters')
disp('2: Supply radius I')

action_input = 'Please select an option: ';
action_select = input(action_input);
while isempty(action_select)
    action_select = input(action_input);
end

while action_select~=1
    
    if action_select == 2
        disp(strcat('Current radius I: ', ' ',string(radius_dimp_I)));
        radius_prompt = "Please enter index of radius: ";
        radius_val = input(radius_prompt);
        while isempty(radius_val)
            radius_val = input(radius_prompt);
        end
        [~, radius_I] = min(abs(T_film.radius-radius_val));
    
    else
        disp('Please enter a valid selection')
    end

    action_input = 'Please select an option: ';
    action_select = input(action_input);
    while isempty(action_select)
        action_select = input(action_input);
    end
end

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

if iscell(film_files) == 0
    film_files = {film_files};
end

file_parts = split(film_files.', {'-'});
if length(film_files) == 1
    file_num = str2double(file_parts(4));
else
    file_num = str2double(file_parts(:,4));
end

timeStamps = T.cumulStamps;
fileNums = T.fileNum;
[~, fileNums_I] = ismember(file_num, fileNums);
timeStamps_select = round(timeStamps(fileNums_I),0);
timeStamps_str = cellstr(num2str(timeStamps_select));

save_check = 1; % 1 = save info, 0 = do not save info
save_descriptor = "";

%% Get metrics

dimp_vol = zeros(length(film_files),1);
center_h = zeros(length(film_files),1);
rim_h = zeros(length(film_files),1);

% Calculate from data and save (optional)
for i = 1:size(film_files,2)
    T_film = readtable(strcat(film_path, film_files{i}));
    selected = file_num(i);
    scatter(T_film.radius, T_film.red_film)

    %     radius_prompt = "Please provide a dimple radius: ";
    %     radius_dimp = input(radius_prompt);
    %
    %     [~, radius_dimp_I] = min(abs(T_film.radius-radius_dimp));

%     [T_metrics] =...
%         film_metrics_1D(T_film, radius_dimp_I,...
%         folder,csvFile, selected, save_check);

    [T_metrics] =...
        film_metrics_1D_discretised(T_film, radius_dimp_I,...
        folder,csvFile, selected, save_check);

    dimp_vol(i) = T_metrics.("Dimple_vol_(micron^3)");
    center_h(i) = T_metrics.("Center_h_(nm)");
    rim_h(i) = T_metrics.("Rim_h_(nm)");
end

% Import from file

% [T_metrics, metrics_files, num_metrics] =...
%     findFile_2D_metrics(metrics_path, selected);

%% Plot

figure(2)

scatter(timeStamps_select,center_h,'filled')
hold on
scatter(timeStamps_select,rim_h,'filled')
yyaxis right
scatter(timeStamps_select,dimp_vol,'filled')

lg = legend;
lg.String = {"Center h", "Rim h", "Dimple volume"};
lg.Box = 'off';

% Shifting initial timestamp to zero for relative comparison

% scatter(timeStamps...
%     -min(timeStamps),...
%     center_h, 'filled')


