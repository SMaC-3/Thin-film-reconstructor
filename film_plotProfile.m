close all

%--------------------------------------------------------------------------
% Import information - USER TO MODIFY
%--------------------------------------------------------------------------

%selected = [350,485,635,785,886];
selected = [420, 520, 620, 720, 820];
folder = '/Volumes/ZIGGY/Thin films/MultiCam/CNC/4p5wtCNC/4p5wtCNC_run8/'; 
csvFile = '4p5wtCNC_run8_TimeStamps.csv';
save_folder = '/Users/jkin0004/Google Drive/University/PhD/Research/Thin film model/Thin film experimental/Interferometry_code/thinFilm_figs/matVarFiles/';

%--------------------------------------------------------------------------
% Check if workspace variables exist. If yes - no need to import, if no - imported
%--------------------------------------------------------------------------

if exist('int','var') == 0
    
    % red_folder = 'red-tiff/red-1D-int/red-film/';
    % blue_folder = 'blue-tiff/blue-1D-int/blue-film/';
    red_folder = 'red-film/';
    blue_folder = 'blue-film/';
    
    red_path = strcat(folder, red_folder);
    blue_path = strcat(folder, blue_folder);
    
    
    [red_files, red_path] = uigetfile('*.txt',...
        'Select the subtracted red-files', 'MultiSelect','on');
    [blue_files, blue_path] = uigetfile('*.txt',...
        'Select the subtracted blue-files', 'MultiSelect','on');
    
    csvRead = strcat(folder, csvFile);
    T = readtable(csvRead, 'Delimiter',',');
    T(end, :) = [];
%     
    name = '_int_1D';
    name_red = '_int_1_red_film';
    name_blue = '_int_1_blue_film';
    type = '.txt';
%     
%     nameID = T.Index;
%     red_names = T.red_file_names;
%     blue_names = T.blue_file_names;
%     
%     for i = 1:length(selected)
%         choose(i) = find(nameID==selected(i));
%     end
%     
%     red_files = {red_names{choose}};
%     blue_files = {blue_names{choose}};
    
%     for i = 1:length(red_files)
%         red_files{i} = strcat(red_files{i}(1:end-5), name_red, type);
%         blue_files{i} = strcat(blue_files{i}(1:end-5), name_blue, type);
%     end
    
    figure(1)
    
    rad = cell(length(selected),1);
    
    int = cell(length(selected),1);
    col_choice = cell(length(selected),1);
    
    for i = 1:length(selected)
        % T_red = importdata(strcat(red_path, red_files{i}),'\t',1);
        % rad_red = T_red.data(:,1);
        % red_int = T_red.data(:,2);
        
        T_blue = importdata(strcat(blue_path, blue_files{i}),'\t',1);
        rad_blue = T_blue.data(:,1);
        blue_int = T_blue.data(:,2);
        
        T_red = importdata(strcat(red_path, red_files{i}),'\t',1);
        rad_red = T_red.data(:,1);
        red_int = T_red.data(:,2);
        
        scatter([-rad_blue; rad_blue], [blue_int;blue_int], 50,'blue')
        hold on
        scatter([-rad_red; rad_red], [red_int;red_int], 50,'red')
        hold off
        
        col_prompt = 'Red or blue [1/2]: ';
        col = input(col_prompt);
        while isempty(col)
            col = input(col_prompt);
        end
        
        if col == 1
            rad{i} = rad_red;
            int{i} = red_int;
            col_choice{i} = {selected(i), 'red'};
            
        elseif col == 2
            rad{i} = rad_blue;
            int{i} = blue_int;
            col_choice{i} = {selected(i), 'blue'};
        end
        
    end
close all
end

%--------------------------------------------------------------------------
% Data import finished
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Find useful metrics for plotting
%--------------------------------------------------------------------------

Hcent = zeros(length(selected),1);
Hmin = zeros(length(selected),1);
Hmin_I = zeros(length(selected),1);
Rrim = zeros(length(selected),1);

for i = 1:length(selected)
   
    Hcent(i) = int{i}(2);
    [Hmin(i), Hmin_I(i)] = nanmin(int{i});
    Rrim(i) = rad{i}(Hmin_I(i));
    
end

if exist('T','var')
    timeStamps = T.cumulStamps(selected);
else
    timeStamps = selected;
end
%--------------------------------------------------------------------------
% Make figures
%--------------------------------------------------------------------------

figure(1);
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

for i = 1:length(selected)    
% T_red = importdata(strcat(red_path, red_files{i}),'\t',1);
% rad_red = T_red.data(:,1);
% red_int = T_red.data(:,2);

% T_blue = importdata(strcat(blue_path, blue_files{i}),'\t',1);
% rad_blue = T_blue.data(:,1);
% blue_int = T_blue.data(:,2);
% 
% T_red = importdata(strcat(red_path, red_files{i}),'\t',1);
% rad_red = T_red.data(:,1);
% red_int = T_red.data(:,2);

str = pal{i};
color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
scatter([-rad{i}; rad{i}], [int{i};int{i}], 30, color,'filled')

% scatter(-rad_blue, blue_int, 50, color,'filled')

end

ax.YLim = [0, ax.YLim(2)];

legend(string(timeStamps), 'Box','off');
hold off

%--------------------------------------------------------------------------
x_title = 'Cumulative time / s ';

figure(2)
fig2 = gcf;
ax2 = gca;

fig2.Color = 'white';

% ax.Units = 'centimeters';
ax2.LineWidth = 1.5;
ax2.XColor = 'k';
ax2.YColor = 'k';
ax2.FontName = 'Helvetica';
ax2.FontSize = 18;
ax2.FontWeight = 'bold';
ax2.Box= 'off';
hold on

xlabel(x_title,'FontWeight','bold');
ylabel('Height at center / nm','FontWeight','bold');

plot(timeStamps,Hcent,'-o','LineWidth', 1.5)

%--------------------------------------------------------------------------

figure(3)
fig3 = gcf;
ax3 = gca;

fig3.Color = 'white';

% ax.Units = 'centimeters';
ax3.LineWidth = 1.5;
ax3.XColor = 'k';
ax3.YColor = 'k';
ax3.FontName = 'Helvetica';
ax3.FontSize = 18;
ax3.FontWeight = 'bold';
ax3.Box= 'off';
hold on

xlabel(x_title,'FontWeight','bold');
ylabel('Minimum height / nm','FontWeight','bold');

plot(timeStamps,Hmin,'-o','LineWidth', 1.5)

%--------------------------------------------------------------------------

figure(4)
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
hold on

xlabel(x_title,'FontWeight','bold');
ylabel('Radius of dimple / \mum','FontWeight','bold');

plot(timeStamps,Rrim,'-o','LineWidth', 1.5)

%--------------------------------------------------------------------------

save_check_prompt = 'Would you like to save the workspace variables? [1]: ';
save_check = input(save_check_prompt);
while isempty(save_check)
    save_check = input(save_check_prompt);
end

if save_check == 1
% print('-f2', '-r300','-dpng', '.png');
split_name = split(csvFile, "_");
save(strcat(save_folder,split_name{1},"_", split_name{2},".mat"),...
    'blue_files','red_files','col_choice','csvFile','folder','int','rad',...
    'selected','T');
end









