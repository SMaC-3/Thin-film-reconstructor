function [I_min_pks, I_max_pks, min_pks, max_pks, cut, cut_grad, dimple_radius] =...
    intensity_maxMin(radial_data, int_data, key_pars)

% Find peaks
minPeak = (nanmean(int_data) - nanmin(int_data))*0.1;
[min_pks, I_min_pks] = findpeaks(-int_data,...
    'MinPeakProminence',minPeak);
min_pks = -min_pks;
[max_pks, I_max_pks] = findpeaks(int_data,...
    'MinPeakProminence',minPeak);

% Plot peaks
figure(2)
scatter(radial_data(I_min_pks), min_pks,200, 'magenta', 'filled')
hold on
scatter(radial_data(I_max_pks), max_pks,200, 'magenta', 'filled')
plot(radial_data, int_data, 'black', 'LineWidth', 2)
hold off

if isempty(key_pars) == 1
    % Get lower bound trim
    [cutoff_lb] = get_LB_SP_ID();
    % Get upper bound trim
    [cutoff_ub] = get_UB_SP_ID();
    
    [cutoff_grad_lb] = get_LB_grad_cor();
    [cutoff_grad_ub] = get_UB_grad_cor();
    [dimple_radius, I_radius] =...
        get_dimple_radius(radial_data,int_data, I_min_pks, I_max_pks);    

else
    
    cutoff_lb = key_pars(1);
    cutoff_ub = key_pars(2);
    cutoff_grad_lb = key_pars(3);
    cutoff_grad_ub = key_pars(4);
    dimple_radius = key_pars(5);
    
    [~, radius_dimp_I] = min(abs(radial_data - dimple_radius));
    [min_sub, min_sub_I] = min(abs(I_min_pks-radius_dimp_I));    
    [max_sub, max_sub_I] = min(abs(I_max_pks - radius_dimp_I));
    
    if min_sub < max_sub
        I_radius = I_min_pks(min_sub_I);
        dimple_radius = radial_data(I_radius);
    elseif max_sub < min_sub | max_sub == min_sub
        I_radius = I_max_pks(max_sub_I);
        dimple_radius = radial_data(I_radius);  
    end
end

% Plot peaks
figure(2)
scatter(radial_data(I_min_pks), min_pks,200, 'magenta', 'filled')
hold on
scatter(radial_data(I_max_pks), max_pks,200, 'magenta', 'filled')
plot(radial_data, int_data, 'black', 'LineWidth', 2)
plot([cutoff_lb, cutoff_lb],[min(int_data), max(int_data)], 'black',...
    'LineWidth', 1)
plot([cutoff_ub, cutoff_ub],[min(int_data), max(int_data)], 'black',...
    'LineWidth', 1)
plot([cutoff_grad_lb, cutoff_grad_lb],[min(int_data), max(int_data)], '--',...
    'Color','black',...
    'LineWidth', 1)
plot([cutoff_grad_ub, cutoff_grad_ub],[min(int_data), max(int_data)], '--',...
    'Color','black',...
    'LineWidth', 1)
scatter(dimple_radius, int_data(I_radius),250,...
    'MarkerFaceColor', 'green','MarkerEdgeColor','green')
hold off

disp('1: Accept all parameters')
disp('2: Adjust lower bound for max/min')
disp('3: Adjust upper bound for max/min')
disp('4: Adjust lower bound for gradient correction')
disp('5: Adjust upper bound for gradient correction')
disp('6: Change selected dimple rim')
disp('7: Add stationary point')
disp('8: Remove stationary point')

action_input = 'Please select an option: ';
action_select = input(action_input);
while isempty(action_select)
    action_select = input(action_input);
end

