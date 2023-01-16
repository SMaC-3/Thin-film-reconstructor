function [int_min, int_max] =...
    intensity_globalExtrema_V2(int_path, channel, lb_cutoff, up_cutoff)
%--------------------------------------------------------------------------
% Info about user input settings
%--------------------------------------------------------------------------

%close all
%clearvars -except folder
format bank

%--------------------------------------------------------------------------
% Input settings - USER TO MODIFY
%--------------------------------------------------------------------------

%---Index of files to be procesed------------------------------------------
% save_check = 0; % 1 = save info, 0 = do not save info 
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------

% int_path = fullfile(folder, red_dir);

%--------------------------------------------------------------------------
% END Input settings
%--------------------------------------------------------------------------

if ~exist(int_path,'dir')
    error("Intensity data folder not recognised")
end

%--------------------------------------------------------------------------
% Find global max & min for blue and red intensity data
%--------------------------------------------------------------------------

% Make sure that only actual red intensity data is used

int_files_struct = dir(fullfile(int_path, '*.txt'));
int_Allfiles = struct2cell(int_files_struct).';
int_Allfiles = int_Allfiles(:,1);
int_check = zeros(size(int_Allfiles));

for j = 1:max(size(int_Allfiles))
    check_val = int_Allfiles{j}(1:3);
    if check_val== channel
        int_check(j) = 1;
    else
        int_check(j) = 0;
    end
end

int_check = logical(int_check);
int_Allfiles = int_Allfiles(int_check);
if isempty(int_Allfiles) == 1
    error("Wrong channel input");
end
int_allData = cell(size(int_Allfiles));


% Only use data within dimple region, so set this as cutoff radius

T_int = importdata(strcat(int_path, int_Allfiles{end}),'\t',8);
radius = T_int.data(:,2);
int_raw = T_int.data(:,3);


% 
% trim = 'Enter upper bound for data: ';
% cutoff = input(trim);
% while isempty(cutoff)
%     cutoff = input(trim);
% end


[~, I_cutoff] = min(abs(radius - up_cutoff));

int_max_dimp_ind = I_cutoff;
figure(1)
plot(radius,int_raw,'LineWidth',1.5,'Color',channel)
hold on
plot([radius(I_cutoff), radius(I_cutoff)], [min(int_raw),max(int_raw)],...
    'LineWidth',1.5, 'LineStyle','--','Color','black')
plot([lb_cutoff,lb_cutoff], [min(int_raw),max(int_raw)],...
    'LineWidth',1.5, 'LineStyle','--', 'Color','black')
hold off

% lb_cutoff = 5;

% Import all red and blue intensity data
for i = 1:max(size(int_Allfiles))
    T_int = importdata(strcat(int_path, int_Allfiles{i}),'\t',8);
    int_allData{i} = T_int.data(lb_cutoff:int_max_dimp_ind,3);
end

% Find global maximum and minimum in red and blue data
int_max = max(cellfun(@max, int_allData));
int_min = min(cellfun(@min, int_allData));

end
