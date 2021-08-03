function film_plot(T_film_metrics,T_film_plot)
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

legend(string(round(T_film_metrics.timeStamp,1)), 'Box','off');
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


end