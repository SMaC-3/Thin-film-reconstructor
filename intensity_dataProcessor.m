% close all
clear all
format bank

%--------------------------------------------------------------------------
% Input settings - USER TO MODIFY
%--------------------------------------------------------------------------

%---Index of files to be procesed------------------------------------------
save_check = 0; % 1 = save info, 0 = do not save info 
%--------------------------------------------------------------------------

%---Set script mode--------------------------------------------------------
reducer = 1;
film_reco = 0;
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
conc = '';
sample = 'Ethylene_glycol';
abbre = 'EG';
expNum = 'run2';
branch = '/Volumes/ZIGGY/Thin films/MultiCam/';

folder = fullfile(branch, sample, strcat(conc,abbre),...
    strcat(conc,abbre,'_',expNum,'/'));
folder = fullfile(branch, sample,...
    strcat(conc,abbre,'_',expNum,'/')); 
folder='/Volumes/ZIGGY/Thin films/MultiCam/Ethylene_glycol/EG_run2/thin-films-plot/';


if ~exist(folder,'dir')
    folder = pwd;
end

reduced_data_folder = 'data-normalised/';
reduced_data_path = strcat(folder, reduced_data_folder);

film_data_folder = 'thin-films/';
film_data_path = strcat(folder, film_data_folder);

if reducer == 1
    %---Select files  manually for reduction-----------------------------------
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
    
    %--------------------------------------------------------------------------
    % PERFORM DATA REDUCTION
    %--------------------------------------------------------------------------
    for i = 1:size(red_files,2)
        % red correction
        T_red = importdata(strcat(red_path, red_files{i}),'\t',8);
        radius = T_red.data(:,2);
        red_int = T_red.data(:,3);
        
        % blue correction
        T_blue = importdata(strcat(blue_path, blue_files{i}),'\t',8);
        blue_int = T_blue.data(:,3);
        
        [T_export] =  intensity_dataReduction(radius, red_int, blue_int);
        
        % saveData function
        
%         file_parts = split(red_files{i},{'-','_'});
%         file_name = strcat(file_parts{2},'-',file_parts{3},'-',...
%             file_parts{4},'-reduced');
        file_name = strcat(red_files{i}(5:end-4),'-reduced');
        saveData(T_export, reduced_data_path, file_name);
    end

end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

if film_reco == 1

    %---Select files  manually for film reconstruction-------------------------
    
    [data_files, data_path] = uigetfile(strcat(folder,'*.txt'),...
        'Select the subtracted red-files', 'MultiSelect','on');
    
    if iscell(data_files) == 0
        data_files = {data_files};
    end
    
    %--------------------------------------------------------------------------
    % PERFORM THIN FILM RECONSTRUCTION
    %--------------------------------------------------------------------------
    
    for ii = 1:size(data_files,2)
        
        T_import = readtable(strcat(data_path, data_files{ii}));
        disp(data_files{ii});
        
        [T_dimp] =...
            intensity_buildFilm(T_import);
        
        % saveData function
%         file_parts = split(data_files{ii}, {'-','_'});
        file_name = strcat('film-',data_files{ii}(1:end-4));
        saveData(T_dimp, film_data_path,file_name);
        
    end
end





