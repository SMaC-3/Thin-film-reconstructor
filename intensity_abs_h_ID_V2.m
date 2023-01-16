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

%--------------------------------------------------------------

function [radius, dimp_h_red, dimp_h_blue, save_abs_h] =...
    intensity_abs_h_ID_V2(T_data, phi_correction, pre_T_dimp)

%--------------------------------------------------------------
% Define intensity profile & peak info for red and blue
%--------------------------------------------------------------

radius = T_data.radius;

red_norm = T_data.red_norm;
red_ind = find(T_data.red_I_max_min ~=0);
red_max_min = T_data.red_I_max_min(red_ind);
red_max_min(red_max_min == -1) = 0;
red_dimp = find(red_ind == find(T_data.red_I_dimp == 1));

blue_norm = T_data.blue_norm;
blue_ind = find(T_data.blue_I_max_min ~=0);
blue_max_min = T_data.blue_I_max_min(blue_ind);
blue_max_min(blue_max_min == -1) = 0;
blue_dimp = find(blue_ind == find(T_data.blue_I_dimp == 1));

%--------------------------------------------------------------
% Define required physical parameters
%--------------------------------------------------------------

lamb_red = 630;     % Wavelength of red light in nm
lamb_blue = 450;    % Wavelength of blue light in nm

% n1 is the refractive index of film medium
n1 = 1.33;          % refractive index of water 
% n1 = 1.43;        % refractive index of glycol
% n1 = 1;           % refractive index of air

%--------------------------------------------------------------
% Plot normalised red and blue intensity data and determine cosine branch
%--------------------------------------------------------------

factor_red = (4*pi*n1)/lamb_red;
factor_blue = (4*pi*n1)/lamb_blue;

figure(5)
plot(radius, blue_norm, 'blue', 'LineWidth', 2)
hold on
scatter(radius(blue_ind), blue_norm(blue_ind), 200, 'black', 'filled')
scatter(radius(blue_ind(blue_dimp)), blue_norm(blue_ind(blue_dimp)), 200, 'magenta', 'filled')

for k = 1:length(blue_ind)

    text(radius(blue_ind(k)), blue_norm(blue_ind(k))-0.05,num2str(k),'Color', 'blue')

end

plot(radius, red_norm, 'red', 'LineWidth', 2)
scatter(radius(red_ind), red_norm(red_ind), 200, 'black', 'filled')
scatter(radius(red_ind(red_dimp)), red_norm(red_ind(red_dimp)), 200, 'magenta', 'filled')

for k = 1:length(red_ind)

    text(radius(red_ind(k)), red_norm(red_ind(k))-0.1,num2str(k),'Color', 'red')

end
hold off
default_branch = 0;

if default_branch ~=1
    blue_dimp_branch_prompt = 'Identify the branch that contains the dimple rim region in blue channel: ';
    red_dimp_branch_prompt = 'Identify the branch that contains the dimple rim region in red channel: ';

    blue_dimp_branch = input(blue_dimp_branch_prompt);
    while isempty(blue_dimp_branch)
        blue_dimp_branch = input(blue_dimp_branch_prompt);
    end

    red_dimp_branch = input(red_dimp_branch_prompt);
    while isempty(red_dimp_branch)
        red_dimp_branch = input(red_dimp_branch_prompt);
    end

else
    red_dimp_branch = 1;
    blue_dimp_branch = 1;
end

%--------------------------------------------------------------
% Inverse normalised intensity 
%--------------------------------------------------------------

red_branches = zeros(length(red_ind),1);
blue_branches = zeros(length(blue_ind),1);

if red_dimp == 1
    red_branch_add = 0;

