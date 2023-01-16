
%--------------------------------------------------------------------------
% INTENSITY_DATAPROCESSOR normalise 1D intensity vs radius data and
% reconstruct thin film profile 
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%% Info about user input settings
%--------------------------------------------------------------------------

close all
% clearvars -except folder
format default

%--------------------------------------------------------------------------
% Input settings - USER TO MODIFY
%--------------------------------------------------------------------------

%---Index of files to be procesed------------------------------------------
save_check = 1; % 1 = save info, 0 = do not save info 
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
folder = "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_run3/";
% csvFile = "1p9wtCNC_run1_TimeStamps.csv";

int_folder = 'red-int-sectors/';
int_sub_folder = 'red-1D-LineInt-0/';
%--folder names 

norm_save = strcat(int_sub_folder(1:end-1),'-norm/');
film_save = strcat(int_sub_folder(1:end-1),'-films/');

%---global intensity directory info
global_max_min = 0; 
% Set to 1 to use global max/min within data set,
% set to 0 to provide an altenative data set below for global exrema

global_int_folder = "/Volumes/T7/Thin films/MultiCam/SDS/150mM_SDS/150mM_SDS_globalExtrema_run3/";
global_int_red_dir = "red-int-sectors/red-1D-int-0-360-surfFit-WBcor/";
global_path = fullfile(global_int_folder,global_int_red_dir);

%--------------------------------------------------------------------------
% END Input settings
%--------------------------------------------------------------------------

if ~exist(folder,'dir')
    folder = pwd;
end

reduced_data_folder = strcat('data-normalised-line/',norm_save);
reduced_data_path = strcat(folder, reduced_data_folder);

film_data_folder = strcat('thin-films-line/',film_save);
film_data_path = strcat(folder, film_data_folder);


%---Select files manually for reduction-----------------------------------
disp("Select red intensity data");
[red_files, red_path] = uigetfile(strcat(folder,...
    int_folder,int_sub_folder,'*.txt'),...
    'Select the subtracted red-files', 'MultiSelect','on');

if iscell(red_files) == 0
    red_files = {red_files};
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% PERFORM DATA REDUCTION
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%% Find global max & min for blue and red intensity data
%--------------------------------------------------------------------------
lower_bound = 5;
% % Only use data within dimple region, so set this as cutoff radius

if global_max_min == 1
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

    % Import red data
    disp(red_files{1});
    T_red = importdata(strcat(red_path, red_files{1}),'\t',8);
    radius = T_red.data(:,2);
    red_int = T_red.data(:,3);

    %%%%%%%%%%
    figure(1)
    plot(radius,red_int,'LineWidth',1.5,'Color','red')

    trim = 'Enter upper bound for data: ';
    cutoff = input(trim);
    while isempty(cutoff)
        cutoff = input(trim);
    end
    
    [~, I_cutoff] = min(abs(radius - cutoff));
    red_max_dimp_ind = I_cutoff;

    red_allData = cell(size(red_Allfiles));
   
    % Import all red and blue intensity data
    parfor i = 1:max(size(red_Allfiles))
        T_red = importdata(strcat(red_path, red_Allfiles{i}),'\t',8);
        red_allData{i} = T_red.data(lower_bound:red_max_dimp_ind,3);
    end

    % Find global maximum and minimum in red and blue data
    red_int_max = max(cellfun(@max, red_allData));
    red_int_min = min(cellfun(@min, red_allData));

elseif global_max_min == 0
 
    % Make sure that only actual red intensity data is used
    red_files_struct = dir(fullfile(global_path, '*.txt'));
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

    % Import red data
    T_red = importdata(strcat(global_path, red_Allfiles{end}),'\t',8);
    radius = T_red.data(:,2);
    red_int = T_red.data(:,3);

    %%%%%%%%%%
    figure(1)
    plot(radius,red_int,'LineWidth',1.5,'Color','red')

    trim = 'Enter upper bound for data: ';
    cutoff = input(trim);
    while isempty(cutoff)
        cutoff = input(trim);
    end
    
    [~, I_cutoff] = min(abs(radius - cutoff));
    red_max_dimp_ind = I_cutoff;

    red_allData = cell(size(red_Allfiles));
   
    % Import all red and blue intensity data
    parfor i = 1:max(size(red_Allfiles))
        T_red = importdata(strcat(global_path, red_Allfiles{i}),'\t',8);
        red_allData{i} = T_red.data(lower_bound:red_max_dimp_ind,3);
    end

    % Find global maximum and minimum in red and blue data
    red_int_max = max(cellfun(@max, red_allData));
    red_int_min = min(cellfun(@min, red_allData));

