% Code written by Joshua P. King, SMaCLab, Monash University, Australia
% Last updated: August, 2022

%   ________  ___      ___       __       ______   ___            __       _______   
%  /"       )|"  \    /"  |     /""\     /" _  "\ |"  |          /""\     |   _  "\  
% (:   \___/  \   \  //   |    /    \   (: ( \___)||  |         /    \    (. |_)  :) 
%  \___  \    /\\  \/.    |   /' /\  \   \/ \     |:  |        /' /\  \   |:     \/  
%   __/  \\  |: \.        |  //  __'  \  //  \ _   \  |___    //  __'  \  (|  _  \\  
%  /" \   :) |.  \    /:  | /   /  \\  \(:   _) \ ( \_|:  \  /   /  \\  \ |: |_)  :) 
% (_______/  |___|\__/|___|(___/    \___)\_______) \_______)(___/    \___)(_______/  
                                                                                   

% SMaCLab website can be found here:
% https://sites.google.com/view/smaclab

%--------------------------------------------------------------
% INTENSITY_DATAPROCESSOR normalise 1D intensity vs radius data and
% reconstruct thin film profile 
%--------------------------------------------------------------

%--------------------------------------------------------------

% Functions used in this script:

% reducer
% 1) intensity_maxMin – identifies points of constructive/destructive
% interference and dimple rim
% 2) intensity_normalise – normalises data branch-wise using points from
% previous function
% 3) saveData 

% film_reco
% 1) intensity_buildFilm – converts normalised intensity to absolute film
% height based on appropriate cosine branch (provided by user)

%--------------------------------------------------------------
% Info about user input settings
%--------------------------------------------------------------

%close all
% clearvars -except folder
format default

clc
clear all
% close all

%--------------------------------------------------------------
%% Input settings - USER TO MODIFY
%--------------------------------------------------------------

%---Index of files to be procesed------------------------------
save_check = 1; % 1 = save info, 0 = do not save info 
%--------------------------------------------------------------

%---Set script mode--------------------------------------------
reducer = 1;
film_reco = 1;
phi_correction = 0; % Set to 1 if a phase shift occurs upon reflection
%--------------------------------------------------------------

%---main branch directory info---------------------------------

folder = "/Volumes/T7/Thin films/MultiCam/CNC_dialysed/3p5wtCNC/3p5wtCNC_run1/";

%---global intensity directory info
global_max_min = 0; 
display(strcat("global max/min: ", num2str(global_max_min)));
% Set to 1 to use global max/min within data set,
% set to 0 to provide an altenative data set below for global exrema

% global_int_folder = "/Volumes/T7/Thin films/MultiCam/CNC_dialysed/1p9wtCNC_V2/1p9wtCNC_V2_run6/";
global_int_folder = folder; 
global_int_red_dir = "red-int-sectors/red-1D-int-0-360-flatField/";
global_int_blue_dir = "blue-int-sectors/blue-1D-int-0-360-flatField/";

%--------------------------------------------------------------
% END Input settings
%--------------------------------------------------------------


if ~exist(folder,'dir')
    folder = pwd;
end

reduced_data_folder = 'data-normalised/';
reduced_data_path = strcat(folder, reduced_data_folder);

film_data_folder = 'thin-films/';
film_data_path = strcat(folder, film_data_folder);

%% Start data reduction

if reducer == 1
    %---Select files manually for reduction--------------------
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
    
%% Setup for max/min and rim ID

    % Range between which code accepts staionary points in intensity data.
    % If a SP falls outside this range, then it is removed automatically
    lb_ub_sp_ID_red = zeros(size(red_files,2),2);
    lb_ub_sp_ID_blue = zeros(size(red_files,2),2);
    
    % Radius corresponding to dimple rim
    dimple_radii_red = zeros(size(red_files,2),1);
    dimple_radii_blue = zeros(size(red_files,2),1);
    
    % Radius imported from file
    radius = cell(size(red_files,2),1);
    
    % Intensity data from file, index of maxima and minima identified using
    % findpeaks in INTENSITY_MAXMIN
    red_int = cell(size(red_files,2),1);
    red_I_min = cell(size(red_files,2),1);
    red_I_max = cell(size(red_files,2),1);
    
    blue_int = cell(size(red_files,2),1);
    blue_I_min = cell(size(red_files,2),1);
    blue_I_max = cell(size(red_files,2),1);
    