else
    red_branch_add = zeros(1,red_dimp-1);
    red_sp_steps = abs(diff(red_max_min(1:red_dimp))).';
    red_steps_zero_I = find(red_sp_steps == 0); % find where zeros are

    if isempty(red_steps_zero_I) ~= 1

        red_steps_zero_direction = ones(1,length(red_steps_zero_I))*-1;

        if length(red_steps_zero_direction) ~= 1

            if rem(length(red_steps_zero_direction),2) == 0 % if even make odd index -1, vice versa
                red_steps_zero_direction(1:2:end) = 1;
            else
                red_steps_zero_direction(2:2:end) = 1;
            end

        end
        red_steps_zero_add = zeros(1,length(red_sp_steps));
        for i=1:length(red_steps_zero_I)
            red_steps_zero_add(red_steps_zero_I(i)) =  red_steps_zero_direction(i);
        end

    else
        red_steps_zero_add = zeros(1,length(red_sp_steps));
    end

    for i = 1:red_dimp-1
        j = red_dimp - i;
        red_branch_add(j) =  sum(red_sp_steps(j:end))+sum(red_steps_zero_add(j:end));
    end
end


red_branches(1:red_dimp-1) = red_branches(1:red_dimp-1)+...
    red_branch_add.' + red_dimp_branch;
red_branches(red_dimp) = red_dimp_branch;
red_branches(red_dimp+1:end) = red_dimp_branch:...
    red_dimp_branch+length(red_branches)-red_dimp-1;


if blue_dimp == 1
    blue_branch_add = 0;

else
    blue_branch_add = zeros(1,blue_dimp-1);
    blue_sp_steps = abs(diff(blue_max_min(1:blue_dimp))).';
    blue_steps_zero_I = find(blue_sp_steps == 0); % find where zeros are

    if isempty(blue_steps_zero_I) ~= 1

        blue_steps_zero_direction = ones(1,length(blue_steps_zero_I))*-1;

        if length(blue_steps_zero_direction) ~= 1

            if rem(length(blue_steps_zero_direction),2) == 0 % if even make odd index -1, vice versa
                blue_steps_zero_direction(1:2:end) = 1;
            else
                blue_steps_zero_direction(2:2:end) = 1;
            end

        end
        blue_steps_zero_add = zeros(1,length(blue_sp_steps));
        for i=1:length(blue_steps_zero_I)
            blue_steps_zero_add(blue_steps_zero_I(i)) =  blue_steps_zero_direction(i);
        end

    else
        blue_steps_zero_add = zeros(1,length(blue_sp_steps));
    end

    for i = 1:blue_dimp-1
        j = blue_dimp - i;
        blue_branch_add(j) =  sum(blue_sp_steps(j:end))+sum(blue_steps_zero_add(j:end));
    end
end


blue_branches(1:blue_dimp-1) = blue_branches(1:blue_dimp-1) +...
    blue_branch_add.'+  blue_dimp_branch;
blue_branches(blue_dimp) = blue_dimp_branch;
blue_branches(blue_dimp+1:end) = blue_dimp_branch:...
    blue_dimp_branch+length(blue_branches)-blue_dimp-1;

red_inv_cos = acos(red_norm);
blue_inv_cos = acos(blue_norm);

%--------------------------------------------------------------
% Correct branches 
%--------------------------------------------------------------

if phi_correction == 0 % No phase shift due to reflections

for i=0:length(red_ind)-1

    if i == 0
        if rem(red_branches(1),2) == 0
            red_inv_cos(1:red_ind(1)) =...
                red_branches(1)*pi - red_inv_cos(1:red_ind(1));
        else
            red_inv_cos(1:red_ind(1)) =...
                (red_branches(1)-1)*pi + red_inv_cos(1:red_ind(1));
        end

    else

         if rem(red_branches(i+1),2) == 0
            red_inv_cos(red_ind(i)+1:red_ind(i+1)) =...
                red_branches(i+1)*pi - red_inv_cos(red_ind(i)+1:red_ind(i+1));
        else
            red_inv_cos(red_ind(i)+1:red_ind(i+1)) =...
                (red_branches(i+1)-1)*pi + red_inv_cos(red_ind(i)+1:red_ind(i+1));
         end
    end
