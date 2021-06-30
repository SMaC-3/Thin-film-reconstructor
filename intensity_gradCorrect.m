function [P] = intensity_gradCorrect(pixels, int_data)
minPeak = (nanmean(int_data) - nanmin(int_data))*0.05;
[min_pks, I_min_pks] = findpeaks(-int_data,...
    'MinPeakProminence',minPeak);
min_pks = -min_pks;
[max_pks, I_max_pks] = findpeaks(int_data,...
    'MinPeakProminence',minPeak);


figure(2)
scatter(pixels(I_min_pks), min_pks,200, 'magenta', 'filled')
hold on
scatter(pixels(I_max_pks), max_pks,200, 'magenta', 'filled')
plot(pixels, int_data, 'black', 'LineWidth', 2)
hold off

trim_1 = 'Enter lower bound for peak identification for gradient correction: ';
cutoff = input(trim_1);
    while isempty(cutoff)
        cutoff = input(trim_1);
    end

% cutoff = 20;
[~,I_cutoff] = min(abs(pixels - cutoff));

min_cut = I_min_pks>I_cutoff;
max_cut = I_max_pks>I_cutoff;

min_pks = min_pks(min_cut);
I_min_pks = I_min_pks(min_cut);

max_pks = max_pks(max_cut);
I_max_pks = I_max_pks(max_cut);

%Trim upper max/min

trim = 'Enter upper bound for peak identification for gradient correction: ';
cutoff_2 = input(trim);
    while isempty(cutoff_2)
        cutoff_2 = input(trim);
    end
% cutoff_2 = 195;

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

P = polyfit(pixels(I_max_pks), max_pks,1);

end