function [radius, dimp_h_red, dimp_h_blue, save_abs_h] =...
    intensity_abs_h_ID(T_data)

%--------------------------------------------------------------------------
% Define intensity profile & peak info for red and blue
%--------------------------------------------------------------------------

radius = T_data.radius;

% red_int_raw = T_data.red_int_raw;
% red_int_cor = T_data.red_int_corrected;
red_norm = T_data.red_norm;
red_ind = find(T_data.red_I_max_min ~=0);
red_max_min = T_data.red_I_max_min(red_ind);
red_max_min(red_max_min == -1) = 0;
red_dimp = find(red_ind == find(T_data.red_I_dimp == 1));

% blue_int_raw = T_data.blue_int_raw;
% blue_int_cor = T_data.blue_int_corrected;
blue_norm = T_data.blue_norm;
blue_ind = find(T_data.blue_I_max_min ~=0);
blue_max_min = T_data.blue_I_max_min(blue_ind);
blue_max_min(blue_max_min == -1) = 0;
blue_dimp = find(blue_ind == find(T_data.blue_I_dimp == 1));

%--------------------------------------------------------------------------
% Define required physical parameters
%--------------------------------------------------------------------------

lamb_red = 630;
lamb_blue = 450;
% n1 = 1.33; % refractive index of water 
n1 = 1.43; % refractive index of glycol

disp(strcat("refractive index ",num2str(n1))  );
%--------------------------------------------------------------------------
% Find film thickness for red & blue at points of max/min intensity.
% Odd --> minima, even --> maxima
%--------------------------------------------------------------------------

numb = 100;