%--------------------------------------------------------------
%--------------------------------------------------------------
% PERFORM DATA REDUCTION
%--------------------------------------------------------------
%--------------------------------------------------------------
%% Import data
    for i = 1:size(red_files,2)
        
        % Import red data
        disp(red_files{i});
        T_red = importdata(strcat(red_path, red_files{i}),'\t',8);
        radius{i} = T_red.data(:,2);
        red_int{i} = T_red.data(:,3);
        
        % Import blue data
        T_blue = importdata(strcat(blue_path, blue_files{i}),'\t',8);
        blue_int{i} = T_blue.data(:,3);

%         
        % First file requires user to identify bounds, dimple radius. For
        % remaining files, the script uses this supplied info to predict
        % these parameters and the user can either accept and manually
        % adjust as needed
        
        if i == 1
            
            [I_min_pks, I_max_pks, min_pks, max_pks, cut, dimple_radius] =...
                intensity_maxMin(radius{i}, red_int{i},[]);

           lb_ub_sp_ID_red(1,1:end) = cut;

           dimple_radii_red(1) = dimple_radius;
           red_I_min{1} = I_min_pks;
           red_I_max{1}= I_max_pks;
           
           key_pars_blue = [lb_ub_sp_ID_red(1,1:end),...
               dimple_radii_red(1)];
           [I_min_pks, I_max_pks, min_pks, max_pks, cut, dimple_radius] =...
               intensity_maxMin(radius{i}, blue_int{i},key_pars_blue);
           
           lb_ub_sp_ID_blue(1,1:end) = cut;

           dimple_radii_blue(1) = dimple_radius;
           blue_I_min{1} = I_min_pks;
           blue_I_max{1}= I_max_pks;
        
        else
            
            key_pars_red = [lb_ub_sp_ID_red(i-1,1:end),...
                dimple_radii_red(i-1)];
            [I_min_pks, I_max_pks, min_pks, max_pks, cut, dimple_radius] =...
                intensity_maxMin(radius{i}, red_int{i},key_pars_red);
            
            lb_ub_sp_ID_red(i,1:end) = cut;
            dimple_radii_red(i) = dimple_radius;
            red_I_min{i} = I_min_pks;
            red_I_max{i}= I_max_pks;
            
            key_pars_blue = [lb_ub_sp_ID_blue(i-1,1:end),...
               dimple_radii_blue(i-1)];
            [I_min_pks, I_max_pks, min_pks, max_pks, cut, dimple_radius] =...
                intensity_maxMin(radius{i}, blue_int{i},key_pars_blue);
            
            lb_ub_sp_ID_blue(i,1:end) = cut;
            dimple_radii_blue(i) = dimple_radius;
            blue_I_min{i} = I_min_pks;
            blue_I_max{i}= I_max_pks;
        end
    end
    
