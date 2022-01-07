%close all

%--------------------------------------------------------------------------
% Import information - USER TO MODIFY
%--------------------------------------------------------------------------

%---Index of files to be procesed------------------------------------------
save_check = 1; % 1 = save info, 0 = do not save info 
%--------------------------------------------------------------------------

%---Set script mode--------------------------------------------------------
film_selector = 1; %ADD ability to splice red & blue channels together
film_analyser = 1;
film_plotter = 1;
%--------------------------------------------------------------------------
%---power-law exponent-----------------------------------------------------------------------

n=1;
m = 0.2; % Flow consistency index in Pa.s^n
R = 0.2; % Setting "R" in Winter paper to dimple radius, in um

%---main branch directory info---------------------------------------------

% folder = fullfile(branch, sample, strcat(conc,abbre),...
%     strcat(conc,abbre,'_',expNum,'/'));
% folder = fullfile(branch, sample,...
%     strcat(conc,abbre,'_',expNum,'/')); 
folder = "/Volumes/ZIGGY/Thin films/MultiCam/CNC_dialysed/1p9wtCNC/1p9wtCNC_run1/";
csvFile = "1p9wtCNC_run1_TimeStamps.csv";

folder_parts = split(folder, '/');
exp_parts = split(folder_parts{end-1},'_');

sample = folder_parts{6};
conc_parts = exp_parts(1:end-1);
conc = join(conc_parts,'_',1);
conc = conc{1};
abbre = conc;
expNum = exp_parts{end};


% conc = '600ppm_Xgum_0p1mMKCl';
% sample = '600ppm_Xgum_0p1mMKCl';
% abbre = '600ppm_Xgum_0p1mMKCl';
% expNum = 'run1';
branch = '/Volumes/ZIGGY/Thin films/MultiCam/';

if ~exist(folder,'dir')
    folder = pwd;
end

film_plot_folder = 'thin-films-plot/';
film_plot_path = strcat(folder, film_plot_folder);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

if film_selector == 1

    %---Select files  manually for reduction-----------------------------------
    
    [film_files, film_path] = uigetfile(strcat(folder,'*.txt'),...
        'Select the film data', 'MultiSelect','on');
    
    if iscell(film_files) == 0
        film_files = {film_files};
    end
    
    %--------------------------------------------------------------------------
    % PERFORM FILM SELECTION
    %--------------------------------------------------------------------------
    
    figure(1)
    
    % radius_plot = cell(size(film_files,2),1);
    film_plot_choice = cell(size(film_files,2),1);
    col_choice = cell(size(film_files,2),1);
    
    for i = 1:size(film_files,2)
        T_film = readtable(strcat(film_path, film_files{i}));
        file_parts = split(film_files{i},{'-','.'});
        fileNum = num2str(str2num(file_parts{4}));
        
        radius = T_film.radius;
        red_film = T_film.red_film;
        blue_film = T_film.blue_film;
        
        scatter([-radius; radius], [blue_film;blue_film], 50,'blue')
        hold on
        scatter([-radius; radius], [red_film;red_film], 50,'red')
        hold off
        
        col_prompt = 'Red or blue [1/2]: ';
        col = input(col_prompt);
        while isempty(col)
            col = input(col_prompt);
        end
        
        if col == 1
            %             radius_plot{i} = radius;
            film_plot_choice{i} = red_film;
            col_choice{i} = {strcat('red_',fileNum)};
            
        elseif col == 2
            %             radius_plot{i} = radius;
            film_plot_choice{i} = blue_film;
            col_choice{i} = {strcat('blue_',fileNum)};
            
        elseif col == -1
            %             radius_plot{i} = radius;
            film_plot_choice{i} = [];
            col_choice{i} = [];
            
        end
        
    end
    close all
    
    if save_check == 1
        film_plot_choice = film_plot_choice(~cellfun(@isempty,film_plot_choice));
        col_choice = col_choice(~cellfun(@isempty,col_choice));
        
        version_prompt = 'Input a version number: ';
        version = input(version_prompt,'s');
        version = strcat('-V',version);
        
        %file_name = strcat(conc, sample, '-',expNum, '-films-plot', version);
        file_name = strcat(folder_parts(end-1), '-films-plot', version);
        
        T_film_plot = table(radius, film_plot_choice{1:end},...
            'VariableNames', ['radius', col_choice{1:end}]);
        
        saveData(T_film_plot, film_plot_path, file_name);
        
    end
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

