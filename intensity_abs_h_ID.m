function [dimp_h_red, dimp_h_blue, save_abs_h] = intensity_abs_h_ID(pixels, norm_int, ind_int, max_min, dimp_ind, dimp_out)

%--------------------------------------------------------------------------
% Define intensity profile & peak info for red and blue
%--------------------------------------------------------------------------

pix_red = pixels(:,1);
norm_red = norm_int(:,1);
ind_red = ind_int{1};
max_min_red = max_min{1};
dimp_red = dimp_ind(1);
dimp_red_outer = dimp_out(1);

pix_blue = pixels(:,2);
norm_blue = norm_int(:,2);
ind_blue = ind_int{2};
max_min_blue = max_min{2};
dimp_blue = dimp_ind(2);
dimp_blue_outer = dimp_out(2);

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

numb = 50;
max_min = repmat([0,1],1,numb/2).';
red_sp_h = (1:numb).'*(lamb_red/(n1*4));
blue_sp_h = (1:numb).'*(lamb_blue/(n1*4));

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

ind_inner_red = ind_red(1:dimp_red);
ind_outer_red = ind_red(dimp_red_outer:end);

ind_inner_blue = ind_blue(1:dimp_blue);
ind_outer_blue = ind_blue(dimp_blue_outer:end);

max_min_inner_red = max_min_red(1:dimp_red);
max_min_outer_red = max_min_red(dimp_red_outer:end);

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
% Find matching sequence b/w experimental and theory max/min
%--------------------------------------------------------------------------


%Note that blue and red have a common minimum that could cause problems!
numPts = 10;
for i = 1:length(sorted_sp_info)-1
%    if i < length(sorted_sp_info) - length(sp_exp)+1 % Do I need this or could I just extend matrix beyond observable limit and run loop to that limit + trim post loop?
%        
%        sorted_sp_info(i, 4) = sum(sum(abs(sorted_sp_info(i:i+length(sp_exp)-1,2:3)-sp_exp(:,2:3))));
    if i < length(sorted_sp_info) - numPts +1 % Do I need this or could I just extend matrix beyond observable limit and run loop to that limit + trim post loop?
       
       sorted_sp_info(i, 4) = sum(sum(abs(sorted_sp_info(i:i+numPts-1,2:3)-sp_exp(1:numPts,2:3))));

   else 
       sorted_sp_info(i, 4) = sum(sum(abs(sorted_sp_info(i:end,2:3)-sp_exp(1:length(sorted_sp_info)-i+1,2:3))));
       
   end
end

%--------------------------------------------------------------------------
% Find height at first stationary point inside dimple based on matching
% series of max/min
%--------------------------------------------------------------------------

I_min_h = find(sorted_sp_info(1:end-1,4) == 0,1);
if isempty(I_min_h)
    disp(sorted_sp_info);
    error_call = 'Could not identify minimum height. Please input index  corresponding to minimum height: ';
    I_min_h = input(error_call);
end

min_lambda = sorted_sp_info(I_min_h,3);

if min_lambda == 450
    min_blue_h = sorted_sp_info(I_min_h, 1);
    I_min_b_h = find(blue_sp_h - min_blue_h == 0);
    
    find_red = red_sp_h - min_blue_h;
    find_red(find_red<=0) = NaN;
    
    [min_red_h, I_min_r_h] =min(find_red); 

elseif min_lambda == 630
    min_red_h = sorted_sp_info(I_min_h, 1);
    I_min_r_h = find(red_sp_h - min_red_h == 0);
    
    find_blue = blue_sp_h - min_red_h;
    find_blue(find_blue<=0) = NaN;
    
    [min_blue_h, I_min_b_h] =min(find_blue);
    
end
    
% min_h = sorted_sp_info(I_min_h, 1);
% sp_exp(:,4) = sorted_sp_info(I_min_h:I_min_h+length(sp_exp)-1, 1); % Add column for height to sp_exp

blue_h = sp_exp(sp_exp(:,3)==450,:);
blue_h(:,4) = blue_sp_h(I_min_b_h:I_min_b_h+size(blue_h,1)-1);
red_h = sp_exp(sp_exp(:,3)==630,:);
red_h(:,4) = red_sp_h(I_min_r_h:I_min_r_h+size(red_h,1)-1);

% I_min_r_h = find(red_sp_h == red_h(1,4));


red_sp_exp_outer = [ind_outer_red, max_min_outer_red,...
    red_sp_h(I_min_r_h:I_min_r_h+length(ind_outer_red)-1)];

% I_min_b_h = find(blue_sp_h == blue_h(1,4));

