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

%--------------------------------------------------------------

function [center, radius] = intensity_houghTransform(img_data)

% intensity_houghTransform.m Performs a hough transform to identify circles
% in provided image data
%   Inputs:
%       img_data: intensity vs pixel of an image containing circles to be
%       identified
%   Outputs:
%       center: x,y co-ordinates of the center of circle as identified by
%       user

%%   User adjustable parameters
% Parameters used in Hough transform 

sensitivity = 0.992;
r1 = 190; % r2 = r1+20 is set later in code

%--------------------------------------------------------------
%   End user adjustable parameters
%--------------------------------------------------------------

disp('1: Run Hough transform with default settings')
disp('2: Adjust Hough transform sensitivity')
disp('3: Adjust Hough transform radius')
disp('4: Manually draw circle')
disp('5: Manually supply center and radius')

action_input = 'Please select an option: ';
action_select = input(action_input);
while isempty(action_select)
    action_select = input(action_input);
end

radius = [];

while isempty(radius) == 1

    if action_select == 1

        [center, radius] = run_HoughTransform(img_data, sensitivity, r1);

    elseif action_select == 2

        disp(strcat('Current sensitivity: ', ' ',string(sensitivity)));

        sensitivity_prompt = 'Enter sensitivity for Hough transform: ';
        sensitivity = input(sensitivity_prompt);
        [center, radius] = run_HoughTransform(img_data, sensitivity, r1);

    elseif action_select == 3

        disp(strcat('Current lower bound radius: ', ' ',string(r1)));

        radius_prompt = 'Enter lower bound radius for Hough transform: ';
        r1 = input(radius_prompt);
        [center, radius] = run_HoughTransform(img_data, sensitivity, r1);

    elseif action_select == 4

        [center, radius] = run_manualCircle(img_data);

    elseif action_select == 5

        [center, radius] = run_manualInput(img_data);

    else
        disp('Please enter a valid selection')
    end

    if isempty(radius) == 1
        
        disp('1: Run Hough transform with default settings')
        disp('2: Adjust Hough transform sensitivity')
        disp('3: Adjust Hough transform radius')
        disp('4: Manually draw circle')
        disp('5: Manually supply center and radius')

        action_select = input(action_input);
        while isempty(action_select)
            action_select = input(action_input);
        end
    end
end
    
end


function [center, radius] = run_HoughTransform(img_data, sensitivity, r1)

object = 'bright';
if isempty(sensitivity) == 1
    sensitivity = 0.985;
end
if isempty(r1) == 1
    r1 = 120;
end
r2 = r1+20;

[centers, radii] = imfindcircles(img_data, [r1, r2],...
    'ObjectPolarity',object, 'Sensitivity',sensitivity);

if isempty(radii) == 1

    disp('No circles detected using supplied Hough transform settings.')

    center = [];
    radius = [];

else

    disp('Circles detected using supplied Hough transform settings.')

    figure(1)
    imshow(img_data)
    hold on
    scatter(centers(:,1), centers(:,2))
    center_count = round([1:size(centers,1)],0).';
    disp([center_count , centers]);
    hold off
    disp('Enter 0 in below prompt to reject all options')
    prompt2 = 'Select the index corresponding a correct circle: ';
    p2 = input(prompt2);

    if p2 == 0
        center = [];
        radius = [];

    else
        center = centers(p2,:);
        radius = radii(p2,:);

        figure(1)
        imshow(img_data)
        viscircles(center, radius);
        hold on
        scatter(center(1,1), center(1,2),100,'x', 'red')
        hold off
    end

end
end

function [center, radius] = run_manualCircle(img_data)

    figure(1)
    BW = imbinarize(img_data);
    imshow(BW);
    roi = drawcircle;
    roi.LineWidth = 0.5;
    input('Press enter to continue: ');
    center = round(roi.Center);
    radius = round(roi.Radius);

    figure(1)
    imshow(img_data)
    viscircles(center, radius);
    hold on
    scatter(center(1,1), center(1,2),100,'x', 'red')
    hold off

end

function [center, radius] = run_manualInput(img_data)

    center_prompt = 'Enter coordinates for circle center: ';
    radius_prompt = 'Enter radius for circle: ';

    center = input(center_prompt);
    radius = input(radius_prompt);

    figure(1)
    imshow(img_data)
    viscircles(center, radius);
    hold on
    scatter(center(1,1), center(1,2),100,'x', 'red')
    hold off
end
