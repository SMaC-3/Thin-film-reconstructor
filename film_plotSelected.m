
clear all
% close all


%%
folder = "/Volumes/T7/Thin films/MultiCam/Xgum/1000ppm_Xgum/1000ppm_Xgum_0p1mMKCl_0p2umF_run9/";
csvFile = "1000ppm_Xgum_0p1mMKCl_0p2umF_run9_TimeStamps.csv";

[film_files, film_path] = uigetfile(strcat(folder,'thin-films/','*.txt'),...
    'Select the film data', 'MultiSelect','on');


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



%%
figure(2);
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
ax.TickDir = 'out';


xlabel('Lateral dimension / \mum','FontWeight','bold');
ylabel('Film thickness / nm','FontWeight','bold');


% Colour blind palette
pal = {'#000000','#004949','#009292','#ff6db6','#ffb6db','#490092',...
    '#006ddb','#b66dff','#6db6ff','#b6dbff','#920000',...
    '#924900','#db6d00','#24ff24','#ffff6d'};

all_films = cell(max(size(film_files)),1);

upper_rad = 300;

rad_h = 220;
upper_h = 145;


for i = 1:size(film_files,2)
    T_film = readtable(strcat(film_path, film_files{i}));
    all_films{i} = T_film;
    radius = T_film.radius;
    red_film = T_film.red_film;
    blue_film = T_film.blue_film;

    [~, upper_rad_I] = min(abs(radius-upper_rad));
    radius(upper_rad_I:end) = nan; 

    [~, rad_h_I] = min(abs(radius-rad_h));
    mask_radius = radius > rad_h_I; 
    mask_film = red_film > upper_h;
%     mask = mask_film & mask_radius;
    mask = radius > rad_h_I & red_film > upper_h;
    red_film(mask) = nan;
%     scatter([-radius; radius], [blue_film;blue_film], 20, [0 0 1],'filled', 'MarkerFaceAlpha',0.5);
%     hold on
%     scatter([-radius; radius], [red_film;red_film], 20, [1 0 0],'filled', 'MarkerFaceAlpha',0.5);
%     
%     delta_col(i) = nanmean(abs(red_film(1:186) - blue_film(1:186)));
%     delta_col_ave_square(i) = sqrt(nanmean(abs(red_film(1:186) - blue_film(1:186)).^2));
%     

    str = pal{i};
    color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
    hold on
% scatter([-radius; radius], [red_film;red_film], 30, color,'filled');
%% 
% scatter([-radius; radius], [blue_film;blue_film], 30, color,'filled');

scatter([-radius; radius], [red_film;red_film], 30, 'red','filled');
scatter([-radius; radius], [blue_film;blue_film], 30, 'blue','filled');
    

end

lg = legend(strcat(string(round(timeStamps_select,0)), ' s'));
lg.Box = "off";
% lg.String = timeStamps_str;
% lg.String = cellstr(num2str(fileNums_I));