if film_analyser == 1

    if exist('T_film_plot','var') == 1
        
        load_check_prompt = 'Would you like to use currently loaded film data table?: [1/0] ';
        load_check = input(load_check_prompt);
        
        while isempty(load_check) == 1
            load_check = input(load_check_prompt);
        end
    end
    
    if exist('T_film_plot','var') == 0 || load_check == 0
    load_check = 0;
    %---Select file manually for film analysis-------------------------
        disp('Select the thin film data to analyse (films-plot.txt)');
        [film_plot_file, film_plot_path] = uigetfile(strcat(folder,'*.txt'),...
            'Select the thin film data to analyse', 'MultiSelect','off');
        
        % Turn off convert to cell b/c only one file
%         if iscell(film_plot_file) == 0
%             film_plot_file = {film_plot_file};
%         end
%         
        T_film_plot = readtable(strcat(film_plot_path, film_plot_file));
    
    end
    
    numFilms = size(T_film_plot,2)-1;
    
    %--------------------------------------------------------------------------
    % Info for timestamp csv
    %--------------------------------------------------------------------------
    
%     csvFile = strcat(conc,sample, '_',expNum,'_TimeStamps.csv');
    csvRead = strcat(folder, csvFile);
    
    if exist(csvRead,'file') == 2
        T = readtable(csvRead, 'Delimiter',',');
%         T(end, :) = [];
        
    else
        disp("Select csv file");
        [csvFile, timeStamp_file_path] = uigetfile('*.csv',...
            'Select timestamp file', 'MultiSelect','off');
        csvRead = strcat(timeStamp_file_path,csvFile);
        T = readtable(csvRead, 'Delimiter',',');
%         T(end, :) = [];
    end
    
    %--------------------------------------------------------------------------
    % Define timestamp info
    %--------------------------------------------------------------------------
    
    nameID = T.Index;
    red_names = T.red_file_names;
    blue_names = T.blue_file_names;
    sampleName = T.sample;
    cam = T.camera;
    fileNums = T.fileNum;
    secs = T.secs;
    cyCount = T.cyCount;
    cyOff = T.cyOff;
    timeStamps = T.timeStamp;
    cumulTimeStamps = T.cumulStamps;
    
    %--------------------------------------------------------------------------
    
    %--------------------------------------------------------------------------
    % Find useful metrics for plotting
    %--------------------------------------------------------------------------
    
    Hcent = zeros(numFilms,1);
    Hmin = zeros(numFilms,1);
    Hmin_I = zeros(numFilms,1);
    
    Rrim = zeros(numFilms,1);
    
    radius_bar = cell(numFilms,1);
    height_bar = cell(numFilms,1);
    dr = cell(numFilms,1);
    
    dimpArea = zeros(numFilms,1);
    dimpVol = cell(numFilms,1);
    dimpDrainageRate = zeros(numFilms,1);
    SA_cyl = cell(numFilms,1);
    
    flowRate = cell(numFilms-1,1);
    
    fileNum_plot = zeros(numFilms,1);
    timeStamp_plot = zeros(numFilms,1);
    
    for i = 1:numFilms
        
        file_parts = split(T_film_plot.Properties.VariableNames{i+1},...
            {'_','-','.'});
        fileNum_plot(i) = str2num(file_parts{2});
        timeStamp_plot(i) = cumulTimeStamps(find(fileNums == fileNum_plot(i)));
        
        Hcent(i) = T_film_plot{1,i+1};
        [Hmin(i), Hmin_I(i)] = nanmin(T_film_plot{:,i+1});
        Rrim(i) = T_film_plot{:,1}(Hmin_I(i));
        
        %dimpArea = trapz(T_film_plot{1:Hmin_I(i),i+1}); % add x-corrds
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        radius_bar{i} = 0.5*(T_film_plot{2:end,1} + T_film_plot{1:end-1,1});
        height_bar{i} = 0.5*(T_film_plot{2:end,i+1} + T_film_plot{1:end-1,i+1});
        dr{i} = T_film_plot{2:end,1} - T_film_plot{1:end-1,1};

        dimpVol{i}= 2*pi.*radius_bar{i}.*(height_bar{i}/1000).*dr{i};

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        SA_cyl{i} = 2*pi.*radius_bar{i}.*(height_bar{i}/1000);
        
    end
    
    for i = 1:numFilms-1
        for j = 1:length(dimpVol{i})
            if i==1
            flowRate{i,1}(j,1) = (sum(dimpVol{i+1}(1:j)) - sum(dimpVol{i}(1:j))) /...
                (timeStamp_plot(i+1)-timeStamp_plot(i));
