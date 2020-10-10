% This function identifies the points of maxima and minima in the intensity
% vs lateral dimension data using the findpeaks function. Sometimes noise in 
% the data around the centre of interference pattern (smaller radius over 
% which to average the data can be mistaken as a genuine maximum or minimum.
% THIS VERSION of the MAX MIN code plots all of the intensity spectra on one 
% figure and asks the user for a universal "cutoff" point along the lateral 
% dimension and then excludes data up to this value from being included in 
% the findpeaks identification 

function [SptIdX, SptX, Sptint] = max_min(x, y);
length = size(y,1);
hold on
for i=1:size(y,2)
plot(x, y(:,i))
end
hold off
Q1 = 'cutoff? ';
val = input(Q1);
tmp = abs(x-val);
[blah idx] = min(tmp); %index of closest value
cutoff = idx;

%Find maxima and minima. Minima are found by reflecting the data to convert
%them to maxima and correcting later on
for i = 1:size(y,2)
[Max{i},MaxIdx{i}] = findpeaks(y(cutoff:length,i:i),'MinPeakProminence',0.9);
MaxIdx{i} = MaxIdx{i} + cutoff-1; %accounts for shift in x-coordinates in previous line
[Min{i},MinIdx{i}] = findpeaks(-y(cutoff:length,i:i),'MinPeakProminence', 0.9); 
Min{i} = -Min{i}; %corrects sign to find minimums
MinIdx{i} = MinIdx{i} + cutoff - 1;

MaxCal{i} = x(MaxIdx{i}).';
MinCal{i} = x(MinIdx{i}).';
end
for i=1:size(y,2)
SptIdX{i} = sort(vertcat(MinIdx{i},MaxIdx{i}),'ascend');
SptX{i} = sort(vertcat(MaxCal{i}.',MinCal{i}.'),'ascend');
Sptint{i} = y((SptIdX{i}),i:i); 
end
end

