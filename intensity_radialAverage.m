% close all;
% clear all;

% --------------------------------------------------------------------------
% Annular data extraction %
% --------------------------------------------------------------------------

function [bins, binaverage, dataTable] = intensity_radialAverage(img_data, center)

% Set center of interference pattern using x and y index as determined by
% circular Hough transform

xcentre=center(1);
ycentre=center(2);

% Set size of radius in pixels;

r_max = 300;

%Calculate the magnitude of distance of each point in graph from centre
rows = 1024;
cols = rows;

x = 1:rows;
y = x;

[xx, yy] = meshgrid(x,y);
xx = xx - 1;
yy = yy - 1;

% Determine radius from center (as set above)
radius = sqrt((xx - xcentre).^2 + (yy - ycentre).^2);

% Draw a set of x,y points for the circles chosen
theta = linspace(0, 2*pi, 314);
cx = r_max*cos(theta) + xcentre;
cy = r_max*sin(theta) + ycentre;

figure(1)
hold on
scatter(cx,cy)

%Capture points that fall within r_max based on their radius from (xcentre,
%ycentre)

I_rad = radius<r_max;
rad = radius(I_rad);
xx_recent = xx(I_rad)-xcentre; % +1?
yy_recent = (yy(I_rad)-ycentre)*-1; % +1?
rad_col = xx(I_rad)+1;
rad_row = yy(I_rad)+1;
rad_val = img_data(I_rad);

ang = zeros(length(rad_row),1);
for i = 1:length(rad_row)
if yy_recent(i) > 0
    ang(i) = atan(xx_recent(i)/yy_recent(i));
elseif yy_recent(i) < 0
    ang(i) = atan(xx_recent(i)/yy_recent(i)) + pi;    
end
end

%Plots the sectioned data


%Calculate the angles for the obtained points. Zero is twleve o clock (vertically up on y-axis)
% for i = 1:length(annul_x)
% if annul_y(i) > 0
%     annul_ang(i) = atan(annul_x(i)/annul_y(i));
% elseif annul_y(i) < 0
%     annul_ang(i) = atan(annul_x(i)/annul_y(i)) + pi;    
% end
% end

% Sort data in order of increasing radius

[rad, I_rad] = sort(rad);
rad_col = rad_col(I_rad);
rad_row = rad_row(I_rad);
rad_val = rad_val(I_rad);
rad_val = double(rad_val);

%Binning the data
%Setting the bins

nbs = 500;
delr = r_max/nbs;
bins = linspace(0,r_max,nbs);

%Filling the bins
binindex = zeros(1,nbs);
bintotal = zeros(1,nbs);

for iii = 1:nbs-1
    for iv = 1:length(rad)
        if rad(iv)>=bins(iii)
			if rad(iv)<bins((iii + 1))
                binindex(iii) = binindex(iii) + 1;
                bintotal(iii) = bintotal(iii) + rad_val(iv);
            end
        end
    end
end

%Averages the data in the bins, and plots it
binaverage = bintotal./binindex;
bins = bins.';
binaverage = binaverage.';

figure(2)
hold on
scatter(bins, binaverage)
hold off

dataTable = table(bins, binaverage);
% 
% if saveSet == 1
%     folder = '2D_annular_sector_extraction/Annular/';
%     type = '.dat';
%     path = strcat(folder, fileInput, type);
%     
%     writetable(dataTable, path, 'Delimiter', '\t');
% end

end