%--------------------------------------------------------------
%% Find global max & min for blue and red intensity data
%--------------------------------------------------------------
if global_max_min == 1

    % Only use data within dimple region, so set this as max dimple rim radius
    red_dimp_radius = max(dimple_radii_red);
    blue_dimp_radius = max(dimple_radii_blue);

    % Index of max dimple rim radius
    [~,red_max_dimp_ind] = min(abs(radius{1}-red_dimp_radius));
    [~,blue_max_dimp_ind] = min(abs(radius{1}-blue_dimp_radius));

    % Make sure that only actual red intensity data is used
    red_files_struct = dir(fullfile(red_path, '*.txt'));
    red_Allfiles = struct2cell(red_files_struct).';
    red_Allfiles = red_Allfiles(:,1);
    red_check = zeros(size(red_Allfiles));

    for j = 1:max(size(red_Allfiles))
        check_val = red_Allfiles{j}(1:3);
        if check_val=='red'
            red_check(j) = 1;
        else
            red_check(j) = 0;
        end
    end

    red_check = logical(red_check);
    red_Allfiles = red_Allfiles(red_check);

    % Make sure that only actual blue intensity data is used
    blue_files_struct = dir(fullfile(blue_path, '*.txt'));
    blue_Allfiles = struct2cell(blue_files_struct).';
    blue_Allfiles = blue_Allfiles(:,1);
    blue_check = zeros(size(blue_Allfiles));

    for j = 1:max(size(blue_Allfiles))
        check_val = blue_Allfiles{j}(1:4);
        if check_val=='blue'
            blue_check(j) = 1;
        else
            blue_check(j) = 0;
        end
    end

    blue_check = logical(blue_check);
    blue_Allfiles = blue_Allfiles(blue_check);

    red_allData = cell(size(red_Allfiles));
    red_all_max = zeros(size(red_Allfiles));
    red_all_min = zeros(size(red_Allfiles));
    blue_allData = cell(size(red_Allfiles));
    blue_all_max = zeros(size(red_Allfiles));
    blue_all_min = zeros(size(red_Allfiles));

    red_end_sp = max([cellfun(@max, red_I_max),cellfun(@max, red_I_min)]);
    blue_end_sp = max([cellfun(@max, blue_I_max),cellfun(@max, blue_I_min)]);

    lb_cutOff = 5;

    % Import all red and blue intensity data
    for i = 1:max(size(red_Allfiles))
        T_red = importdata(strcat(red_path, red_Allfiles{i}),'\t',8);
        red_allData{i} = T_red.data(lb_cutOff:red_end_sp,3); % Changed to use end sp instead of dimple
        red_all_max(i) = max(T_red.data(:,3));
        red_all_min(i) = min(T_red.data(:,3));
        T_blue = importdata(strcat(blue_path, blue_Allfiles{i}),'\t',8);
        blue_allData{i} = T_blue.data(lb_cutOff:blue_end_sp,3); % Changed to use end sp instead of dimple
        blue_all_max(i) = max(T_blue.data(:,3));
        blue_all_min(i) = min(T_blue.data(:,3));
    end

    % Find global maximum and minimum in red and blue data
    red_int_max = max(cellfun(@max, red_allData));
    blue_int_max = max(cellfun(@max, blue_allData));
    % red_int_max = max(red_all_max);
    % blue_int_max = max(blue_all_max);

    red_int_min = min(cellfun(@min, red_allData));
    blue_int_min = min(cellfun(@min, blue_allData));


elseif global_max_min == 0
    [red_int_min, red_int_max, blue_int_min, blue_int_max] =...
        intensity_globalExtrema(global_int_folder, ...
        global_int_red_dir, global_int_blue_dir);

%     blue_int_max = 11210.85;
    % blue_int_min = 6741.11;

%     red_int_max = 32579.05;
    % red_int_min = 19848.03;

else
    error("Did not recognise global_max_min variable option");
end

%--------------------------------------------------------------
%% Normalise data and export
%--------------------------------------------------------------

