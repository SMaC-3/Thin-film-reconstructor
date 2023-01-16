function plot_metrics(T_metrics, label)
figure(1)
timeStamps = T_metrics.("Time_stamps_(s)");
rim_h = T_metrics.("Rim_h_(nm)");
center_h = T_metrics.("Center_h_(nm)");
dimp_vol = T_metrics.("Dimple_vol_(micron^3)");

% yyaxis left
scatter(timeStamps,center_h,'filled')
hold on
% scatter(timeStamps,rim_h,'filled')
% yyaxis right
% scatter(timeStamps,dimp_vol,'filled')

lg = legend;
lg.String = label;
% lg.String = {"Center h", "Rim h", "Dimple volume"};
lg.Box = 'off';
end