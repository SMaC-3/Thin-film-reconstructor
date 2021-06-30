function [dimp_h_red, dimp_h_blue, save_abs_h] = intensity_abs_h_ID(pixels, norm_int, ind_int, max_min, dimp_ind, dimp_out)

%--------------------------------------------------------------------------
% Define intensity profile & peak info for red and blue
%--------------------------------------------------------------------------

pix_red = pixels(:,1);
norm_red = norm_int(:,1);
ind_red = ind_int{1};
max_min_red = max_min{1};

dimp_red = dimp_ind(1)+1;
dimp_red_outer = dimp_out(1)-1;


red_dimp = dimp_red;


pix_blue = pixels(:,2);
norm_blue = norm_int(:,2);
ind_blue = ind_int{2};
max_min_blue = max_min{2};

dimp_blue = dimp_ind(2)+1;
dimp_blue_outer = dimp_out(2)-1;

%--------------------------------------------------------------------------
% Define required physical parameters
%--------------------------------------------------------------------------

lamb_red = 630;
lamb_blue = 450;
n1 = 1.33; % refractive index of water

%--------------------------------------------------------------------------
% Find film thickness for red & blue at points of max/min intensity.
% Odd --> minima, even --> maxima
%--------------------------------------------------------------------------

numb = 100;
% max_min = repmat([0,1],1,numb/2).';
% red_sp_h = (1:numb).'*(lamb_red/(n1*4));
% blue_sp_h = (1:numb).'*(lamb_blue/(n1*4));

max_min = repmat([1,0],1,numb/2).';
red_sp_h = (0:numb-1).'*(lamb_red/(n1*4));
blue_sp_h = (0:numb-1).'*(lamb_blue/(n1*4));

[blue_co_I, red_co_I] = ismember(blue_sp_h,red_sp_h);

red_co = red_co_I(blue_co_I);
blue_co = find(blue_co_I);


%--------------------------------------------------------------------------
% THEORY
% Find sequence of red-blue max/min with increasing film thickness
%--------------------------------------------------------------------------

red_sp_info = [red_sp_h, max_min, repmat(lamb_red,numb,1)];
blue_sp_info = [blue_sp_h, max_min, repmat(lamb_blue,numb,1)];

merged_sp_info = [red_sp_info; blue_sp_info];
[~, sort_I] = sort(merged_sp_info(:,1));
sorted_sp_info = merged_sp_info(sort_I,:); % Theoretical: [height, max or min, colour (wavelength)]

%--------------------------------------------------------------------------
% EXPERIMENT DATA
% Find indices up to 1st inner sp
% Find indices inside and outside dimple (two monotonic regions for height)
% then merge colour channels and sort based on indices to give a sorted
% series of red/blue maxima and minima. With this, we can compare to our
% theoretical sorted series of red/blue maxima and minima to find where the
% two match up and determine absolute height.
%--------------------------------------------------------------------------

ind_inner_red = ind_red(1:red_dimp);
ind_outer_red = ind_red(red_dimp:end);



ind_inner_blue = ind_blue(1:dimp_blue);
ind_outer_blue = ind_blue(dimp_blue_outer:end);

max_min_inner_red = max_min_red(1:red_dimp);
max_min_outer_red = max_min_red(red_dimp:end);

max_min_inner_blue = max_min_blue(1:dimp_blue);
max_min_outer_blue = max_min_blue(dimp_blue_outer:end);

red_sp_exp = [ind_inner_red, max_min_inner_red,...
    repmat(lamb_red,length(ind_inner_red),1)];

blue_sp_exp = [ind_inner_blue, max_min_inner_blue,...
    repmat(lamb_blue,length(ind_inner_blue),1)];


merge_sp_exp = [red_sp_exp; blue_sp_exp];
[~, sp_I] = sort(merge_sp_exp(:,1), 'descend');

sp_exp = merge_sp_exp(sp_I, :); % Matrix for comparison with theory

%--------------------------------------------------------------------------
% Alternative 1 method: find common minimum between blue and red to
% calibrate absolute height
%--------------------------------------------------------------------------

[~,red_I_d] = sort(red_sp_exp(:,1), 'descend');
red_sp_exp_d = red_sp_exp(red_I_d,:);

