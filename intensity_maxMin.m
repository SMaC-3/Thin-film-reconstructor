function [ind_sort,  sp_sorted] = intensity_maxMin(pixels, int_data)
minPeak = (nanmean(int_data) - nanmin(int_data))*0.5;
[min_pks, I_min_pks] = findpeaks(-int_data, 'MinPeakProminence',minPeak,'MinPeakDistance',10);
min_pks = -min_pks;
[max_pks, I_max_pks] = findpeaks(int_data, 'MinPeakProminence',minPeak,'MinPeakDistance',10);

figure(3)
hold on
scatter(pixels(I_min_pks), min_pks,200, 'red', 'filled')
scatter(pixels(I_max_pks), max_pks,200, 'black', 'filled')
hold off

I_merge = [I_min_pks; I_max_pks];
sp_merge = [min_pks; max_pks]; %stationary points

[ind_sort, I_merge_sorted] = sort(I_merge);
sp_sorted = sp_merge(I_merge_sorted);
end