for i = 1:size(red_files,2)
    
    %----------------------------------------------------------
    % Gradient correction not used, so null values provided and as imported
    % data used for normalisation
    %----------------------------------------------------------
    red_P = 0;
    red_y = 0;
    red_int_cor = red_int{i};
    
    blue_P = 0;
    blue_y = 0;
    blue_int_cor = blue_int{i};
    
    %----------------------------------------------------------
    % Normalise data
    %----------------------------------------------------------

    [red_norm, red_dimp] =...
        intensity_normalise(radius{i}, red_int_cor,...
        red_I_min{i}, red_I_max{i}, dimple_radii_red(i),...
        red_int_min,red_int_max);
    
    [blue_norm, blue_dimp] =...
        intensity_normalise(radius{i}, blue_int_cor,...
        blue_I_min{i}, blue_I_max{i}, dimple_radii_blue(i),...
        blue_int_min,blue_int_max);
    
    %----------------------------------------------------------
    % Prepare data for export
    %----------------------------------------------------------
    
    red_I_sp = sort([red_I_min{i};red_I_max{i}]);
    blue_I_sp = sort([blue_I_min{i};blue_I_max{i}]);
    
    red_I_max_min = zeros(length(radius{i}),1);
    blue_I_max_min = zeros(length(radius{i}),1);
    
    red_I_max_min(red_I_min{i}) = -1;
    red_I_max_min(red_I_max{i}) = 1;
    blue_I_max_min(blue_I_min{i}) = -1;
    blue_I_max_min(blue_I_max{i}) = 1;
    
    red_trendline = zeros(length(radius{i}),1);
    red_trendline(1:2) = red_P;
    blue_trendline = zeros(length(radius{i}),1);
    blue_trendline(1:2) = blue_P;
    
    red_I_dimp = zeros(length(radius{i}),1);
    blue_I_dimp = zeros(length(radius{i}),1);
    
    red_I_dimp(red_I_sp(red_dimp)) = 1;
    blue_I_dimp(blue_I_sp(blue_dimp)) = 1;

    red_extrema = zeros(length(radius{i}),1);
    red_extrema(1) = red_int_max;
    red_extrema(2) = red_int_min;
    blue_extrema = zeros(length(radius{i}),1);
    blue_extrema(1) = blue_int_max;
    blue_extrema(2) = blue_int_min;
    %----------------------------------------------------------
    % Export normalised data and max/min, dimple parameters 
    %----------------------------------------------------------

    T_export = table(radius{i}, red_int{i}, blue_int{i},...
        round(red_int_cor,4), round(blue_int_cor,4),...
        round(red_norm,4), round(blue_norm,4),...
        red_I_max_min, blue_I_max_min, red_I_dimp, blue_I_dimp,...
        round(red_trendline,4), round(blue_trendline,4),...
        round(red_extrema,4), round(blue_extrema,4),...
        'VariableNames', {'radius','red_int_raw','blue_int_raw',...
        'red_int_corrected','blue_int_corrected',...
        'red_norm','blue_norm','red_I_max_min', 'blue_I_max_min',...
        'red_I_dimp', 'blue_I_dimp',...
        'red_trendline', 'blue_trendline',...
        'red_extrema','blue_extrema'});
    %  [T_export] =  intensity_dataReduction(radius, red_int, blue_int);

    if save_check == 1

        norm_info = {...
            "Normalisation path: ", global_int_folder;...
            "Intensity max red: ", red_int_max;...
            "Intensity min red: ", red_int_min;...
            "Intensity max blue: ", blue_int_max;...
            "Intensity min blue: ", blue_int_min;...
            };

        writecell(norm_info, strcat(folder, "norm_pars.txt"),...
            'Delimiter','\t');

        file_name = strcat(red_files{i}(5:end-4),'-reduced');
        saveData(T_export, reduced_data_path, file_name);
    end
end

end

%--------------------------------------------------------------
%--------------------------------------------------------------
%% Film reconstruction 
%--------------------------------------------------------------
%--------------------------------------------------------------

if film_reco == 1
    
    %---Select files  manually for film reconstruction---------
    disp('select normalised data');
    [data_files, data_path] = uigetfile(strcat(folder,'*.txt'),...
        'Select the subtracted red-files', 'MultiSelect','on');
    
    if iscell(data_files) == 0
        data_files = {data_files};
    end
    
    %----------------------------------------------------------
    % PERFORM THIN FILM RECONSTRUCTION
    %----------------------------------------------------------
    
    for ii = 1:size(data_files,2)
        
        T_import = readtable(strcat(data_path, data_files{ii}));
        disp(data_files{ii});
        
        if ii == 1
            [T_dimp] =...
                intensity_buildFilm(T_import, phi_correction, []);
            pre_T_dimp = T_dimp;
        
        else    
            [T_dimp] =...
                intensity_buildFilm(T_import, phi_correction, pre_T_dimp);
            pre_T_dimp = T_dimp;
        end
        
        if save_check ==1
            % saveData function
            %         file_parts = split(data_files{ii}, {'-','_'});
            file_name = strcat('film-',data_files{ii}(1:end-4));
            saveData(T_dimp, film_data_path,file_name);
        end
        
    end
end





