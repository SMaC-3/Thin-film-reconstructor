%---main branch directory info---------------------------------------------
folder = "/Volumes/T7/Thin films/MultiCam/CNC_dialysed/1p9wtCNC_V2/1p9wtCNC_V2_run5/";
csvFile = "1p9wtCNC_V2_run5_TimeStamps.csv";

% DON'T FORGET TO CHANGE FLOW INDEX!

n=0.58; 
m = 0.16; % Flow consistency index in Pa.s^n
R = 0.2; % Setting "R" in Winter paper to dimple radius, in um

save_check = 1;

[metrics_files, metrics_path] = uigetfile(strcat(folder,'thin-films-1D-metrics-discrete/','*.txt'),...
    'Select the film data', 'MultiSelect','on');

metrics_data = cell(size(metrics_files));

for i = 1:size(metrics_files,2)
    import_data = readmatrix(strcat(metrics_path, metrics_files{i}));
    timeStamps(i,1) = import_data(1,2);
    metrics_data{i} = readmatrix(strcat(metrics_path, metrics_files{i}),"NumHeaderLines",2);
%     radius_bar =
%     height_bar =
%     SA_cyl =
%     vol =
end

% film_metrics_1D_shearRate_calculator(metrics_data, timeStamps,...
%     folder,csvFile, save_check)

% function [T_metrics] =...
%     film_metrics_1D_shearRate_calculator(metrics_data, timeStamps,...
%     folder,csvFile, save_check)
%---power-law exponent-----------------------------------------------------
%%
numFilms = max(size(metrics_data));
flowRate = cell(numFilms-1,1);

figure()
hold on

for i = 1:numFilms
    for j = 1:length(metrics_data{i})

        if i == 1 % forward differencing
            flowRate{i,1}(j,1) = (sum(metrics_data{i+1}(1:j,4)) - sum(metrics_data{i}(1:j,4))) /...
                (timeStamps(i+1)-timeStamps(i));
            %     = diff(dimpVol)./(diff(timeStamp_plot));

        elseif i == numFilms % backward differencing

            flowRate{i,1}(j,1) = (sum(metrics_data{i}(1:j,4)) - sum(metrics_data{i-1}(1:j,4))) /...
                (timeStamps(i)-timeStamps(i-1));
        
        else % central differencing

            flowRate{i,1}(j,1) = (sum(metrics_data{i+1}(1:j,4)) - sum(metrics_data{i-1}(1:j,4))) /...
                (timeStamps(i+1)-timeStamps(i-1));
        end
    end


%     shearRate{i,1} = -6*(flowRate{i}./(metrics_data{i}(:,3)/2+metrics_data{i+1}(:,3)/2))./...
%         ((metrics_data{i}/2+metrics_data{i+1}/2)/1000);

%%% INCORRECT EQAUTION YOU #$@%&!

% shearRate_power{i,1} = -(flowRate{i}./(2*pi)./(metrics_data{i}(:,1)/2 + metrics_data{i+1}(:,1)/2)).*...
%     ((2*n+1)/n).*(2./((metrics_data{i}(:,2)/2 + metrics_data{i+1}(:,2)/2)/1000)).^((1+n)/n);
%     shearRate_power{i,1} = -(flowRate{i}./(2*pi)./(metrics_data{i}(:,1))).*...
%         ((2*n+1)/n).*(2./((metrics_data{i}(:,2))/1000)).^((1+n)/n);

%%%% 

%     shearRate_power{i,1} = -(flowRate{i}./(pi.*metrics_data{i}(:,1).*((metrics_data{i}(:,2)/1000).^2))).*...
%         ((2*n+1)/n).*(2./((metrics_data{i}(:,2))/1000)).^((1)/n); % SHOULD THIS BE 2/H OR JUST 2?
% 
%     shearRate_power{i,1} = -(flowRate{i}./(pi.*metrics_data{i}(:,1).*((metrics_data{i}(:,2)/1000).^2))).*...
%         ((2*n+1)/n).*(2).^((1)/n); % SHOULD THIS BE 2/H OR JUST 2?

        shearRate_power{i,1} = -(flowRate{i}./(pi.*metrics_data{i}(:,1).*((metrics_data{i}(:,2)/1000).^2))).*...
        ((2*n+1)/n); % SHOULD THIS BE 2/H OR JUST 2?

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% CHECK WITH JOE THAT BELOW IMPLEMENTATION OF PRESSURE EQUATION
    %%%% IS CORRECT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %       pressure{i,1} = ((2*n+1)/n)^n.*(flowRate{i}./(pi*R.*(height_bar{i}/2 + height_bar{i+1}/2)/1000)).^n...
    %           .*((2*m*R)./((height_bar{i}/2 + height_bar{i+1}/2)/1000).*(1-n)).*...
    %           (1-((radius_bar{i}/2 + radius_bar{i+1}/2)./R).^(1-n) );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(metrics_data{i}(:,1), shearRate_power{i})

end

%% Save metrics info
if save_check == 1

    metrics_data_folder = 'thin-films-1D-metrics-shearRate/';

    if exist(fullfile(folder,metrics_data_folder),"dir") == 0
        mkdir(fullfile(folder,metrics_data_folder));
    end

    metrics_path = fullfile(folder, metrics_data_folder);
    
    for i = 1:length(metrics_files)
        
        file_parts = split(metrics_files{i}, '-discrete-metrics.txt');
        file_name_metrics = strcat(file_parts{1},'-shearRate.txt');

        full_metrics_discrete = fullfile(metrics_path,...
            file_name_metrics);
% n=0.36;
% m = 2; % Flow consistency index in Pa.s^n
% R = 0.2; % Setting "R" in Winter paper to dimple radius, in um
        cellSave_discrete = [...
            {'TimeStamp: ',round(timeStamps(i),4),'';...
            'Flow index',n,'';...
            'Flow consistency Pa.s^n',m,'';...
            'radius_bar','flow_rate','shear_rate'};...
            table2cell(table(metrics_data{i}(:,1),flowRate{i}, shearRate_power{i}))];

        writecell(cellSave_discrete, full_metrics_discrete, 'Delimiter', '\t');

    end
end
% end