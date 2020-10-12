function [center] = intensity_houghTransform(img_data)
object = 'bright';
sensitivity = 0.985;

r1 = 120;
r2 = 180;

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
prompt2 = 'Select the index corresponding a correct circle: ';
p2 = input(prompt2);

center = centers(p2,:);
end