red_sp_h = round((0:numb-1).'*(lamb_red/(n1*4)),4);
blue_sp_h = round((0:numb-1).'*(lamb_blue/(n1*4)),4);

[blue_co_I, red_co_I] = ismember(blue_sp_h,red_sp_h);

red_co = red_co_I(blue_co_I);
blue_co = find(blue_co_I);

%--------------------------------------------------------------------------
% Find index of common minimum or maximum red & blue 
%--------------------------------------------------------------------------


figure(5)
plot(radius, blue_norm, 'blue', 'LineWidth', 2)
hold on
scatter(radius(blue_ind), blue_norm(blue_ind), 200, 'black', 'filled')

for k = 1:length(blue_ind)
    
    text(radius(blue_ind(k)), blue_norm(blue_ind(k))-0.05,num2str(k),'Color', 'blue')
    
end

plot(radius, red_norm, 'red', 'LineWidth', 2)
scatter(radius(red_ind), red_norm(red_ind), 200, 'black', 'filled')

for k = 1:length(red_ind)
    
    text(radius(red_ind(k)), red_norm(red_ind(k))-0.1,num2str(k),'Color', 'red')
    
end
hold off

prompt_absH_b = 'Identify index of common stationary point in blue channel: ';
prompt_absH_r = 'Identify index of common stationary point in red channel: ';
p_absH_b = input(prompt_absH_b);
while isempty(p_absH_b)
    p_absH_b = input(prompt_absH_b);
end
p_absH_r = input(prompt_absH_r);
while isempty(p_absH_r)
    p_absH_r = input(prompt_absH_r);
end

%--------------------------------------------------------------------------
% Count back from common sp to index one inside dimple to assign height
%--------------------------------------------------------------------------

check_sp = blue_dimp - p_absH_b +1;

if check_sp > blue_dimp
    check_sp = mod(check_sp,2);
end

if blue_max_min(blue_dimp-check_sp+1) == 0 %common min, counting backwards b/c reverse order
    check = 'Is this the 1st common min (~592 nm) or 2nd common min (~1776 nm)? 1/2 : ';
    min_check = input(check);
    
    while isempty(min_check)
        min_check = input(check);
    end
    
    % dimpSP_ = stationary point below the dimple rim
    
    if min_check == 1
        
        dimpSP_red = red_co(2) - (red_dimp - p_absH_r);
        dimpSP_blue = blue_co(2) - (blue_dimp - p_absH_b);
        
    elseif min_check == 2
        
        dimpSP_red = red_co(4) - (red_dimp - p_absH_r);
        dimpSP_blue = blue_co(4) - (blue_dimp - p_absH_b);
        
    else
        
        dimpSP_red = input('minimum check failed. Input index for red shift: ');
        dimpSP_blue = input('minimum check failed. Input index for blue shift: ');
        
    end
    
else
    
    check_2 = 'Is this the 1st common max (~1184 nm) or 2nd common max (~2368 nm)? 1/2 : ';
    max_check = input(check_2);
    
    while isempty(max_check)
        max_check = input(check_2);
    end
    
    if max_check == 1
        
        dimpSP_red =  red_co(3) - (red_dimp - p_absH_r);
        dimpSP_blue = blue_co(3) - (blue_dimp - p_absH_b);
        
    elseif max_check == 2
        
        dimpSP_red = red_co(5) - (red_dimp - p_absH_r);
        dimpSP_blue = blue_co(5) - (blue_dimp - p_absH_b);
        
    else
        
        dimpSP_red = input('max check failed. Input index for red shift: ');
        dimpSP_blue = input('max check failed. Input index for blue shift: ');
        
    end
    
end

%--------------------------------------------------------------------------
% Alternative 1 method: find common minimum between blue and red to
% calibrate abolsute height
%--------------------------------------------------------------------------

blue_sp_h_exp = blue_sp_h(dimpSP_blue:blue_dimp+dimpSP_blue-1); % Find heights in blue channel at all sp
blue_sp_h_exp_outer = blue_sp_h(dimpSP_blue:length(blue_ind)-blue_dimp+dimpSP_blue);

red_sp_h_exp = red_sp_h(dimpSP_red:red_dimp+dimpSP_red-1); % Find heights in red channel at all sp
red_sp_h_exp_outer = red_sp_h(dimpSP_red:length(red_ind)-red_dimp+dimpSP_red);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% red channel film reconstruction
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

dimp_h_red = zeros(length(radius),1); % Empty matrix for height inversion at each bin
% new_norm = (red_norm*2)-1; % cosine component of interferometry eq'n
factor = (4*pi*n1)/lamb_red; % convert argument to height
h_inv_red = acos(red_norm)./factor; % acos returns value b/w [0, pi]

%--------------------------------------------------------------------------
% From dimple rim inwards
%--------------------------------------------------------------------------
for i = 1:red_dimp-1
    if red_max_min(red_dimp-i+1) == 1 % Red maximum
       % dimple height from previous minimum to maximum = height@next min -
       % (factor - inverted height from previous minimum to maximum) 
       % This seems more complicated than necessary but it avoids ever
       % using the "stationary point" at the dimple rim because all
       % reconstruction is based on i+1
       
       
       dimp_h_red(red_ind(red_dimp-i):red_ind(red_dimp-i+1)) = red_sp_h_exp(i+1) -...
           (red_sp_h(2) -  h_inv_red(red_ind(red_dimp-i):red_ind(red_dimp-i+1)) );
       
   elseif red_max_min(red_dimp-i+1) == 0 % Red minimum
       % dimple height from previous maximum to minimum = height@max -
       % inverted height from previous maximum to minimum
       dimp_h_red(red_ind(red_dimp-i):red_ind(red_dimp-i+1)) = red_sp_h_exp(i+1) - ...
           h_inv_red(red_ind(red_dimp-i):red_ind(red_dimp-i+1));
    
   end
       
end

%--------------------------------------------------------------------------
% Dimple center 
%--------------------------------------------------------------------------

if red_max_min(1) == 1 
    
    dimp_h_red(1:red_ind(1)) = red_sp_h_exp(end) + h_inv_red(1:red_ind(1));
    
elseif red_max_min(1) == 0
    
    dimp_h_red(1:red_ind(1)) = red_sp_h_exp(end) + (red_sp_h(2) - h_inv_red(1:red_ind(1)));
end

%--------------------------------------------------------------------------
% From dimple rim outwards
%--------------------------------------------------------------------------

for i = 1:length(red_ind)-red_dimp
   if red_max_min(red_dimp+i-1) == 1
       
       dimp_h_red(red_ind(red_dimp+i-1):red_ind(red_dimp+i)) =...
           red_sp_h_exp_outer(i+1) - (red_sp_h(2) - h_inv_red(red_ind(red_dimp+i-1):red_ind(red_dimp+i)));
       
   elseif red_max_min(red_dimp+i-1) == 0
    
       dimp_h_red(red_ind(red_dimp+i-1):red_ind(red_dimp+i)) =...
           red_sp_h_exp_outer(i+1) - h_inv_red(red_ind(red_dimp+i-1):red_ind(red_dimp+i));
    
   end       
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% blue channel film reconstruction
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

dimp_h_blue = zeros(length(radius),1); % Empty matrix for height inversion at each bin
% new_norm = (blue_norm*2)-1; % cosine component of interferometry eq'n
factor = (4*pi*n1)/lamb_blue; % convert argument to height
h_inv_blue = acos(blue_norm)./factor; % acos returns value b/w [0, pi]

%--------------------------------------------------------------------------
% From dimple rim inwards
%--------------------------------------------------------------------------

for i = 1:blue_dimp-1
    if blue_max_min(blue_dimp-i+1) == 1 % blue maximum
       % dimple height from previous minimum to maximum = height@next min -
       % (factor - inverted height from previous minimum to maximum) 
       % This seems more complicated than necessary but it avoids ever
       % using the "stationary point" at the dimple rim because all
       % reconstruction is based on i+1
       
       
       dimp_h_blue(blue_ind(blue_dimp-i):blue_ind(blue_dimp-i+1)) = blue_sp_h_exp(i+1) -...
           (blue_sp_h(2) -  h_inv_blue(blue_ind(blue_dimp-i):blue_ind(blue_dimp-i+1)) );
       
   elseif blue_max_min(blue_dimp-i+1) == 0 % blue minimum
       % dimple height from previous maximum to minimum = height@max -
       % inverted height from previous maximum to minimum
       dimp_h_blue(blue_ind(blue_dimp-i):blue_ind(blue_dimp-i+1)) = blue_sp_h_exp(i+1) - ...
           h_inv_blue(blue_ind(blue_dimp-i):blue_ind(blue_dimp-i+1));
    
   end      
end

%--------------------------------------------------------------------------
% Dimple center
%--------------------------------------------------------------------------

if blue_max_min(1) == 1 
    
    dimp_h_blue(1:blue_ind(1)) = blue_sp_h_exp(end) + h_inv_blue(1:blue_ind(1));
    
elseif blue_max_min(1) == 0
    
    dimp_h_blue(1:blue_ind(1)) = blue_sp_h_exp(end) + (blue_sp_h(2) - h_inv_blue(1:blue_ind(1)));
end

%--------------------------------------------------------------------------
% From dimple rim outwards
%--------------------------------------------------------------------------

for i = 1:length(blue_ind)-blue_dimp
   if blue_max_min(blue_dimp+i-1) == 1
       
       dimp_h_blue(blue_ind(blue_dimp+i-1):blue_ind(blue_dimp+i)) =...
           blue_sp_h_exp_outer(i+1) - (blue_sp_h(2) - h_inv_blue(blue_ind(blue_dimp+i-1):blue_ind(blue_dimp+i)));
       
   elseif blue_max_min(blue_dimp+i-1) == 0
    
       dimp_h_blue(blue_ind(blue_dimp+i-1):blue_ind(blue_dimp+i)) =...
           blue_sp_h_exp_outer(i+1) - h_inv_blue(blue_ind(blue_dimp+i-1):blue_ind(blue_dimp+i));
    
   end
       
end

zap_red = find(dimp_h_red ==0);
dimp_h_red(zap_red) = NaN;

figure(6)
scatter(radius, dimp_h_red, 'red', 'filled')
hold on
scatter(-radius, dimp_h_red, 'red', 'filled')


zap_blue = find(dimp_h_blue ==0);
dimp_h_blue(zap_blue) = NaN;

figure(7)
scatter(radius, dimp_h_blue, 'blue', 'filled')
hold on
scatter(-radius, dimp_h_blue, 'blue', 'filled')

save_abs_h = [lamb_red, lamb_blue, n1];
end
