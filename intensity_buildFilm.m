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

% -------------------------------------------------------------

function [T_dimp] =...
    intensity_buildFilm(T_data, phi_correction, pre_T_dimp)

%--------------------------------------------------------------
% Identify absolute height from red/blue intensity ratio with reference
% to ideal, normalised curve
%--------------------------------------------------------------

[radius, dimp_h_red, dimp_h_blue, save_abs_h] =...
    intensity_abs_h_ID_V2(T_data, phi_correction, pre_T_dimp);

dimp_h_red = real(dimp_h_red);
dimp_h_blue = real(dimp_h_blue);

T_dimp = table(round(radius,4), round(dimp_h_red,4),round(dimp_h_blue,4),...
    'VariableNames',{'radius','red_film','blue_film'});

figure(8)

scatter([-radius;radius], [dimp_h_blue;dimp_h_blue], 'blue','filled')
hold on
scatter([-radius;radius], [dimp_h_red;dimp_h_red], 'red','filled')
xlabel('Radius (\mu m)');
ylabel('Film thickness (nm)');

end