%     = diff(dimpVol)./(diff(timeStamp_plot));
            else
                
                flowRate{i,1}(j,1) = (sum(dimpVol{i+1}(1:j)) - sum(dimpVol{i-1}(1:j))) /...
                (timeStamp_plot(i+1)-timeStamp_plot(i-1));
            end
        end
        
        shearRate{i,1} = -6*(flowRate{i}./(SA_cyl{i}/2+SA_cyl{i+1}/2))./...
            ((height_bar{i}/2+height_bar{i+1}/2)/1000);
        
        shearRate_power{i,1} = -(flowRate{i}./(2*pi)./(radius_bar{i}/2 + radius_bar{i+1}/2)).*...
            ((2*n+1)/n).*(2./((height_bar{i}/2 + height_bar{i+1}/2)/1000)).^((1+n)/n);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% CHECK WITH JOE THAT BELOW IMPLEMENTATION OF PRESSURE EQUATION
        %%%% IS CORRECT
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%       pressure{i,1} = ((2*n+1)/n)^n.*(flowRate{i}./(pi*R.*(height_bar{i}/2 + height_bar{i+1}/2)/1000)).^n...
%           .*((2*m*R)./((height_bar{i}/2 + height_bar{i+1}/2)/1000).*(1-n)).*...
%           (1-((radius_bar{i}/2 + radius_bar{i+1}/2)./R).^(1-n) );
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      
      
      
%         maxShear(i) = 
%         dimpVol_rim(i) =
%         maxFlow(i) = 
    end
%     flowRate(numFilms) = NaN;
    
% CHANGE TO CENTRAL DIFFERENCING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     dT = timeStamp_plot(2) - timeStamp_plot(1);
%     for i = 2:length(numFilms)-1
%         flowRate(i) = (dimpVol(i+1) - dimpVol(i-1))/(2*dT);
%     end
%     
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SA_cyl_ave = (SA_cyl(1:end-1)+SA_cyl(2:end))/2;
% Hmin_ave = (Hmin(1:end-1)+Hmin(2:end))/2;
% shearRate = -(flowRate./SA_cyl_ave)./(Hmin_ave/2000); % ?????????????
    % Note convert height to micron and divide by 2
    
    % if exist('T','var')
    %     timeStamps = T.cumulStamps(selected);
    % else
    %     timeStamp_plot = selected;
    % end
    
    if save_check == 1
        
        T_film_shear = table(radius_bar{1}, shearRate_power{1:end},...
            'VariableNames', ['radius_bar',T_film_plot.Properties.VariableNames(2:end-1)]);
        max_radius_I = max(Hmin_I);
        dimpVol_rim = zeros(max(size(dimpVol)),1);
        dimpVol_Hmin = zeros(max(size(dimpVol)),1);
        for ii = 1:max(size(dimpVol))
            dimpVol_rim(ii) = sum(dimpVol{ii}(1:max_radius_I));
            dimpVol_Hmin(ii) = sum(dimpVol{ii}(1:Hmin_I(ii)));
        end
        
        
        max_dimpVol = cellfun(@max,dimpVol);
        max_flowRate = cellfun(@max, flowRate);
        max_flowRate(end+1) = NaN;
        max_shearRate = cellfun(@max, shearRate);
        max_shearRate(end+1) = NaN;
        
        T_film_metrics = table(fileNum_plot,timeStamp_plot,round(Hcent,4),...
            round(Hmin,4),round(Rrim,4),...
            round(max_dimpVol,4),round(max_flowRate,4),round(max_shearRate,4),...
            round(dimpVol_rim,4), round(dimpVol_Hmin,4),...
            'VariableNames', {'fileNum', 'timeStamp', 'Hcent_nm',...
            'Hmin_nm', 'Rrim_micron', 'max_dimpVol_micron_cubed',...
            'max_flowRate_micron_cubed_persec', 'max_shearRate_persec',...
            'dimpVol_rim','dimpVol_Hmin'});
        
        if load_check == 0
            file_name_metrics = strcat(film_plot_file(1:end-4), '-metrics');
            file_name_shear = strcat(film_plot_file(1:end-4), '-shearRate');
        
        else
