% close all
% clear all
img = "/Volumes/T7/Thin films/MultiCam/Xgum/1000ppm_Xgum/1000ppm_Xgum_0p1mMKCl_0p2umF_run9/red-tiff/red_1000ppm_Xgum_0p1mM_KCl-1-03159-23-6151-1219.tiff";
red_fig = imread(img);
red_fig_dbl = double(red_fig);

x_cent = 256;
y_cent = 256 ;
 
max_rad = 150;

% red_int_min=min(min(red_fig_dbl));
% red_int_max=max(max(red_fig_dbl));
% 
red_int_min = 37655.44;
red_int_max = 53237.80;

red_norm = (2*red_fig_dbl - (red_int_max+red_int_min))./(red_int_max-red_int_min);
% imshow(red_norm)
lamb_red = 630;
lamb_blue = 450;
n1 = 1.33; % refractive index of water
factor = (4*pi*n1)/lamb_red; % convert argument to height
h_inv_red = real(acos(red_norm)./factor);
% h_inv_red = 118+(118-real(acos(red_norm)./factor));

x = linspace(1, 512,512);
y=x;
[xx, yy] = meshgrid(x,y);
zz = griddata(x,y,h_inv_red, xx,yy);

rr = ((xx-x_cent).^2+(yy-y_cent).^2).^(0.5);
rr_log = rr>max_rad;
rr_log_2 = rr<0;
zz_2 = zz;
zz_2(rr_log)=nan;
zz_2(rr_log_2) = nan;
h_inv_red_2 = h_inv_red;
h_inv_red_2(rr_log)=nan;
h_inv_red_2(rr_log_2) = nan;

figure()
contour3(h_inv_red_2,100)
colormap jet
colorbar
ax = gca;
ax.ZLim = [0,120];
% ax.ZLim = [110,220];

fig = gcf;
fig.Color = 'white';

ax = gca;
ax.Color = 'white';
ax.XColor = 'white';
ax.YColor = 'white';
ax.ZColor = 'white';

% Colorbar
ax.Colorbar.FontSize = 16;
ax.Colorbar.FontWeight = 'bold';
ax.Colorbar.Label.String = "Film thickness (nm)";
