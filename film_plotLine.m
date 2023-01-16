
% close all

file_save = '3000-228.png';

folder = "/Volumes/T7/Thin films/MultiCam/C6F14drop_H2O/C6F14drop_H2O_0p1mMKCl_run3/";
% csvFile = "1p9wtCNC_run1_TimeStamps.csv";

%--------------------------------------------------------------------------
% END Input settings
%--------------------------------------------------------------------------

if ~exist(folder,'dir')
    folder = pwd;
end

disp("Select thin film data");
[red_files, red_path] = uigetfile(strcat(folder,'*.txt'),...
    'Select thin film file', 'MultiSelect','on');

if iscell(red_files) == 0
    red_files = {red_files};
end


figure();
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


xlabel('Lateral dimension (\mum)','FontWeight','bold');
ylabel('Film thickness (nm)','FontWeight','bold');
    

% Colour blind palette
pal = {'#000000','#004949','#009292','#ff6db6','#ffb6db','#490092',...
    '#006ddb','#b66dff','#6db6ff','#b6dbff','#920000',...
    '#924900','#db6d00','#24ff24','#ffff6d'};

numFilms = size(red_files,2);

for i = 1:numFilms 

    T_red = importdata(strcat(red_path, red_files{i}),'\t',1);
    radius = T_red.data(:,1);
    red_film = T_red.data(:,3);

    str = pal{2*i-1};
    color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
    scatter(radius, red_film, 30, color,'filled')

    % scatter(-rad_blue, blue_int, 50, color,'filled')

end

ax.YLim = [0, 300];
% % leg_string = strcat(string(round(T_film_metrics.timeStamp,0)), repmat(" s", [max(size(T_film_metrics.timeStamp)),1]));
% legend(leg_string, 'Box','off');
% hold off


% print('-f1', '-r300','-dpng',file_save);