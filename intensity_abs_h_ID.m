function [dimp_h_red, dimp_h_blue, save_abs_h] = intensity_abs_h_ID(pixels, norm_int, ind_int, dimp_ind)

pix_red = pixels(:,1);
norm_red = norm_int(:,1);
ind_red = ind_int{1};
dimp_red = dimp_ind(1);

pix_blue = pixels(:,2);
norm_blue = norm_int(:,2);
ind_blue = ind_int{2};
dimp_blue = dimp_ind(2);

% Plot normalised red intensity and scatter points of ID'd max/min
% 
% figure(5)
% plot(pix_red, norm_red, 'red', 'LineWidth', 2)
% hold on
% scatter(pix_red(ind_red), norm_red(ind_red), 200, 'black', 'filled')
% hold off
% 
% disp(pix_red(ind_red).')
% disp(1:length(ind_red))
% prompt3 = 'Identify index of max/min one *before* red dimple: ';
% dimp_red = input(prompt3);
% 
% % Plot normalised blue intensity and scatter points of ID'd max/min
% 
% figure(6)
% plot(pix_blue, norm_blue, 'blue', 'LineWidth', 2)
% hold on
% scatter(pix_blue(ind_blue), norm_blue(ind_blue), 200, 'black', 'filled')
% hold off
% 
% disp(pix_blue(ind_blue).')
% disp(1:length(ind_blue))
% prompt4 = 'Identify index of max/min one *before* blue dimple: ';
% dimp_blue = input(prompt4);

% Define required physical parameters

lamb_red = 630;
lamb_blue = 450;
n1 = 1.33; % refractive index of water

% Find film thickness for red & blue at points of max/min intensity

numb = 25;
red_sp_h = (1:numb).'*(lamb_red/(n1*4));
blue_sp_h = (1:numb).'*(lamb_blue/(n1*4));

% Find corresponding normalised theoretical intensities at points of
% max/min

red_at_blue_sp = (cos(4*pi*n1*blue_sp_h/lamb_red)+1)./(2);
blue_at_red_sp = (cos(4*pi*n1*red_sp_h/lamb_blue)+1)./(2);

% Identify absolute height by comparing sequence of intensity pairs

seq_n = 3;
find_abs_h_rab = zeros(length(red_sp_h)-seq_n,1);
find_abs_h_bar = zeros(length(blue_sp_h)-seq_n,1);

red_at_blue_exp = flip(norm_red(ind_blue(1:dimp_blue))); % Flip so that height is increasing
blue_at_red_exp = flip(norm_blue(ind_red(1:dimp_red))); % Flip so that height is increasing

for ii = 1:length(find_abs_h_rab)
   
    find_abs_h_rab(ii) = abs(red_at_blue_exp(1)-red_at_blue_sp(ii))+...
        abs(red_at_blue_exp(2)-red_at_blue_sp(ii+1))+...
        abs(red_at_blue_exp(3)-red_at_blue_sp(ii+2));    
end

for ii = 1:length(find_abs_h_bar)
   
    find_abs_h_bar(ii) = abs(blue_at_red_exp(1)-blue_at_red_sp(ii))+...
        abs(blue_at_red_exp(2)-blue_at_red_sp(ii+1))+...
        abs(blue_at_red_exp(3)-blue_at_red_sp(ii+2));
end

find_abs_h_rab = round(find_abs_h_rab, 4);
find_abs_h_bar = round(find_abs_h_bar, 4);

[seq_min_rab, I_seq_min_rab] = min(find_abs_h_rab);
[seq_min_bar, I_seq_min_bar] = min(find_abs_h_bar);



blue_sp_h(I_seq_min_rab);
red_sp_h(I_seq_min_bar);

dimp_h_red = red_sp_h(I_seq_min_bar:dimp_red+I_seq_min_bar-1); % bar is blue at red  SP. It refers to max/min in red spectra
dimp_h_blue = blue_sp_h(I_seq_min_rab:dimp_blue+I_seq_min_rab-1); % rab is red at blue  SP. It refers to max/min in blue spectra

dimp_h_red = flip(dimp_h_red);
dimp_h_blue = flip(dimp_h_blue);

figure(7)
scatter(pix_red(ind_red(1:dimp_red)), dimp_h_red, 100, 'red', 'filled')
hold on
scatter(pix_blue(ind_blue(1:dimp_blue)), dimp_h_blue, 100, 'blue', 'filled')
scatter(-pix_red(ind_red(1:dimp_red)), dimp_h_red, 100, 'red', 'filled')
scatter(-pix_blue(ind_blue(1:dimp_blue)), dimp_h_blue, 100, 'blue', 'filled')

save_abs_h = [lamb_red, lamb_blue, n1, seq_n];
end

