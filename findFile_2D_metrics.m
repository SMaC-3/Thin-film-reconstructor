% Code written by Joshua P. King, SMaCLab, Monash University, Australia
% 2022

%   ________  ___      ___       __       ______   ___            __       _______   
%  /"       )|"  \    /"  |     /""\     /" _  "\ |"  |          /""\     |   _  "\  
% (:   \___/  \   \  //   |    /    \   (: ( \___)||  |         /    \    (. |_)  :) 
%  \___  \    /\\  \/.    |   /' /\  \   \/ \     |:  |        /' /\  \   |:     \/  
%   __/  \\  |: \.        |  //  __'  \  //  \ _   \  |___    //  __'  \  (|  _  \\  
%  /" \   :) |.  \    /:  | /   /  \\  \(:   _) \ ( \_|:  \  /   /  \\  \ |: |_)  :) 
% (_______/  |___|\__/|___|(___/    \___)\_______) \_______)(___/    \___)(_______/  
                                                                                   

% SMaCLab website can be found here:
% https://sites.google.com/view/smaclab

%--------------------------------------------------------------------------

function [T_metrics, metrics_files, num_metrics] =...
    findFile_2D_metrics(metrics_path, selected)

if isempty(selected) == 1

    [metrics_files, ~] = uigetfile(strcat(metrics_path,'*.txt'),...
        'Select the film data', 'MultiSelect','on');

else

    all_films_struct = dir(fullfile(metrics_path, '*.txt'));
    all_films_cell = struct2cell(all_films_struct).';
    all_films_names = all_films_cell(:,1);
    file_parts = split(all_films_names, {'-'});
    if length(selected) == 1
        file_num = str2double(file_parts(3));
    else
        file_num = str2double(file_parts(:,3));
    end
    %
    % if selected == 0
    %     % select all files
    %     metrics_files = all_films_names;
    %
    % else
    [~, selected_I] = ismember(selected, file_num);
    %     selected_I = logical(selected_I);
    metrics_files = all_films_names(selected_I);
    %
end


%--------------------------------------------------------------------------
num_metrics = length(metrics_files);
%--------------------------------------------------------------------------
metrics_data = zeros(num_metrics,4);
% metrics_data = zeros(num_metrics,5);

for i =1:num_metrics
   A = readmatrix(fullfile(metrics_path,...
       metrics_files{i}), 'NumHeaderLines',7); 
   metrics_data(i,1:4) = A(1:4);
end

timeStamps_select = metrics_data(:,1);
rim_h = metrics_data(:,2);
center_h = metrics_data(:,3);
dimp_vol = metrics_data(:,4);
% ave_h = metrics_data(:,5);

% T_metrics = table(timeStamps_select, rim_h, center_h, dimp_vol,ave_h,...
%     'VariableNames',["Time_stamps_(s)", "Center_h_(nm)",...
%     "Rim_h_(nm)",...
%     "Dimple_vol_(micron^3)",...
%     "Average_h_(nm)"]);
T_metrics = table(timeStamps_select, rim_h, center_h, dimp_vol,...
    'VariableNames',["Time_stamps_(s)", "Center_h_(nm)",...
    "Rim_h_(nm)",...
    "Dimple_vol_(micron^3)"]);

end