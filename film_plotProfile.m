

% [red_file, red_path] = uigetfile('*.txt',...
%     'Select the subtracted red-files', 'MultiSelect','on');
% [blue_file, blue_path] = uigetfile('*.txt',...
%     'Select the subtracted blue-files', 'MultiSelect','on');

% test import code

folder = '/Volumes/Z_MS-DOS/Thin films/MultiCam/CNC/6wtCNC/6wtCNC_run2/'; 
csvFile = '6wtCNC_run2_TimeStamps.csv';


red_folder = 'red-tiff/red-1D-int/red-film/';
blue_folder = 'blue-tiff/blue-1D-int/blue-film/';

red_path = strcat(folder, red_folder);
blue_path = strcat(folder, blue_folder);

% selected = [669, 569, 475, 375,275,225,195];
selected = [440, 460, 480, 500, 510];

csvRead = strcat(folder, csvFile);
T = readtable(csvRead, 'Delimiter',',');
T(end, :) = [];

% name = '_int_1D';
name_red = '_int_1_red_film';
name_blue = '_int_1_blue_film';
type = '.txt';

nameID = T.Index;
red_names = T.red_file_names;
blue_names = T.blue_file_names;

    for i = 1:length(selected)
    choose(i) = find(nameID==selected(i));
    end
    
    red_files = {red_names{choose}};
    blue_files = {blue_names{choose}};

    for i = 1:length(red_files)
    red_files{i} = strcat(red_files{i}(1:end-5), name_red, type);
    blue_files{i} = strcat(blue_files{i}(1:end-5), name_blue, type);
    end

figure('Color','white'); %half page
hold on
fig = gcf;
ax = gca;

% ax.Units = 'centimeters';
ax.LineWidth = 1.5;
ax.XColor = 'k';
ax.YColor = 'k';
ax.FontName = 'Helvetica';
ax.FontSize = 18;
ax.FontWeight = 'bold';
ax.Box= 'off';


xlabel('Lateral dimension (\mum)','FontWeight','bold');
ylabel('Film thickness (nm)','FontWeight','bold');
    

% Colour blind palette
pal = {'#000000','#004949','#009292','#ff6db6','#ffb6db','#490092','#006ddb','#b66dff','#6db6ff','#b6dbff','#920000','#924900','#db6d00','#24ff24','#ffff6d'};
    
for i = 1:length(selected)    
% T_red = importdata(strcat(red_path, red_files{i}),'\t',1);
% rad_red = T_red.data(:,1);
% red_int = T_red.data(:,2);

T_blue = importdata(strcat(blue_path, blue_files{i}),'\t',1);
rad_blue = T_blue.data(:,1);
blue_int = T_blue.data(:,2);

str = pal{i};
color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
scatter([-rad_blue; rad_blue], [blue_int;blue_int], 50, color,'filled')

% scatter(-rad_blue, blue_int, 50, color,'filled')

end
legend(string(selected), 'Box','off');
hold off