[~,blue_I_d] = sort(blue_sp_exp(:,1), 'descend');
blue_sp_exp_d = blue_sp_exp(blue_I_d,:);
        
    figure(5)
    plot(pix_blue, norm_blue, 'blue', 'LineWidth', 2)
    hold on
    scatter(pix_blue(ind_blue), norm_blue(ind_blue), 200, 'black', 'filled')
    
    for k = 1:length(ind_blue)
   
    text(pix_blue(ind_blue(k)), norm_blue(ind_blue(k))-0.05,num2str(k),'Color', 'blue')
    
    end
    
    plot(pix_red, norm_red, 'red', 'LineWidth', 2)
    scatter(pix_red(ind_red), norm_red(ind_red), 200, 'black', 'filled')
    
    for k = 1:length(ind_red)
   
    text(pix_red(ind_red(k)), norm_red(ind_red(k))-0.1,num2str(k),'Color', 'red')
    
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
  
    % Count back from common sp to index one inside dimple to assign height
    
    check_sp = dimp_blue - p_absH_b +1;
    
    if check_sp > size(blue_sp_exp_d,1)
        check_sp = mod(check_sp,2);
    end
    
        if blue_sp_exp_d(check_sp,2) == 0 %common min, counting backwards b/c reverse order
            check = 'Is this the 1st common min (~592 nm) or 2nd common min (~1776 nm)? 1/2 : ';
            min_check = input(check);
            
            while isempty(min_check) 
                min_check = input(check);
            end
            
            % dimpSP_ = stationary point below the dimple rim
            
            if min_check == 1
                
                dimpSP_red = red_co(2) - (dimp_red - p_absH_r); 
                dimpSP_blue = blue_co(2) - (dimp_blue - p_absH_b);
            
            elseif min_check == 2
                
                dimpSP_red = red_co(4) - (dimp_red - p_absH_r);
                dimpSP_blue = blue_co(4) - (dimp_blue - p_absH_b);
                
            else
                
                dimpSP_red = input('minimum check failed. Input index for red shift: ');
                dimpSP_blue = input('minimum check failed. Input index for blue shift: ')
                
            end

        else
            
            check_2 = 'Is this the 1st common max (~1184 nm) or 2nd common max (~2368 nm)? 1/2 : ';
            max_check = input(check_2);
            
            while isempty(max_check) 
                max_check = input(check_2);
            end
            
            if max_check == 1
                
                dimpSP_red =  red_co(3) - (dimp_red - p_absH_r);
                dimpSP_blue = blue_co(3) - (dimp_blue - p_absH_b);
            
            elseif max_check == 2
                
                dimpSP_red = red_co(5) - (dimp_red - p_absH_r);
                dimpSP_blue = blue_co(5) - (dimp_blue - p_absH_b);
                
            else
                
                dimpSP_red = input('max check failed. Input index for red shift: ');
                dimpSP_blue = input('max check failed. Input index for blue shift: ')
                
            end
                
        end

%--------------------------------------------------------------------------
% Alternative 1 method: find common minimum between blue and red to
% calibrate abolsute height
%--------------------------------------------------------------------------

blue_h = sp_exp(sp_exp(:,3)==450,:);
blue_h(:,4) = blue_sp_h(dimpSP_blue:size(blue_h,1)+dimpSP_blue-1); % Find heights in blue channel at all sp
red_h = sp_exp(sp_exp(:,3)==630,:);
red_h(:,4) = red_sp_h(dimpSP_red:size(red_h,1)+dimpSP_red-1); % Find heights in red channel at all sp

red_sp_exp_outer = [ind_outer_red, max_min_outer_red,...
    red_sp_h(dimpSP_red:length(ind_outer_red)+dimpSP_red-1)];


blue_sp_exp_outer = [ind_outer_blue, max_min_outer_blue,...
    blue_sp_h(dimpSP_blue:length(ind_outer_blue)+dimpSP_blue-1)];

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% red channel film reconstruction
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

dimp_h_red = zeros(length(pix_red),1); % Empty matrix for height inversion at each bin
new_norm = (norm_red*2)-1; % cosine component of interferometry eq'n
factor = (4*pi*n1)/lamb_red; % convert argument to height
h_inv_red = acos(new_norm)./factor; % acos returns value b/w [0, pi]

%--------------------------------------------------------------------------
% From dimple rim inwards
%--------------------------------------------------------------------------

for i = 1:size(red_h,1)-1
   if red_h(i,2) == 1 % Red maximum
       % dimple height from previous minimum to maximum = height@next min -
       % (factor - inverted height from previous minimum to maximum) 
       % This seems more complicated than necessary but it avoids ever
       % using the "stationary point" at the dimple rim because all
       % reconstruction is based on i+1
       
       
       dimp_h_red(red_h(i+1,1):red_h(i,1)) = red_h(i+1,4) -...
           (red_sp_h(2) -  h_inv_red(red_h(i+1,1):red_h(i,1)) );
       
   elseif red_h(i,2) == 0 % Red minimum
       % dimple height from previous maximum to minimum = height@max -
       % inverted height from previous maximum to minimum
       dimp_h_red(red_h(i+1,1):red_h(i,1)) = red_h(i+1,4) - ...
           h_inv_red(red_h(i+1,1):red_h(i,1));
    
   end
       
