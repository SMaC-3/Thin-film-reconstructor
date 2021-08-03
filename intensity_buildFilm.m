function [T_dimp] =...
    intensity_buildFilm(T_data)

%--------------------------------------------------------------------------
% Smooth data
%--------------------------------------------------------------------------

% blue_int = smooth(blue_int);

%--------------------------------------------------------------------------
% Identify absolute height from red/blue intensity ratio with reference
% to ideal, normalised curve
%--------------------------------------------------------------------------

[radius, dimp_h_red, dimp_h_blue, save_abs_h] =...
    intensity_abs_h_ID(T_data);

dimp_h_red = real(dimp_h_red);
dimp_h_blue = real(dimp_h_blue);

T_dimp = table(round(radius,4), round(dimp_h_red,4),round(dimp_h_blue,4),...
    'VariableNames',{'radius','red_film','blue_film'});

% pixels_mm = 1792/2; 
% Conversion from 2048 x 2048 image at 10x magnification -- need to divide by 2
% pixels_um = pixels_mm/1000;

figure(8)

scatter([-radius;radius], [dimp_h_blue;dimp_h_blue], 'blue','filled')
hold on
scatter([-radius;radius], [dimp_h_red;dimp_h_red], 'red','filled')
xlabel('Radius (\mu m)');
ylabel('Film thickness (nm)');

end