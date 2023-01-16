% Code written by Joshua P. King, SMaCLab, Monash University, Australia
% Last updated: August, 2022

%   ________  ___      ___       __       ______   ___            __       _______   
%  /"       )|"  \    /"  |     /""\     /" _  "\ |"  |          /""\     |   _  "\  
% (:   \___/  \   \  //   |    /    \   (: ( \___)||  |         /    \    (. |_)  :) 
%  \___  \    /\\  \/.    |   /' /\  \   \/ \     |:  |        /' /\  \   |:     \/  
%   __/  \\  |: \.        |  //  __'  \  //  \ _   \  |___    //  __'  \  (|  _  \\  
%  /" \   :) |.  \    /:  | /   /  \\  \(:   _) \ ( \_|:  \  /   /  \\  \ |: |_)  :) 
% (_______/  |___|\__/|___|(___/    \___)\_______) \_______)(___/    \___)(_______/  
                                                                                   

% SMaCLab website can be found here:
% https://sites.google.com/view/smaclab

% -------------------------------------------------------------------------

function [I_min_pks, I_max_pks, min_pks, max_pks, cut, dimple_radius] =...
    intensity_maxMin(radial_data, int_data, key_pars)

% Find peaks
% minPeak = (nanmean(int_data) - nanmin(int_data))*0.1;
minPeak = (nanmean(int_data) - nanmin(int_data))*0.05;
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

    [dimple_radius, I_radius] =...
        get_dimple_radius(radial_data,int_data, I_min_pks, I_max_pks);

else

    cutoff_lb = key_pars(1);
    cutoff_ub = key_pars(2);

    dimple_radius = key_pars(3);

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

scatter(dimple_radius, int_data(I_radius),250,...
    'MarkerFaceColor', 'green','MarkerEdgeColor','green')
hold off

disp('1: Accept all parameters')
disp('2: Adjust lower bound for max/min')
disp('3: Adjust upper bound for max/min')
disp('4: Change selected dimple rim')
disp('5: Add stationary point')
disp('6: Remove stationary point')
disp('7: Remove stationary points within range')

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
        [dimple_radius, I_radius] =...
            get_dimple_radius(radial_data,int_data, I_min_pks, I_max_pks);
    elseif action_select == 5
        [I_min_pks, min_pks, I_max_pks, max_pks] =...
            add_stationary_point(radial_data, int_data, I_min_pks, I_max_pks);
    elseif action_select == 6
        [I_min_pks, min_pks, I_max_pks, max_pks] =...
            remove_stationary_point(radial_data, I_min_pks, min_pks, I_max_pks, max_pks);
    elseif action_select == 7
        [I_min_pks, min_pks, I_max_pks, max_pks] =...
            remove_stationary_point_range_index(radial_data, int_data, I_min_pks, min_pks, I_max_pks, max_pks);
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
    scatter(dimple_radius, int_data(I_radius),250,...
        'MarkerFaceColor', 'green','MarkerEdgeColor','green')
    hold off

    action_input = 'Please select an option: ';
    action_select = input(action_input);
    while isempty(action_select)
        action_select = input(action_input);
    end
end

% Perform upper and lower bound trim

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

end

function  [cutoff_lb] =...
    get_LB_SP_ID()

trim_lb = 'Enter lower bound for max/min peak identification: ';
cutoff_lb = input(trim_lb);
while isempty(cutoff_lb)
    cutoff_lb = input(trim_lb);
end


end

function  [cutoff_ub] =...
    get_UB_SP_ID()

trim = 'Enter upper bound for max/min peak identification: ';
cutoff_ub = input(trim);
while isempty(cutoff_ub)
    cutoff_ub = input(trim);
end

end

function  [dimple_radius, I_radius] =...
    get_dimple_radius(radial_data,int_data, I_min_pks, I_max_pks)

I_sp = sort([I_min_pks; I_max_pks]);

c = linspace(1,10,length(I_sp));

figure(3)
colormap lines
plot(radial_data, int_data, 'black', 'LineWidth', 2)
hold on
scatter(radial_data(I_sp), int_data(I_sp), 200, c, 'filled')
ax = gca;
cmap = colormap(ax,lines(length(I_sp)));
ax.YLim(2) = max(int_data)*1.1;

for k = 1:length(I_sp)
        text(radial_data(I_sp(k)), max(int_data)*1.01 + (0.01*max(int_data)*(sin(k))) ,num2str(k),...
            "Color",cmap(k,1:3))
end

hold off
disp([radial_data(I_sp).' ; 1:length(I_sp)])

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

end

function  [I_min_pks, min_pks, I_max_pks, max_pks] =...
    remove_stationary_point(radial_data, I_min_pks, min_pks, I_max_pks, max_pks)

I_sp = sort([I_min_pks; I_max_pks]);

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

end


function  [I_min_pks, min_pks, I_max_pks, max_pks] =...
    remove_stationary_point_range(radial_data, I_min_pks, min_pks, I_max_pks, max_pks)

    lower_ID_prompt = 'please select lower bound pixel value for SP removal: ';
    lower_ID = input(lower_ID_prompt);
    while isempty(lower_ID)
        lower_ID = input(lower_ID_prompt);
    end

    upper_ID_prompt = 'please select upper bound pixel value for SP removal: ';
    upper_ID = input(upper_ID_prompt);
    while isempty(upper_ID)
        upper_ID = input(upper_ID_prompt);
    end
    
while length(lower_ID) ~= length(upper_ID)
    disp('Length mismatch between lower and upper bounds')
    
    lower_ID_prompt = 'please select lower bound pixel value for SP removal: ';
    lower_ID = input(lower_ID_prompt);
    while isempty(lower_ID)
        lower_ID = input(lower_ID_prompt);
    end

    upper_ID_prompt = 'please select upper bound pixel value for SP removal: ';
    upper_ID = input(upper_ID_prompt);
    while isempty(upper_ID)
        upper_ID = input(upper_ID_prompt);
    end
end


for i = 1:length(upper_ID)
    rad_max = radial_data(I_max_pks);
    rad_min = radial_data(I_min_pks);

    log_max = rad_max > lower_ID(i) & rad_max < upper_ID(i);
    log_min = rad_min > lower_ID(i) & rad_min < upper_ID(i);

    I_max_pks(log_max) = [];
    max_pks(log_max) = [];
    I_min_pks(log_min) = [];
    min_pks(log_min) = [];
end

end

function  [I_min_pks, min_pks, I_max_pks, max_pks] =...
    remove_stationary_point_range_index(radial_data, int_data, I_min_pks, min_pks, I_max_pks, max_pks)

I_sp = sort([I_min_pks; I_max_pks]);

c = linspace(1,10,length(I_sp));

figure(3)
colormap lines
plot(radial_data, int_data, 'black', 'LineWidth', 2)
hold on
scatter(radial_data(I_sp), int_data(I_sp), 200, c, 'filled')
ax = gca;
cmap = colormap(ax,lines(length(I_sp)));
ax.YLim(2) = max(int_data)*1.1;

for k = 1:length(I_sp)
        text(radial_data(I_sp(k)), max(int_data)*1.01 + (0.01*max(int_data)*(sin(k))) ,num2str(k),...
            "Color",cmap(k,1:3))
end

hold off
disp([radial_data(I_sp).' ; 1:length(I_sp)])



    lower_ID_prompt = 'please select lower bound index value for SP removal: ';
    lower_ID = input(lower_ID_prompt);
    while isempty(lower_ID)
        lower_ID = input(lower_ID_prompt);
    end

    upper_ID_prompt = 'please select upper bound index value for SP removal: ';
    upper_ID = input(upper_ID_prompt);
    while isempty(upper_ID)
        upper_ID = input(upper_ID_prompt);
    end
    
while length(lower_ID) ~= length(upper_ID)
    disp('Length mismatch between lower and upper bounds')

    lower_ID = input(lower_ID_prompt);
    while isempty(lower_ID)
        lower_ID = input(lower_ID_prompt);
    end

    upper_ID = input(upper_ID_prompt);
    while isempty(upper_ID)
        upper_ID = input(upper_ID_prompt);
    end
end

for i = 1:length(upper_ID)
    rad_max = radial_data(I_max_pks);
    rad_min = radial_data(I_min_pks);
    lower_rad = radial_data(I_sp(lower_ID(i)));
    upper_rad = radial_data(I_sp(upper_ID(i)));

    log_max = rad_max >= lower_rad & rad_max <= upper_rad;
    log_min = rad_min >= lower_rad & rad_min <= upper_rad;

    I_max_pks(log_max) = [];
    max_pks(log_max) = [];
    I_min_pks(log_min) = [];
    min_pks(log_min) = [];
end

end