end

%--------------------------------------------------------------------------
% Dimple center 
%--------------------------------------------------------------------------

if red_h(end,2) == 1 
    
    dimp_h_red(1:red_h(end,1)) = red_h(end,4) + h_inv_red(1:red_h(end,1));
    
elseif red_h(end,2) == 0
    
    dimp_h_red(1:red_h(end,1)) = red_h(end,4) + (red_sp_h(2) - h_inv_red(1:red_h(end,1)));
end

%--------------------------------------------------------------------------
% From dimple rim outwards
%--------------------------------------------------------------------------

for i = 1:size(red_sp_exp_outer,1)-1
   if red_sp_exp_outer(i,2) == 1
       
       dimp_h_red(red_sp_exp_outer(i,1):red_sp_exp_outer(i+1,1)) =...
           red_sp_exp_outer(i+1,3) - (red_sp_h(2) - h_inv_red(red_sp_exp_outer(i,1):red_sp_exp_outer(i+1,1)) );
       
   elseif red_sp_exp_outer(i,2) == 0
    
       dimp_h_red(red_sp_exp_outer(i,1):red_sp_exp_outer(i+1,1)) =...
           red_sp_exp_outer(i+1,3) - h_inv_red(red_sp_exp_outer(i,1):red_sp_exp_outer(i+1,1));
    
   end
       
end
 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% blue channel film reconstruction
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

dimp_h_blue = zeros(length(pix_blue),1); % Empty matrix for height inversion at each bin
new_norm = (norm_blue*2)-1; % cosine component of interferometry eq'n
factor = (4*pi*n1)/lamb_blue; % convert argument to height
h_inv_blue = acos(new_norm)./factor; % acos returns value b/w [0, pi]

%--------------------------------------------------------------------------
% From dimple rim inwards
%--------------------------------------------------------------------------

for i = 1:size(blue_h,1)-1
   if blue_h(i,2) == 1
       
       dimp_h_blue(blue_h(i+1,1):blue_h(i,1)) = blue_h(i+1,4) - (blue_sp_h(2) - h_inv_blue(blue_h(i+1,1):blue_h(i,1)));
       
   elseif blue_h(i,2) == 0
    
       dimp_h_blue(blue_h(i+1,1):blue_h(i,1)) = blue_h(i+1,4) - h_inv_blue(blue_h(i+1,1):blue_h(i,1));
    
   end
end

%--------------------------------------------------------------------------
% Dimple center
%--------------------------------------------------------------------------

if blue_h(end,2) == 1
    
    dimp_h_blue(1:blue_h(end,1)) = blue_h(end,4) + h_inv_blue(1:blue_h(end,1));
    
    
elseif blue_h(end,2) == 0
    
    dimp_h_blue(1:blue_h(end,1)) = blue_h(end,4) + (blue_sp_h(2) - h_inv_blue(1:blue_h(end,1)));
end

%--------------------------------------------------------------------------
% From dimple rim outwards
%--------------------------------------------------------------------------

for i = 1:size(blue_sp_exp_outer,1)-1
   if blue_sp_exp_outer(i,2) == 1
       
       dimp_h_blue(blue_sp_exp_outer(i,1):blue_sp_exp_outer(i+1,1)) =...
           blue_sp_exp_outer(i+1,3) - (blue_sp_h(2) -  h_inv_blue(blue_sp_exp_outer(i,1):blue_sp_exp_outer(i+1,1)));
       
   elseif blue_sp_exp_outer(i,2) == 0
    
       dimp_h_blue(blue_sp_exp_outer(i,1):blue_sp_exp_outer(i+1,1)) =...
           blue_sp_exp_outer(i+1,3) - h_inv_blue(blue_sp_exp_outer(i,1):blue_sp_exp_outer(i+1,1));
    
   end
       
end

zap_red = find(dimp_h_red ==0);
dimp_h_red(zap_red) = NaN;

figure(6)
scatter(pix_red, dimp_h_red, 'red', 'filled')
hold on
scatter(-pix_red, dimp_h_red, 'red', 'filled')


zap_blue = find(dimp_h_blue ==0);
dimp_h_blue(zap_blue) = NaN;

figure(7)
scatter(pix_blue, dimp_h_blue, 'blue', 'filled')
hold on
scatter(-pix_blue, dimp_h_blue, 'blue', 'filled')

save_abs_h = [lamb_red, lamb_blue, n1, length(sp_exp)];
end