while action_select~=1
   
    if action_select == 2
        disp(strcat('Current lower bound trim: ', ' ',string(cutoff_lb)));
        [cutoff_lb] = get_LB_SP_ID();
    elseif action_select == 3
        disp(strcat('Current upper bound trim: ', ' ',string(cutoff_ub)));
        [cutoff_ub] = get_UB_SP_ID();
    elseif action_select == 4
        disp(strcat('Current lower bound for gradient correction: ', ' ',...
            string(cutoff_grad_lb)));
        [cutoff_grad_lb] = get_LB_grad_cor();
    elseif action_select == 5
        disp(strcat('Current upper bound for gradient correction: ',' ',...
            string(cutoff_grad_ub)));
        [cutoff_grad_ub] = get_UB_grad_cor();
    elseif action_select == 6
        [dimple_radius, I_radius] =...
            get_dimple_radius(radial_data,int_data, I_min_pks, I_max_pks);
    elseif action_select == 7
        [I_min_pks, min_pks, I_max_pks, max_pks] =...
            add_stationary_point(radial_data, int_data, I_min_pks, I_max_pks);
    elseif action_select == 8
        [I_min_pks, min_pks, I_max_pks, max_pks] =...
            remove_stationary_point(radial_data, I_min_pks, min_pks, I_max_pks, max_pks);
    else
        disp('Please enter a valid selection')
    end
    
    figure(2)
    scatter(radial_data(I_min_pks), min_pks,200, 'magenta', 'filled')
    hold on
    scatter(radial_data(I_max_pks), max_pks,200, 'magenta', 'filled')
    plot(radial_data, int_data, 'black', 'LineWidth', 2)
    plot([cutoff_lb, cutoff_lb],[min(int_data), max(int_data)], 'black',...
        'LineWidth', 1)
    plot([cutoff_ub, cutoff_ub],[min(int_data), max(int_data)], 'black',...
        'LineWidth', 1)
    plot([cutoff_grad_lb, cutoff_grad_lb],[min(int_data), max(int_data)], '--',...
        'Color','black',...
        'LineWidth', 1)
    plot([cutoff_grad_ub, cutoff_grad_ub],[min(int_data), max(int_data)], '--',...
        'Color','black',...
        'LineWidth', 1)
    scatter(dimple_radius, int_data(I_radius),250,...
        'MarkerFaceColor', 'green','MarkerEdgeColor','green')
    hold off
    
    action_input = 'Please select an option: ';
    action_select = input(action_input);
    while isempty(action_select)
        action_select = input(action_input);
    end
end

% Perfrom upper and lower bound trim

[~,I_cutoff] = min(abs(radial_data - cutoff_lb));

min_cut = I_min_pks>I_cutoff;
max_cut = I_max_pks>I_cutoff;

min_pks = min_pks(min_cut);
I_min_pks = I_min_pks(min_cut);

max_pks = max_pks(max_cut);
I_max_pks = I_max_pks(max_cut);

[~,I_cutoff_2] = min(abs(radial_data - cutoff_ub));

min_cut_2 = I_min_pks<I_cutoff_2;
max_cut_2 = I_max_pks<I_cutoff_2;

min_pks = min_pks(min_cut_2);
I_min_pks = I_min_pks(min_cut_2);

max_pks = max_pks(max_cut_2);
I_max_pks = I_max_pks(max_cut_2);

% Prepare input parameters for return

cut = [cutoff_lb, cutoff_ub];
cut_grad = [cutoff_grad_lb, cutoff_grad_ub];
end

function  [cutoff_lb] =...
    get_LB_SP_ID()

trim_lb = 'Enter lower bound for max/min peak identification: ';
cutoff_lb = input(trim_lb);
while isempty(cutoff_lb)
    cutoff_lb = input(trim_lb);
end

% % cutoff = 20;
% [~,I_cutoff] = min(abs(radial_data - cutoff_lb));
% 
% min_cut = I_min_pks>I_cutoff;
% max_cut = I_max_pks>I_cutoff;
% 
% min_pks = min_pks(min_cut);
% I_min_pks = I_min_pks(min_cut);
% 
% max_pks = max_pks(max_cut);
% I_max_pks = I_max_pks(max_cut);

end

function  [cutoff_ub] =...
    get_UB_SP_ID()

trim = 'Enter upper bound for max/min peak identification: ';
cutoff_ub = input(trim);
    while isempty(cutoff_ub)
        cutoff_ub = input(trim);
    end
