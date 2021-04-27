function [ind_sort,  sp_sorted, max_min, save_maxMin] = intensity_maxMin(pixels, int_data)
minPeak = (nanmean(int_data) - nanmin(int_data))*0.05;
[min_pks, I_min_pks] = findpeaks(-int_data,...
    'MinPeakProminence',minPeak);
min_pks = -min_pks;
[max_pks, I_max_pks] = findpeaks(int_data,...
    'MinPeakProminence',minPeak);

cutoff = 15;
[~,I_cutoff] = min(abs(pixels - cutoff));

min_cut = I_min_pks>I_cutoff;
max_cut = I_max_pks>I_cutoff;

min_pks = min_pks(min_cut);
I_min_pks = I_min_pks(min_cut);

max_pks = max_pks(max_cut);
I_max_pks = I_max_pks(max_cut);

figure(2)
scatter(pixels(I_min_pks), min_pks,200, 'magenta', 'filled')
hold on
scatter(pixels(I_max_pks), max_pks,200, 'magenta', 'filled')
plot(pixels, int_data, 'black', 'LineWidth', 2)
hold off

%Trim upper max/min

trim = 'Enter upper bound for max/min peak identification: ';
% cutoff_2 = input(trim);
cutoff_2 = 230;

[~,I_cutoff_2] = min(abs(pixels - cutoff_2));

min_cut_2 = I_min_pks<I_cutoff_2;
max_cut_2 = I_max_pks<I_cutoff_2;

min_pks = min_pks(min_cut_2);
I_min_pks = I_min_pks(min_cut_2);

max_pks = max_pks(max_cut_2);
I_max_pks = I_max_pks(max_cut_2);

%End trim

max_min_merge = [zeros(length(I_min_pks),1);...
    ones(length(I_max_pks),1)];
    
I_merge = [I_min_pks; I_max_pks];
sp_merge = [min_pks; max_pks]; %stationary points

[ind_sort, I_merge_sorted] = sort(I_merge);
sp_sorted = sp_merge(I_merge_sorted);
max_min = max_min_merge(I_merge_sorted);
save_maxMin = [minPeak, cutoff, cutoff_2];
end