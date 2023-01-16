 


%---main branch directory info---------------------------------------------
folder = "/Volumes/T7/Thin films/MultiCam/CNC_dialysed/3p5wtCNC/3p5wtCNC_run4/";
csvFile = "3p5wtCNC_run4_TimeStamps.csv";

[metrics_files, metrics_path] = uigetfile(strcat(folder,'thin-films-1D-metrics-shearRate/','*.txt'),...
    'Select the film data', 'MultiSelect','on');
%%
metrics_data = cell(size(metrics_files));

for i = 1:size(metrics_files,2)
    import_data = readmatrix(strcat(metrics_path, metrics_files{i}));
    timeStamps(i,1) = import_data(1,2);
    metrics_data{i} = readmatrix(strcat(metrics_path, metrics_files{i}),"NumHeaderLines",4);
    shearRate_power{i} = metrics_data{i}(:,3);
end

radius_bar = metrics_data{1}(:,1);

T_film_shear = table(radius_bar, shearRate_power{1:end});

numFilms = size(metrics_files,2);
%%
figure();
hold on
fig4 = gcf;
ax4 = gca;



fig4.Color = 'white';

% ax.Units = 'centimeters';
ax4.LineWidth = 1.5;
ax4.XColor = 'k';
ax4.YColor = 'k';
ax4.FontName = 'Helvetica';
ax4.FontSize = 18;
ax4.FontWeight = 'bold';
ax4.Box= 'off';


xlabel('Lateral dimension / \mum','FontWeight','bold');
ylabel('Shear rate / s^{-1}','FontWeight','bold');


% Colour blind palette
pal = {'#000000','#004949','#009292','#ff6db6','#ffb6db','#490092',...
    '#006ddb','#b66dff','#6db6ff','#b6dbff','#920000',...
    '#924900','#db6d00','#24ff24','#ffff6d'};

for i = 1:numFilms
    str = pal{i};
    color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
    plot([T_film_shear.radius_bar], [T_film_shear{:,i+1}], 'Color',color,...
        'LineWidth',1.5)
    
    % scatter(-rad_blue, blue_int, 50, color,'filled')
    
end

lg = legend(strcat(string(round(timeStamps,0)), ' s'));
lg.Box = 'off';