blue_sp_exp_outer = [ind_outer_blue, max_min_outer_blue,...
    blue_sp_h(I_min_b_h:I_min_b_h+length(ind_outer_blue)-1)];

% red channel film reconstruction

dimp_h_red = zeros(length(pix_red),1); % Empty matrix for height inversion at each bin
new_norm = (norm_red*2)-1; % cosine component of interferometry eq'n
factor = (4*pi*n1)/lamb_red; % convert argument to height
h_inv_red = acos(new_norm)./factor; % acos returns value b/w [0, pi]


% From edge of dimple inwards

for i = 1:size(red_h,1)-1
   if red_h(i,2) == 1 % Red maximum
       % dimple height from previous minimum to maximum = height@max +
       % inverted height from previous minimum to maximum
       dimp_h_red(red_h(i+1,1):red_h(i,1)) = red_h(i,4) + h_inv_red(red_h(i+1,1):red_h(i,1));
       
   elseif red_h(i,2) == 0 % Red minimum
       % dimple height from previous maximum to minimum = height@max -
       % inverted height from previous maximum to minimum
       dimp_h_red(red_h(i+1,1):red_h(i,1)) = red_h(i+1,4) - h_inv_red(red_h(i+1,1):red_h(i,1));
    
   end
       
end


% From outer-edge outwards


for i = 1:size(red_sp_exp_outer,1)-1
   if red_sp_exp_outer(i,2) == 1
       
       dimp_h_red(red_sp_exp_outer(i,1):red_sp_exp_outer(i+1,1)) =...
           red_sp_exp_outer(i,3) + h_inv_red(red_sp_exp_outer(i,1):red_sp_exp_outer(i+1,1));
       
   elseif red_sp_exp_outer(i,2) == 0
    
       dimp_h_red(red_sp_exp_outer(i,1):red_sp_exp_outer(i+1,1)) =...
           red_sp_exp_outer(i+1,3) - h_inv_red(red_sp_exp_outer(i,1):red_sp_exp_outer(i+1,1));
    
   end
       
end
 

% blue channel film reconstruction

%%% Uncomment for blue 

dimp_h_blue = zeros(length(pix_blue),1); % Empty matrix for height inversion at each bin
new_norm = (norm_blue*2)-1; % cosine component of interferometry eq'n
factor = (4*pi*n1)/lamb_blue; % convert argument to height
h_inv_blue = acos(new_norm)./factor; % acos returns value b/w [0, pi]


% From edge of dimple inwards

for i = 1:size(blue_h,1)-1
   if blue_h(i,2) == 1
       
       dimp_h_blue(blue_h(i+1,1):blue_h(i,1)) = blue_h(i,4) + h_inv_blue(blue_h(i+1,1):blue_h(i,1));
       
   elseif blue_h(i,2) == 0
    
       dimp_h_blue(blue_h(i+1,1):blue_h(i,1)) = blue_h(i+1,4) - h_inv_blue(blue_h(i+1,1):blue_h(i,1));
    
   end
end

for i = 1:size(blue_sp_exp_outer,1)-1
   if blue_sp_exp_outer(i,2) == 1
       
       dimp_h_blue(blue_sp_exp_outer(i,1):blue_sp_exp_outer(i+1,1)) =...
           blue_sp_exp_outer(i,3) + h_inv_blue(blue_sp_exp_outer(i,1):blue_sp_exp_outer(i+1,1));
       
   elseif blue_sp_exp_outer(i,2) == 0
    
       dimp_h_blue(blue_sp_exp_outer(i,1):blue_sp_exp_outer(i+1,1)) =...
           blue_sp_exp_outer(i+1,3) - h_inv_blue(blue_sp_exp_outer(i,1):blue_sp_exp_outer(i+1,1));
    
   end
       
end

zap_red = find(dimp_h_red ==0);
% dimp_h_red = dimp_h_red(zap_red);
% pix_red_zap = pix_red(zap_red);
dimp_h_red(zap_red) = NaN;

figure(6)
scatter(pix_red, dimp_h_red, 'red', 'filled')
hold on
scatter(-pix_red, dimp_h_red, 'red', 'filled')


zap_blue = find(dimp_h_blue ==0);
% dimp_h_blue = dimp_h_blue(zap_blue);
% pix_blue_zap = pix_blue(zap_blue);
dimp_h_blue(zap_blue) = NaN;

figure(7)
scatter(pix_blue, dimp_h_blue, 100, 'blue', 'filled')
hold on
scatter(-pix_blue, dimp_h_blue, 100, 'blue', 'filled')

save_abs_h = [lamb_red, lamb_blue, n1, length(sp_exp)];
end