% cutoff_2 = 195;
% 
% [~,I_cutoff_2] = min(abs(radial_data - cutoff_ub));
% 
% min_cut_2 = I_min_pks<I_cutoff_2;
% max_cut_2 = I_max_pks<I_cutoff_2;
% 
% min_pks = min_pks(min_cut_2);
% I_min_pks = I_min_pks(min_cut_2);
% 
% max_pks = max_pks(max_cut_2);
% I_max_pks = I_max_pks(max_cut_2);

end

function  [cutoff_grad_lb] =...
    get_LB_grad_cor()

trim_lb = 'Enter lower bound for gradient correction: ';
cutoff_grad_lb = input(trim_lb);
while isempty(cutoff_grad_lb)
    cutoff_grad_lb = input(trim_lb);
end

end

function  [cutoff_grad_ub] =...
    get_UB_grad_cor()

trim = 'Enter upper bound for gradient correction: ';
cutoff_grad_ub = input(trim);
    while isempty(cutoff_grad_ub)
        cutoff_grad_ub = input(trim);
    end

end

function  [dimple_radius, I_radius] =...
    get_dimple_radius(radial_data,int_data, I_min_pks, I_max_pks)
I_sp = sort([I_min_pks; I_max_pks]);
% sp = int_data(I_sp);

figure(3)
plot(radial_data, int_data, 'black', 'LineWidth', 2)
hold on
scatter(radial_data(I_sp), int_data(I_sp), 200, 'black', 'filled')

for k = 1:length(I_sp)
    text(radial_data(I_sp(k)), mean(int_data) ,num2str(k))   
end

hold off
disp([radial_data(I_sp).' ; 1:length(I_sp)])
dimp_prompt = 'Identify index of dimple: ';
I_dimp = input(dimp_prompt);
while isempty(I_dimp)
    I_dimp = input(dimp_prompt);
end

I_radius = I_sp(I_dimp);
dimple_radius = radial_data(I_sp(I_dimp));

end

function  [I_min_pks, min_pks, I_max_pks, max_pks] =...
    add_stationary_point(radial_data, int_data, I_min_pks, I_max_pks)

man_ID_prompt = 'please select pixel value for SP: ';
man_ID = input(man_ID_prompt);
while isempty(man_ID)
    man_ID = input(man_ID_prompt);
end
[~, mvI] = min(abs(radial_data - man_ID));

man_ID_prompt_2 = 'Is this a max or min [enter 1 or 0]: ';
man_ID_2 = input(man_ID_prompt_2);
while isempty(man_ID_2)
    man_ID_2 = input(man_ID_prompt_2);
end


if man_ID_2 == 1
    I_max_pks = [I_max_pks;mvI];
elseif man_ID_2 == 0
    I_min_pks = [I_min_pks;mvI];
end

min_pks = int_data(I_min_pks);
max_pks = int_data(I_max_pks);

% I_sp = [I_sp; mvI];
% [I_sp, I_sp_sorted] = sort(I_sp);
% 
% sp = [sp; int_data(mvI)];
% sp = sp(I_sp_sorted);

end

function  [I_min_pks, min_pks, I_max_pks, max_pks] =...
    remove_stationary_point(radial_data, I_min_pks, min_pks, I_max_pks, max_pks)

I_sp = sort([I_min_pks; I_max_pks]);
% sp = int_data(I_sp);

man_ID_prompt = 'please select pixel value for SP: ';
man_ID = input(man_ID_prompt);
while isempty(man_ID)
    man_ID = input(man_ID_prompt);
end

[~, mvI] = min(abs(radial_data - man_ID));
[~,find_I] = min(abs(I_sp-mvI));

is_max = ismember(I_max_pks, I_sp(find_I));
I_max_pks(is_max) = [];
max_pks(is_max) = [];
is_min = ismember(I_min_pks, I_sp(find_I));
I_min_pks(is_min) = [];
min_pks(is_min) = [];

% I_sp(find_I) = [];
% sp(find_I) = [];

end