%Data at smaller radius is noiser becuase there is less data to average.
%This code allows the user to cutoff the data in this region in order to
%avoid maxima/minima false positives 

% x = radius
% y = intensity

function [SptIdX, SptX, Sptint] = max_mindrain(x, y);
length = size(y,1);


for i=1:size(y,2)
plot(x, y(:,i))
Q1 = 'cutoff? '; 
val{i} = input(Q1);
tmp{i} = abs(x-val{i});
[blah idx{i}] = min(tmp{i}); %index of closest value
cutoff{i} = idx{i};
end


for i = 1:size(y,2)
[Max{i},MaxIdx{i}] = findpeaks(y(cutoff{i}:length,i:i),'MinPeakProminence',0.9);
MaxIdx{i} = MaxIdx{i} + cutoff{i}-1; %accounts for shift in x-coordinates in previous line
[Min{i},MinIdx{i}] = findpeaks(-y(cutoff{i}:length,i:i),'MinPeakProminence', 0.9); %finds maximums & x-coordinates 
Min{i} = -Min{i}; %corrects sign to find minimums
MinIdx{i} = MinIdx{i} + cutoff{i} - 1;

MaxCal{i} = x(MaxIdx{i}).';
MinCal{i} = x(MinIdx{i}).';
end


for i=1:size(y,2)
SptIdX{i} = sort(vertcat(MinIdx{i},MaxIdx{i}),'ascend');
SptX{i} = sort(vertcat(MaxCal{i}.',MinCal{i}.'),'ascend');
Sptint{i} = y((SptIdX{i}),i:i); 
end
end

