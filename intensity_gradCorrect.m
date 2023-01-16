function [P,y,int_cor] = intensity_gradCorrect(radial_data, int_data, I_min, I_max, lb, ub)

min_pks = int_data(I_min);
max_pks = int_data(I_max);

figure(2)
scatter(radial_data(I_min), min_pks,200, 'magenta', 'filled')
hold on
scatter(radial_data(I_max), max_pks,200, 'magenta', 'filled')
plot(radial_data, int_data, 'black', 'LineWidth', 2)
hold off

%     trim_1 = 'Enter 0 to enter gradient correction manually or 1 to correct automatically: ';
%     cutoff = input(trim_1);
%     while isempty(cutoff)
%         cutoff = input(trim_1);
%     end
cutoff = 1;    
    
if cutoff == 0
        
        light_m = input('Please enter value for gradient: ');
        while isempty(light_m)
            light_m = input('Please enter value for gradient: ');
        end
        
        light_c = input('Please enter value for y-intercept: ');
        while isempty(light_c)
            light_c = input('Please enter value for y-intercept: ');
        end
        
        P = [light_m, light_c];
        
else
    
    % cutoff = 20;
    [~,I_cutoff] = min(abs(radial_data - lb));
    
    min_cut = I_min>I_cutoff;
    max_cut = I_max>I_cutoff;
    
    min_pks = min_pks(min_cut);
    I_min = I_min(min_cut);
    
    max_pks = max_pks(max_cut);
    I_max = I_max(max_cut);
    
    %Trim upper max/min
    
    [~,I_cutoff_2] = min(abs(radial_data - ub));
    
    min_cut_2 = I_min<I_cutoff_2;
    max_cut_2 = I_max<I_cutoff_2;
    
    min_pks = min_pks(min_cut_2);
    I_min = I_min(min_cut_2);
    
    max_pks = max_pks(max_cut_2);
    I_max = I_max(max_cut_2);
    
    P = polyfit(radial_data(I_max), max_pks,1);
end

y = polyval(P, radial_data);
int_cor = int_data./y;

end