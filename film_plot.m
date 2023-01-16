function film_plot(T_film_metrics,T_film_plot,T_film_shear)
numFilms = size(T_film_plot,2)-1;
 
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

for i = 1:numFilms    
str = pal{i};
color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
scatter([-T_film_plot.radius; T_film_plot.radius], [T_film_plot{:,i+1};T_film_plot{:,i+1}], 30, color,'filled')

% scatter(-rad_blue, blue_int, 50, color,'filled')

end

ax.YLim = [0, ax.YLim(2)];
leg_string = strcat(string(round(T_film_metrics.timeStamp,0)), repmat(" s", [max(size(T_film_metrics.timeStamp)),1]));
legend(leg_string, 'Box','off');
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

plot(T_film_metrics.timeStamp,T_film_metrics.Hcent_nm,'-o','LineWidth', 1.5,...
    'Color','blue','MarkerFaceColor','blue', 'MarkerSize',10)

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

plot(T_film_metrics.timeStamp,T_film_metrics.Hmin_nm,'-o','LineWidth', 1.5,...
    'Color','blue','MarkerFaceColor','blue', 'MarkerSize',10)

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

plot(T_film_metrics.timeStamp,T_film_metrics.Rrim_micron,'-o','LineWidth', 1.5,...
    'Color','blue','MarkerFaceColor','blue', 'MarkerSize',10)
%--------------------------------------------------------------------------

figure(5);
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


xlabel('Lateral dimension (\mum)','FontWeight','bold');
ylabel('Shear rate (1/s)','FontWeight','bold');


% Colour blind palette
pal = {'#000000','#004949','#009292','#ff6db6','#ffb6db','#490092',...
    '#006ddb','#b66dff','#6db6ff','#b6dbff','#920000',...
    '#924900','#db6d00','#24ff24','#ffff6d'};

for i = 1:numFilms-1
    str = pal{i};
    color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
    plot([T_film_shear.radius_bar], [T_film_shear{:,i+1}], 'Color',color,...
        'LineWidth',1.5)
    
    % scatter(-rad_blue, blue_int, 50, color,'filled')
    
end

%--------------------------------------------------------------------------
Exist_Column = strcmp('dimpVol_rim',T_film_metrics.Properties.VariableNames);
val = Exist_Column(Exist_Column==1) ;

if val ==1
    x_title = 'Cumulative time / s ';
    
    figure(6)
    fig6 = gcf;
    ax6 = gca;
    
    fig6.Color = 'white';
    
    % ax.Units = 'centimeters';
    ax6.LineWidth = 1.5;
    ax6.XColor = 'k';
    ax6.YColor = 'k';
    ax6.FontName = 'Helvetica';
    ax6.FontSize = 18;
    ax6.FontWeight = 'bold';
    ax6.Box= 'off';
    hold on
    
    xlabel(x_title,'FontWeight','bold');
    ylabel('Dimple volume (\mum^3)','FontWeight','bold');
    
    plot(T_film_metrics.timeStamp,T_film_metrics.dimpVol_rim,'-o','LineWidth', 1.5,...
        'Color','blue','MarkerFaceColor','blue', 'MarkerSize',10)
    
    plot(T_film_metrics.timeStamp,T_film_metrics.dimpVol_Hmin,'-o','LineWidth', 1.5,...
        'Color','cyan','MarkerFaceColor','cyan', 'MarkerSize',10)
    L = legend();
    L.String = {'dimple volume @ rim','dimple volume @ minimum height'};
end

end