else
    error('global max/min par not recognised')
end
%--------------------------------------------------------------------------
%% Normalise data
%--------------------------------------------------------------------------

norm_red = zeros(length(radius),max(size(red_files)));
h_inv_red = zeros(length(radius),max(size(red_files)));
% h_inv_red = cell(max(size(red_files)),1);
% h_min_red = zeros(max(size(red_files)),1);

lamb_red = 630;
lamb_blue = 450;
n1 = 1.33; % refractive index of water

factor_red = (4*pi*n1)/lamb_red; % convert argument to height

parfor i = 1:size(red_files,2)

    %----------------------------------------------------------
    % Normalise data
    %----------------------------------------------------------

    T_red = importdata(strcat(red_path, red_files{i}),'\t',8);
    radius = T_red.data(:,2);
    red_int = T_red.data(:,3);

    norm_red(:,i) = ...
        (2*red_int - (red_int_max+red_int_min))...
        ./(red_int_max-red_int_min);

    h_inv_red(:,i) = acos(norm_red(:,i))./factor_red; 
    % acos returns value b/w [0, pi]
end

%% clean up and export
h_inv_red = real(h_inv_red);
h_inv_red(I_cutoff:end,:) = 0;
zap_red = find(h_inv_red ==0);
h_inv_red(zap_red) = NaN;
% h_inv_red(1:2,:) = NaN;

if save_check == 1
    parfor i = 1:size(red_files,2)

        T_norm = table(radius, round(norm_red(:,i),4),'VariableNames',...
            {'radius (micron)','red_int_norm'});
        T_h_red = table(radius, round(h_inv_red(:,i),4),'VariableNames',...
            {'radius (micron)','red_film'});

        file_name_norm = strcat(red_files{i}(5:end-4),'-reduced');
        file_name_h = strcat('film-',file_name_norm);

        reduced_data_path = strcat(folder, reduced_data_folder);
        film_data_path = strcat(folder, film_data_folder);

        saveData(T_norm, reduced_data_path,file_name_norm);
        saveData(T_h_red, film_data_path,file_name_h);

    end
end
%% plot

h_min_red = min(h_inv_red(5:end,:));

%%%%%%%%%%%%%%
figure(2)
hold on
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

xlabel('Film count','FontWeight','bold');
ylabel('Minimum film thickness (nm)','FontWeight','bold');
scatter(linspace(1,length(h_min_red),length(h_min_red)), min(h_inv_red))

%%%%%%%%%%%%%%
figure(3)
hold on
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
ax.YLim = [0,200];

xlabel('Lateral dimension (\mum)','FontWeight','bold');
ylabel('Film thickness (nm)','FontWeight','bold');
scatter(radius, h_inv_red(:,end))

%%%%%%%%%%%%

%     alpha = linspace(0.1,1,size(red_files,2));
%     scatter(radius, abs(h_inv_blue),'filled','MarkerFaceColor',...
%         [alpha(i)/1.5,0,1-alpha(i)],'MarkerFaceAlpha',alpha(i))
%
%         figure(3)
%     hold on
%     fig = gcf;
%     ax = gca;
%
%     fig.Color = 'white';
%
%     % ax.Units = 'centimeters';
%     ax.LineWidth = 1.5;
%     ax.XColor = 'k';
%     ax.YColor = 'k';
%     ax.FontName = 'Helvetica';
%     ax.FontSize = 18;
%     ax.FontWeight = 'bold';
%     ax.Box= 'off';
%     ax.YLim = [0,200];
%
%     xlabel('Lateral dimension (\mum)','FontWeight','bold');
%     ylabel('Film thickness (nm)','FontWeight','bold');
%
%     alpha = linspace(0.1,1,size(red_files,2));
%     scatter(radius, abs(h_inv_red),'filled','MarkerFaceColor',...
%         [alpha(i)/1.5,0,1-alpha(i)],'MarkerFaceAlpha',alpha(i))
%
%
%     figure(4)
%     hold on
%     scatter(i, min(h_inv_red(1:150)))
%
%     if save_check ==1
%         % saveData function
%         file_parts = split(red_files{i}, {'-','_','.'});
%         line_angle_folder = strcat('thinFilms-',...
%             file_parts{end-2},'-',file_parts{end-1});
%
%         film_data_path_angle = strcat(film_data_path,line_angle_folder,'/');
%         file_name = strcat('film-',red_files{i}(5:end-4));
%         saveData(T_dimp, film_data_path_angle,file_name);
%     end








