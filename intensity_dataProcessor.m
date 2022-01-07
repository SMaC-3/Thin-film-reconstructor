%close all
clearvars -except folder
format bank

%--------------------------------------------------------------------------
% Input settings - USER TO MODIFY
%--------------------------------------------------------------------------

%---Index of files to be procesed------------------------------------------
save_check = 1; % 1 = save info, 0 = do not save info 
%--------------------------------------------------------------------------

%---Set script mode--------------------------------------------------------
reducer = 1;
film_reco = 1;

%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
% conc = ''; 
% sample = 'Eth ylene_glycol';
% abbre = 'EG';
% expNum = 'run1';
% branch = '/Volumes/ZIGGY/Thin films/MultiCam/';
%  
% folder = fullfile(branch, sample, strcat(conc,abbre),...
%     strcat(conc,abbre,'_',expNum,'/'));
% folder = fullfile(branch, sample,...
%     strcat(conc,abbre,'_',expNum,'/')); 

folder = "/Volumes/ZIGGY/Thin films/MultiCam/CNC_dialysed/1p9wtCNC/1p9wtCNC_run4/";
% csvFile = "1p9wtCNC_run1_TimeStamps.csv";

if ~exist(folder,'dir')
    folder = pwd;
end

reduced_data_folder = 'data-normalised/';
reduced_data_path = strcat(folder, reduced_data_folder);

film_data_folder = 'thin-films/';
film_data_path = strcat(folder, film_data_folder);

if reducer == 1
    %---Select files manually for reduction-----------------------------------
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
    
    lb_ub_sp_ID_red = zeros(size(red_files,2),2);
    lb_ub_sp_grad_cor_red = zeros(size(red_files,2),2);
    dimple_radii_red = zeros(size(red_files,2),1);
    
    lb_ub_sp_ID_blue = zeros(size(red_files,2),2);
    lb_ub_sp_grad_cor_blue = zeros(size(red_files,2),2);
    dimple_radii_blue = zeros(size(red_files,2),1);
    
    radius = cell(size(red_files,2),1);
    red_int = cell(size(red_files,2),1);
    red_I_min = cell(size(red_files,2),1);
    red_I_max = cell(size(red_files,2),1);
    blue_int = cell(size(red_files,2),1);
    blue_I_min = cell(size(red_files,2),1);
    blue_I_max = cell(size(red_files,2),1);
    %--------------------------------------------------------------------------
    % PERFORM DATA REDUCTION
    %--------------------------------------------------------------------------
    for i = 1:size(red_files,2)
        % red correction
        disp(red_files{i});
        T_red = importdata(strcat(red_path, red_files{i}),'\t',8);
        radius{i} = T_red.data(:,2);
        red_int{i} = T_red.data(:,3);
        
        % blue correction
        T_blue = importdata(strcat(blue_path, blue_files{i}),'\t',8);
        blue_int{i} = T_blue.data(:,3);
        
        if i == 1
            [I_min_pks, I_max_pks, min_pks, max_pks, cut, cut_grad, dimple_radius] =...
               intensity_maxMin(radius{i}, red_int{i},[]); 
           
           lb_ub_sp_ID_red(1,1:end) = cut;
           lb_ub_sp_grad_cor_red(1,1:end) = cut_grad;
           dimple_radii_red(1) = dimple_radius;
           red_I_min{1} = I_min_pks;
           red_I_max{1}= I_max_pks;
           
           key_pars_blue = [lb_ub_sp_ID_red(1,1:end),...
               lb_ub_sp_grad_cor_red(1,1:end), dimple_radii_red(1)];
           [I_min_pks, I_max_pks, min_pks, max_pks, cut, cut_grad, dimple_radius] =...
               intensity_maxMin(radius{i}, blue_int{i},key_pars_blue);
           
           lb_ub_sp_ID_blue(1,1:end) = cut;
           lb_ub_sp_grad_cor_blue(1,1:end) = cut_grad;
           dimple_radii_blue(1) = dimple_radius;
           blue_I_min{1} = I_min_pks;
           blue_I_max{1}= I_max_pks;
        
        else
            key_pars_red = [lb_ub_sp_ID_red(i-1,1:end),...
                lb_ub_sp_grad_cor_red(i-1,1:end), dimple_radii_red(i-1)];
            [I_min_pks, I_max_pks, min_pks, max_pks, cut, cut_grad, dimple_radius] =...
                intensity_maxMin(radius{i}, red_int{i},key_pars_red);
            
            lb_ub_sp_ID_red(i,1:end) = cut;
            lb_ub_sp_grad_cor_red(i,1:end) = cut_grad;
            dimple_radii_red(i) = dimple_radius;
            red_I_min{i} = I_min_pks;
            red_I_max{i}= I_max_pks;
            
            key_pars_blue = [lb_ub_sp_ID_blue(i-1,1:end),...
                lb_ub_sp_grad_cor_blue(i-1,1:end), dimple_radii_blue(i-1)];
            [I_min_pks, I_max_pks, min_pks, max_pks, cut, cut_grad, dimple_radius] =...
                intensity_maxMin(radius{i}, blue_int{i},key_pars_blue);
            
            lb_ub_sp_ID_blue(i,1:end) = cut;
            lb_ub_sp_grad_cor_blue(i,1:end) = cut_grad;
            dimple_radii_blue(i) = dimple_radius;
            blue_I_min{i} = I_min_pks;
            blue_I_max{i}= I_max_pks;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find global max & min for blue and red
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    red_dimp_radius = max(dimple_radii_red);
    blue_dimp_radius = max(dimple_radii_blue);
    [~,red_max_dimp_ind] = min(abs(radius{1}-red_dimp_radius));
    [~,blue_max_dimp_ind] = min(abs(radius{1}-blue_dimp_radius));
    
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
    blue_allData = cell(size(red_Allfiles));
    
     for i = 1:max(size(red_Allfiles))
        % red correction
        T_red = importdata(strcat(red_path, red_Allfiles{i}),'\t',8);
