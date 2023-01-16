
%--------------------------------------------------------------------------
% INTENSITY_DATAPROCESSOR normalise 1D intensity vs radius data and
% reconstruct thin film profile 
%--------------------------------------------------------------------------

close all
% clearvars -except folder
format default

%--------------------------------------------------------------------------
%% Info about user input settings
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
folder = "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_run6/";
csvFile = "150mM_SDS_run6_TimeStamps.csv";

red_img_folder = "red-surfFit-WBcor-tiff/";
red_img_path = fullfile(folder, red_img_folder);

%---Index of files to be procesed-----------------------------
% selected = [270:1:550, 3000:1:3150];
selected = [500:1:900];
save_check = 1; % 1 = save info, 0 = do not save info 
save_descriptor = "";

%---global intensity directory info

global_int_folder = "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_globalExtrema_run6/";
% global_int_folder = folder;
global_int_red_dir = "red-int-sectors/red-1D-int-0-360-surfFit-WBcor/";

global_path = fullfile(global_int_folder,global_int_red_dir);
channel = "red";
%--------------------------------------------------------------

%--------------------------------------------------------------------------
% END Input settings
%--------------------------------------------------------------------------

reduced_data_folder = 'data-normalised-2D/';
film_data_folder = 'thin-films-2D/';

if exist(fullfile(folder,'data-normalised-2D/'),"dir") == 0
    mkdir(fullfile(folder,reduced_data_folder));
end

if exist(fullfile(folder,'thin-films-2D/'),"dir") == 0
    mkdir(fullfile(folder,'thin-films-2D/'));
end

reduced_data_path = strcat(folder, reduced_data_folder);
film_data_path = strcat(folder, film_data_folder);

%% Load data

[red_data, red_files, num_imgs]...
    = findFile(folder, red_img_path, csvFile, selected, "red");

%--------------------------------------------------------------------------
%% Find global max & min for blue and red intensity data
%--------------------------------------------------------------------------
lower_bound = 5;
upper_bound = 250;
% % Only use data within dimple region, so set this as cutoff radius

[red_int_min, red_int_max] =...
    intensity_globalExtrema_V2(global_path, channel, ...
    lower_bound, upper_bound);

%--------------------------------------------------------------------------
%% Normalise data
%--------------------------------------------------------------------------

norm_red = cell(size(red_data));
h_inv_red = cell(size(red_data));

lambda = 630;
% lamb_blue = 450;
n1 = 1.33; % refractive index of water

factor_red = (4*pi*n1)/lambda; % convert argument to height

parfor i = 1:max(size(red_data))

    norm_red{i} = ...
        (2*double(red_data{i}) - (red_int_max+red_int_min))...
        ./(red_int_max-red_int_min);

    h_inv_red{i} = real(acos(norm_red{i})./factor_red); 
    % acos returns value b/w [0, pi]
end

%% clean up and export
tic
% h_inv_red = real(h_inv_red);

% h_inv_red(I_cutoff:end,:) = 0;
% zap_red = find(h_inv_red ==0);
% h_inv_red(zap_red) = NaN;
% h_inv_red(1:2,:) = NaN;

% TO DO: save info on max/min normalisation values

if save_check == 1

% lambda = 630;
% n1 = 1.33; % refractive index of water
% factor_red = (4*pi*n1)/lambda; % convert argument to height
% red_int_min, red_int_max
% global_path

norm_h_info = {...
    "Normalisation path: ", global_path;...
    "Intensity max: ", red_int_max;...
    "Intensity min: ", red_int_min;...
    "Lower bound radius (global extrema): ", lower_bound;...
    "Upper bound radius (global extrema): ", upper_bound;...
    "Wavelength: ", lambda;...
    "Refractive index: ", n1
    };

writecell(norm_h_info, strcat(folder, "2D_norm_film_pars.txt"),...
    'Delimiter','\t');

    parfor i = 1:size(red_files,2)
        
        file_name_split = split(red_files{i},'-');
        
        file_name_norm = strcat(file_name_split{1},'-',...
            file_name_split{2}, '-',file_name_split{3},...
            '-reduced.txt');
        file_name_h = strcat('film-',file_name_norm);

        writematrix(norm_red{i},...
            strcat(reduced_data_path,file_name_norm));
        writematrix(h_inv_red{i},...
            strcat(film_data_path, file_name_h));
    end
end
toc 
%% Metrics

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

        BW = imbinarize(red_data{end});
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

            figure()
        BW = imbinarize(red_data{end});
        % BW = imbinarize(red_data{round(end/2)});
        imshow(BW);
        viscircles(center_circ, radius_circ);
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



%% Run metrics function
% 
[T_metrics] =...
    film_metrics_2D(h_inv_red, norm_red, radius_circ, center_circ,...
    folder, csvFile, selected, save_check);


% [T_metrics] =...
%     film_metrics_2D(h_inv_red, radius_circ, center_circ,...
%     folder, csvFile, selected, 0);


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


