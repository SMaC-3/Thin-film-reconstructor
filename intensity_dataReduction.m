function [T_export] =  intensity_dataReduction(radial_data, red_int, blue_int)
%--------------------------------------------------------------------------
% Identify red & blue maxima/minima within bounds
%--------------------------------------------------------------------------

[red_I_min, red_I_max, red_min, red_max] = ...
    intensity_maxMin(radial_data, red_int);

[blue_I_min, blue_I_max, blue_min, blue_max] = ...
    intensity_maxMin(radial_data, blue_int);

%--------------------------------------------------------------------------
% Correct for uneven illumination
%--------------------------------------------------------------------------

[red_P, red_y, red_int_cor] =...
    intensity_gradCorrect(radial_data, red_int, red_I_min, red_I_max);

[blue_P, blue_y, blue_int_cor] =...
intensity_gradCorrect(radial_data, blue_int, blue_I_min, blue_I_max);

%--------------------------------------------------------------------------
% Normalise data branch-wise
%--------------------------------------------------------------------------

[red_norm, red_dimp, red_I_min, red_I_max] =...
    intensity_normalise(radial_data, red_int_cor, red_I_min, red_I_max);

[blue_norm, blue_dimp, blue_I_min, blue_I_max] =...
    intensity_normalise(radial_data, blue_int_cor, blue_I_min, blue_I_max);

% Note minima/maxima index may have changed, so _min, _max values may be
% incomplete

%--------------------------------------------------------------------------
% Save data to text file
%--------------------------------------------------------------------------

red_I_sp = sort([red_I_min;red_I_max]);
blue_I_sp = sort([blue_I_min;blue_I_max]);

red_I_max_min = zeros(length(radial_data),1);
blue_I_max_min = zeros(length(radial_data),1);

red_I_max_min(red_I_min) = -1;
red_I_max_min(red_I_max) = 1;
blue_I_max_min(blue_I_min) = -1;
blue_I_max_min(blue_I_max) = 1;

red_trendline = zeros(length(radial_data),1);
red_trendline(1:2) = red_P;
blue_trendline = zeros(length(radial_data),1);
blue_trendline(1:2) = blue_P;

red_I_dimp = zeros(length(radial_data),1);
blue_I_dimp = zeros(length(radial_data),1);

red_I_dimp(red_I_sp(red_dimp)) = 1;
blue_I_dimp(blue_I_sp(blue_dimp)) = 1;

T_export = table(radial_data, red_int, blue_int,...
    round(red_int_cor,4), round(blue_int_cor,4),...
    round(red_norm,4), round(blue_norm,4),...
    red_I_max_min, blue_I_max_min, red_I_dimp, blue_I_dimp,...
    round(red_trendline,4), round(blue_trendline,4),...
    'VariableNames', {'radius','red_int_raw','blue_int_raw',...
    'red_int_corrected','blue_int_corrected',...
    'red_norm','blue_norm','red_I_max_min', 'blue_I_max_min',...
    'red_I_dimp', 'blue_I_dimp',...
    'red_trendline', 'blue_trendline'});
    
% writetable(T_export, 'test.txt', 'Delimiter','\t');

end