%             file_name = strcat(conc, sample, '-',expNum, '-films-plot', version);
            file_name = strcat(folder_parts(end-1), '-films-plot', version);
            file_name_metrics = strcat(file_name, '-metrics');
            file_name_shear = strcat(file_name, '-shearRate');
        end
        
        saveData(T_film_metrics, film_plot_path, file_name_metrics);
        saveData(T_film_shear, film_plot_path, file_name_shear);
    end 
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

if film_plotter == 1
    
    if exist('T_film_plot','var') == 1
        
        load_check_prompt = 'Would you like to use currently loaded film data table?: [1/0] ';
        load_check = input(load_check_prompt);
        
        while isempty(load_check) == 1
            load_check = input(load_check_prompt);
        end
    end
    
    if exist('T_film_plot','var') == 0 || load_check == 0
    load_check = 0;
        %---Select files  manually for film plotting-------------------------
        disp('Select film plot data');
        [film_plot_file, film_plot_path] = uigetfile(strcat(folder,'*.txt'),...
            'Select the thin film data to analyse', 'MultiSelect','off');
        
        % Turn off convert to cell b/c only one file
%         if iscell(film_plot_file) == 0
%             film_plot_file = {film_plot_file};
%         end
%         
        T_film_plot = readtable(strcat(film_plot_path, film_plot_file));
    
    end
    
    if exist('T_film_metrics','var') == 1
        
        load_check_prompt = 'Would you like to use currently loaded film metrics table?: [1/0] ';
        load_check = input(load_check_prompt);
        
        while isempty(load_check) == 1
            load_check = input(load_check_prompt);
        end
    end
    
    if exist('T_film_metrics','var') == 0 || load_check == 0
    
        %---Select files  manually for film plotting-------------------------
        disp('Select film metrics data');
        [film_metrics_file, film_metrics_path] = uigetfile(strcat(folder,'*.txt'),...
            'Select the thin film data to analyse', 'MultiSelect','off');
        
        % Turn off convert to cell b/c only one file
%         if iscell(film_plot_file) == 0
%             film_plot_file = {film_plot_file};
%         end
%         
        T_film_metrics = readtable(strcat(film_metrics_path,film_metrics_file));
    
    end
    
    if exist('T_film_shear','var') == 1
        
        load_check_prompt = 'Would you like to use currently loaded film shear table?: [1/0] ';
        load_check = input(load_check_prompt);
        
        while isempty(load_check) == 1
            load_check = input(load_check_prompt);
        end
    end
    
    if exist('T_film_shear','var') == 0 || load_check == 0
    
        %---Select files  manually for film plotting-------------------------
        disp('Select film shear data');
        [film_shear_file, film_shear_path] = uigetfile(strcat(folder,'*.txt'),...
            'Select the thin film shear rate data to analyse', 'MultiSelect','off');
        
        % Turn off convert to cell b/c only one file
%         if iscell(film_plot_file) == 0
%             film_plot_file = {film_plot_file};
%         end
%         
        T_film_shear = readtable(strcat(film_shear_path,film_shear_file));
    
    end
    %--------------------------------------------------------------------------
    % Make figures
    %--------------------------------------------------------------------------
    
    % make function to take tabulated input
    film_plot(T_film_metrics, T_film_plot,T_film_shear)
    
    if save_check == 1
        
        version_prompt = 'Input a version number: ';
        version = input(version_prompt,'s');
        version = strcat('V',version);
        
       print('-f1', '-r300','-dpng',...
           fullfile(folder,film_plot_folder,strcat(abbre,'_',expNum,...
           '_films_',version, '.png'))); 
       
       print('-f2', '-r300','-dpng',...
           fullfile(folder,film_plot_folder,strcat(abbre,'_',expNum,...
           '_Hcent_',version,'.png')));
       
       print('-f3', '-r300','-dpng',...
           fullfile(folder,film_plot_folder,strcat(abbre,'_',expNum,...
           '_Hmin_',version,'.png')));
       
       print('-f4', '-r300','-dpng',...
           fullfile(folder,film_plot_folder,strcat(abbre,'_',expNum,...
           '_Rdimp_',version,'.png')));
       
        print('-f5', '-r300','-dpng',...
           fullfile(folder,film_plot_folder,strcat(abbre,'_',expNum,...
           '_shearRate_',version,'.png')));
       
       if ishandle(6)
           print('-f6', '-r300','-dpng',...
               fullfile(folder,film_plot_folder,strcat(abbre,'_',expNum,...
               '_dimpVol_',version,'.png')));
           
       end
    end
        
       
    
    %--------------------------------------------------------------------------
end

