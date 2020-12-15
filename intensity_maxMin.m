function [ind_sort,  sp_sorted, save_maxMin] = intensity_maxMin(pixels, int_data)
minPeak = (nanmean(int_data) - nanmin(int_data))*0.05;
[min_pks, I_min_pks] = findpeaks(-int_data,...
    'MinPeakProminence',minPeak);
min_pks = -min_pks;
[max_pks, I_max_pks] = findpeaks(int_data,...
    'MinPeakProminence',minPeak);

cutoff = 15;

min_cut = I_min_pks>cutoff;
max_cut = I_max_pks>cutoff;

min_pks = min_pks(min_cut);
I_min_pks = I_min_pks(min_cut);

max_pks = max_pks(max_cut);
I_max_pks = I_max_pks(max_cut);

% figure(3)
% hold on
% scatter(pixels(I_min_pks), min_pks,200, 'red', 'filled')
% scatter(pixels(I_max_pks), max_pks,200, 'black', 'filled')
% hold off

I_merge = [I_min_pks; I_max_pks];
sp_merge = [min_pks; max_pks]; %stationary points

[ind_sort, I_merge_sorted] = sort(I_merge);
sp_sorted = sp_merge(I_merge_sorted);
save_maxMin = [minPeak, cutoff];
end