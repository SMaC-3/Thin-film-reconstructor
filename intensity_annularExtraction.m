% -------------------------------------------------------------------------
% INTENSITY_RADIALAVERAGE radially average intensity data in an image file
% between angle bounds 

% A positive angle is measured with respect to the positive x-axis in a
% clock-wise direction
% --------------------------------------------------------------------------

function [bins, bins_micron, binaverage] =...
    intensity_annularExtraction(img_data, center, radius_in, thx, micron_bin)

% Set center of interference pattern using x and y index as determined by
% circular Hough transform
center = round(center);
% center = [258,257];
xcentre=center(1);
ycentre=center(2);
plot_data = 0;

% Set size of radius in pixels;

% r_max = 250;

% %Key points are dimensions of first circle, and annulus thickness.
% 
% micron_bin = 1.4122; % Sets interval between bins in micron
% thx = 5;

%Calculate the magnitude of distance of each point in graph from centre
% rows = 1024;
rows = 512;
cols = rows;

x = 1:rows;
y = x;

[xx, yy] = meshgrid(x,y);
xx = xx - 1;
yy = yy - 1;

% Determine radius from center (as set above)
radius = sqrt((xx - xcentre).^2 + (yy - ycentre).^2);

% Draw a set of x,y points for the circles chosen
% theta = linspace(0, 2*pi, 314);
% cx = r_max*cos(theta) + xcentre;
% cy = r_max*sin(theta) + ycentre;

% %Draw a set of x,y points for the circles chosen
theta = linspace(0, 2*pi, 314);
cx = radius_in*cos(theta);
cy = radius_in*sin(theta);
cxouter = (radius_in + thx)*cos(theta);
cyouter = (radius_in + thx)*sin(theta);

% figure(1)
% hold on
% scatter(cx,cy)

%Capture points that fall within r_max based on their radius from (xcentre,
%ycentre)

xx_cent = xx-xcentre; % +1?
yy_cent = yy-ycentre; % +1?

div = yy_cent./xx_cent;
ang = atan(div);
ang(:,1:center(1)) = ang(:,1:center(1)) + pi;
ang(1:center(2),center(1)+1:end) = ang(1:center(2),center(1)+1:end)+(2*pi);
ang = ang.*(180/pi); % convert to degrees
ang = 360-ang;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [I_ann] = find(radius_in<radius & radius<(radius_in + thx));

I_ann_1 = radius_in<radius;
I_ann_2 = radius<(radius_in + thx);
I_ann = I_ann_1 & I_ann_2;

select = img_data(I_ann);
annul_x = xx(I_ann);
annul_y = yy(I_ann);
annul_ang = ang(I_ann);
annul_rad = radius(I_ann);

%Plots the sectioned data
if plot_data == 1
    figure(2)
    imshow(img_data);
    hold on
    scatter(annul_x, annul_y,5,'blue','MarkerFaceAlpha',0.1,'MarkerEdgeAlpha',0.1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sort data in order of increasing radius

% I_rad_a = radius<r_max;
% I_rad = I_rad_a & I_ang;
% % figure(2)
% % imshow(I_rad);
% rad = radius(I_rad);
% rad_col = xx(I_rad)+1;
% rad_row = yy(I_rad)+1;
% rad_val = img_data(I_rad);

[annul_ang, I_ang] = sort(annul_ang);

annul_x = annul_x(I_ang);
annul_y = annul_y(I_ang);
annul_int = select(I_ang);
annul_int = double(annul_int);

%Binning the data
%Setting the bins

% area = pi*r_max^2;

% nbs = round(1*r_max);

% area_bin = area/nbs;
% bins = zeros(1, nbs);
% bins(2) = sqrt(area_bin/pi);
% 
% for i = 3:nbs
%     bins(i) = sqrt((area_bin/(pi*bins(i-1)^2)+1))*bins(i-1);
% end

pixels_micron = 0.896;

radius_ave = (radius_in+radius_in+thx)/2;
radius_ave_micron = radius_ave/pixels_micron;
circum_micron = 2*pi*radius_ave_micron;

 % How many microns difference b/w bins
nbs = round(circum_micron/micron_bin);

% nbs = 360;
deltheta = 360/nbs;
% bins = zeros(nbs);

for ii = 1:nbs
    bins(ii) = (deltheta)*ii;
end



%Filling the bins
binindex = zeros(1,nbs);
bintotal = zeros(1,nbs);

for iii = 1:nbs-1
    for iv = 1:length(annul_int)
        if annul_ang(iv)>=bins(iii)
			if annul_ang(iv)<bins((iii + 1))
                binindex(iii) = binindex(iii) + 1;
                bintotal(iii) = bintotal(iii) + annul_int(iv);
            end
        end
    end
end

%Averages the data in the bins, and plots it
binaverage = bintotal./binindex;
bins = bins.';
binaverage = binaverage.';
micron_deg = circum_micron/360;
bins_micron = bins.*micron_deg;



if plot_data == 1

    figure(4)
    % plot(bins, binaverage)
    hold on

    fig = gcf;
    ax = gca;

    fig.Color = 'white';

    % ax.Units = 'centimeters';
    ax.LineWidth = 1.5;
    ax.XColor = 'k';
    ax.YColor = 'k';
    ax.FontName = 'Helvetica';
    ax.FontSize = 18;
    ax.FontWeight = 'bold';
    ax.Box= 'off';
    %     ax.YLim = [0,200];
    ax.XLim = [0,360];

    xlabel('Azimuthal angle (degrees)','FontWeight','bold');
    ylabel('Intensity (A.U)','FontWeight','bold');

    plot(bins, binaverage,'Color',[0,0,1],'LineWidth',1.5)

    figure(5)
    hold on

    fig = gcf;
    ax = gca;

    fig.Color = 'white';

    % ax.Units = 'centimeters';
    ax.LineWidth = 1.5;
    ax.XColor = 'k';
    ax.YColor = 'k';
    ax.FontName = 'Helvetica';
    ax.FontSize = 18;
    ax.FontWeight = 'bold';
    ax.Box= 'off';
    %     ax.YLim = [0,200];

    xlabel('Azimuthal dimension (\mum)','FontWeight','bold');
    ylabel('Intensity (A.U)','FontWeight','bold');

    plot(bins_micron, binaverage,'Color',[0,0,1],'LineWidth',1.5)
end
% 
% figure(2)
% hold on
% scatter(bins, binaverage, 100, 'black','filled')
% hold off

% dataTable = table(bins, binaverage);
% 
% if saveSet == 1
%     folder = '2D_annular_sector_extraction/Annular/';
%     type = '.dat';
%     path = strcat(folder, fileInput, type);
%     
%     writetable(dataTable, path, 'Delimiter', '\t');
% end

end

