function [center, radius] = intensity_houghTransform(img_data)
% intensity_houghTransform.m Performs a hough transform to identify circles
% in provided image data
%   Inputs:
%       img_data: intensity vs pixel of an image containing circles to be
%       identified
%   Outputs:
%       center: x,y co-ordinates of the center of circle as identified by
%       user



%--------------------------------------------------------------------------
%   User adjustable parameters
%--------------------------------------------------------------------------

object = 'bright';
sensitivity = 0.985;

r1 = 50;
r2 = r1+20;

%--------------------------------------------------------------------------
%   End user adjustable parameters
%--------------------------------------------------------------------------

[centers, radii] = imfindcircles(img_data, [r1, r2],...
    'ObjectPolarity',object, 'Sensitivity',sensitivity);

while isempty(radii) == 1
    prompt = 'No circles detected. Adjust sensitivity to try again. Sensitivity: ';
    p1 = input(prompt);
    [centers, radii] = imfindcircles(img_data, [r1, r2],...
    'ObjectPolarity',object, 'Sensitivity',p1); 
end

disp('circle detected. Showing overlay');
% viscircles(centers, radii);
hold on
scatter(centers(:,1), centers(:,2))
disp(centers);
hold off
prompt2 = 'Select the index corresponding a correct circle: ';
p2 = input(prompt2);

while p2 == 0
    r1_prompt = 'Adjsut r1 value to re-attempt transform: '
    r1 = input(r1_prompt);
    
    [centers, radii] = imfindcircles(img_data, [r1, r2],...
    'ObjectPolarity',object, 'Sensitivity',sensitivity);
    
if isempty(centers)
    continue
    
else

    disp('circle detected. Showing overlay');
    % viscircles(centers, radii);
    hold on
    scatter(centers(:,1), centers(:,2))
    disp(centers);
    hold off
    prompt2 = 'Select the index corresponding a correct circle: ';
    p2 = input(prompt2);
    
end

end
    
center = centers(p2,:);
radius = radii(p2,:);
end