end

for i=0:length(blue_ind)-1

    if i == 0
        if rem(blue_branches(1),2) == 0
            blue_inv_cos(1:blue_ind(1)) =...
                blue_branches(1)*pi - blue_inv_cos(1:blue_ind(1));
        else
            blue_inv_cos(1:blue_ind(1)) =...
                (blue_branches(1)-1)*pi + blue_inv_cos(1:blue_ind(1));
        end

    else

         if rem(blue_branches(i+1),2) == 0
            blue_inv_cos(blue_ind(i)+1:blue_ind(i+1)) =...
                blue_branches(i+1)*pi - blue_inv_cos(blue_ind(i)+1:blue_ind(i+1));
        else
            blue_inv_cos(blue_ind(i)+1:blue_ind(i+1)) =...
                (blue_branches(i+1)-1)*pi + blue_inv_cos(blue_ind(i)+1:blue_ind(i+1));
         end
    end
end

elseif phi_correction == 1 % Phase shift of pi due to reflections

for i=0:length(red_ind)-1

    if i == 0
        if rem(red_branches(1),2) == 1
            red_inv_cos(1:red_ind(1)) =...
                red_branches(1)*pi - red_inv_cos(1:red_ind(1));
        else
            red_inv_cos(1:red_ind(1)) =...
                (red_branches(1)-1)*pi + red_inv_cos(1:red_ind(1));
        end

    else

         if rem(red_branches(i+1),2) == 1
            red_inv_cos(red_ind(i)+1:red_ind(i+1)) =...
                red_branches(i+1)*pi - red_inv_cos(red_ind(i)+1:red_ind(i+1));
        else
            red_inv_cos(red_ind(i)+1:red_ind(i+1)) =...
                (red_branches(i+1)-1)*pi + red_inv_cos(red_ind(i)+1:red_ind(i+1));
         end
    end
end

for i=0:length(blue_ind)-1

    if i == 0
        if rem(blue_branches(1),2) == 1
            blue_inv_cos(1:blue_ind(1)) =...
                blue_branches(1)*pi - blue_inv_cos(1:blue_ind(1));
        else
            blue_inv_cos(1:blue_ind(1)) =...
                (blue_branches(1)-1)*pi + blue_inv_cos(1:blue_ind(1));
        end

    else

         if rem(blue_branches(i+1),2) == 1
            blue_inv_cos(blue_ind(i)+1:blue_ind(i+1)) =...
                blue_branches(i+1)*pi - blue_inv_cos(blue_ind(i)+1:blue_ind(i+1));
        else
            blue_inv_cos(blue_ind(i)+1:blue_ind(i+1)) =...
                (blue_branches(i+1)-1)*pi + blue_inv_cos(blue_ind(i)+1:blue_ind(i+1));
         end
    end
end

else
    error("Phi correction not recognised")
end

%--------------------------------------------------------------
% Convert to absolute height, clean up and plot
%--------------------------------------------------------------

dimp_h_red = red_inv_cos./factor_red;

dimp_h_red(red_ind(end):end) = NaN;

figure(6)
scatter(radius, dimp_h_red, 'red', 'filled')
hold on
scatter(-radius, dimp_h_red, 'red', 'filled')


dimp_h_blue = blue_inv_cos./factor_blue;

dimp_h_blue(blue_ind(end):end) = NaN;

figure(7)
scatter(radius, dimp_h_blue, 'blue', 'filled')
hold on
scatter(-radius, dimp_h_blue, 'blue', 'filled')

figure(8)
scatter(radius, dimp_h_red, 'red', 'filled')
hold on
scatter(-radius, dimp_h_red, 'red', 'filled')
scatter(radius, dimp_h_blue, 'blue', 'filled')
scatter(-radius, dimp_h_blue, 'blue', 'filled')

save_abs_h = [lamb_red, lamb_blue, n1];
end