%         radius{i} = T_red.data(:,2);
        red_allData{i} = T_red.data(1:red_max_dimp_ind,3);
        
        % blue correction
        T_blue = importdata(strcat(blue_path, blue_Allfiles{i}),'\t',8);
        blue_allData{i} = T_blue.data(1:blue_max_dimp_ind,3);
     end
    
     
     red_int_max = max(cellfun(@max, red_allData));
     blue_int_max = max(cellfun(@max, blue_allData));
     
     red_int_min = min(cellfun(@min, red_allData));
     blue_int_min = min(cellfun(@min, blue_allData));
     
     
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find global max & min for blue and red
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     
     
     
    for i = 1:size(red_files,2)
        
        %%%
        
%         [red_P, red_y, red_int_cor] =...
%             intensity_gradCorrect(radius{i}, red_int{i},...
%             red_I_min{i}, red_I_max{i}, lb_ub_sp_grad_cor_red(i,1),lb_ub_sp_grad_cor_red(i,2));
%         
%         [blue_P, blue_y, blue_int_cor] =...
%             intensity_gradCorrect(radius{i}, blue_int{i},...
%             blue_I_min{i}, blue_I_max{i}, lb_ub_sp_grad_cor_blue(i,1),lb_ub_sp_grad_cor_blue(i,2));
%         
        
        %%%
        
        red_P = 0;
        red_y = 0;
        red_int_cor = red_int{i};
        
        blue_P = 0;
        blue_y = 0;
        blue_int_cor = blue_int{i};
        
        [red_norm, red_dimp] =...
            intensity_normalise(radius{i}, red_int_cor,...
            red_I_min{i}, red_I_max{i}, dimple_radii_red(i),red_int_min,red_int_max );
        
        [blue_norm, blue_dimp] =...
            intensity_normalise(radius{i}, blue_int_cor,...
            blue_I_min{i}, blue_I_max{i}, dimple_radii_blue(i),blue_int_min,blue_int_max);

        
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
        
        T_export = table(radius{i}, red_int{i}, blue_int{i},...
            round(red_int_cor,4), round(blue_int_cor,4),...
            round(red_norm,4), round(blue_norm,4),...
            red_I_max_min, blue_I_max_min, red_I_dimp, blue_I_dimp,...
            round(red_trendline,4), round(blue_trendline,4),...
            'VariableNames', {'radius','red_int_raw','blue_int_raw',...
            'red_int_corrected','blue_int_corrected',...
            'red_norm','blue_norm','red_I_max_min', 'blue_I_max_min',...
            'red_I_dimp', 'blue_I_dimp',...
            'red_trendline', 'blue_trendline'});
%         [T_export] =  intensity_dataReduction(radius, red_int, blue_int);
        
        % saveData function
        
        %         file_parts = split(red_files{i},{'-','_'});
        %         file_name = strcat(file_parts{2},'-',file_parts{3},'-',...
        %             file_parts{4},'-reduced');
        if save_check == 1
            file_name = strcat(red_files{i}(5:end-4),'-reduced');
            saveData(T_export, reduced_data_path, file_name);
        end
    end

end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

if film_reco == 1

    %---Select files  manually for film reconstruction-------------------------
    disp('select normalised data');
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
        
        if ii == 1
            
            [T_dimp] =...
                intensity_buildFilm(T_import,[]);
            
            pre_T_dimp = T_dimp;
        else
            
            [T_dimp] =...
                intensity_buildFilm(T_import,pre_T_dimp);
            
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





