%Prompts user to identify if dimple is present [Y]/[N]? If Y then user must
%identify index corresponding to dimple rim, if N then
%assumed to be spherical. Data must be pre-processed via imageJ to obtain
%an excel file of radius vs intensity.

% Key 

% x = radius 
% y = intensity
% SptIdX = values corresponding to the index of stationary points in x matrix 
% SptX = Lists values of x at which stationary points occur
% SptInt = Lists intensity values at which stationary points occur

%Begin data prep
clc; clear all; close all
%global x y Max MaxIdx Min MinIdx

set = 'H2O_171004_3';

[x,y] = data_prep('TriggerH2O.xlsx',set);

[SptIdX, SptX, SptInt] = max_min(x, y); %max_mindrain allows user to select cutoff for each profile

[FilmX, HT] = film_thickness_Aug19(x,y, SptIdX, SptX, SptInt); 
figure
for i = 1:size(HT,2)
hold on
scatter(FilmX{i},HT{i}) 
end

Q = 'Save? Y/N [Y]: ';
str = input(Q, 's');

if isempty(str)
    str = 'Y';
end

% for i = 1:size(FilmX,2)
% p{i} = polyfit(FilmX{i}, HT{i}, 9);
% xI{i} = linspace(min(FilmX{i}), max(FilmX{i}),1000);
% yI{i} = polyval(p{i},xI{i});
% end

% if str == 'Y';
%      save(set, 'FilmX','HT','SptIdX','SptInt','SptX','x','y');
% end








