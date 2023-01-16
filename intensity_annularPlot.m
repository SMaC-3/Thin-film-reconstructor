
azi_path = "/Volumes/T7/Thin films/MultiCam/Xgum/1000ppm_Xgum/1000ppm_Xgum_0p1mMKCl_0p2umF_run9/azimuthal-intensity/azimuthal-intensity-rad-70/red_1000ppm_Xgum_0p1mM_KCl-1-03040-AzimuthalInt-rad70.txt";
azi_data = importdata(azi_path,'\t',6);

azi_degrees = azi_data.data(:,1);
azi_dimension = azi_data.data(:,2);
azi_int = azi_data.data(:,3);

figure(2)
% plot(bins, binaverage)
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
%     ax.YLim = [0,200];
% ax.XLim = [0,360];

xlabel('Azimuthal angle (degrees)','FontWeight','bold');
ylabel('Intensity (A.U)','FontWeight','bold');

plot(azi_degrees, azi_int,'Color',[0,0,1],'LineWidth',1.5)

figure(3)
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
%     ax.YLim = [0,200];

xlabel('Azimuthal dimension (\mum)','FontWeight','bold');
ylabel('Intensity (A.U)','FontWeight','bold');

plot(azi_dimension, azi_int,'Color',[0,0,1],'LineWidth',1.5)
