function [FilmX, HT, Hdimp, Xdimp] = film_thickness_highres(x,y, SptIdX, SptX, SptInt)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

lambda = 450;
n = 1.33;

for i = 1:size(y,2)
plot(x,y(:,i))
hold on
scatter(SptX{i},SptInt{i})
hold off
Q2 = 'Is dimple present? Y/N [Y]: ';
str{i} = input(Q2, 's');
if isempty(str{i})
    str{i} = 'Y';
end
end

for i=1:size(y,2)
if str{i} == 'Y'
plot(x,y(:,i))
hold on
scatter(SptX{i},SptInt{i})
hold off
    Q3 = 'Identify index of dimple? '; %This point is not included
    Dindex{i} = input(Q3);
    Q4 = 'Apparent max? Y/N [Y]: ';
    str2{i} = input(Q4, 's');
    if isempty(str2{i})
        str2{i} = 'Y';
    end
end
end

for i=1:size(y,2)
if str{i} == 'Y'
for ii=1:Dindex{i} - 1
       if str2{i} == 'Y'
   DimpleL{i}(ii) = (Dindex{i} -ii) * (0.25*lambda/n);
       else 
   DimpleL{i}(ii) = (Dindex{i} -ii + 1) * (0.25*lambda/n);       
       end
end
   lengthSptIdx = cellfun('length',SptIdX);
   for ii = 1:lengthSptIdx(i) - Dindex{i}
       if str2{i} == 'Y'
   DimpleR{i}(ii) = (ii)*(0.25*lambda/n);
       else
   DimpleR{i}(ii) = (ii+1)*(0.25*lambda/n);       
       end
   end
   
   for ii=1:Dindex{i} - 1
      DimpleLx{i}(ii) = SptIdX{i}(ii); 
   end
   for ii=1:lengthSptIdx(i) - Dindex{i}
      DimpleRx{i}(ii) = SptIdX{i}(ii + Dindex{i});
   end
   
   FilmIdX{i} = horzcat(DimpleLx{i}, DimpleRx{i});
   Ht{i} = horzcat(DimpleL{i}, DimpleR{i});
   
else
for ii=1:lengthSptIdx(i)
    Ht{i}(ii) = ii*(0.25*lambda/n);
    %Needs to be a way of identifying the correct thickness to assign in
    %this case
    
    FilmIdX = SptIdX;
end
end
end

for i=1:size(y,2)
Xdimp{i} = x(1:SptIdX{i}(1));
Ydimp{i} = y(1:SptIdX{i}(1));
end


for i = 1:size(y,2)
if mod(Dindex{i},2) == 1
    if str2{i} == 'Y'
        YdimpI{i} = (Ydimp{i} - SptInt{i}(2))/(SptInt{i}(1)-SptInt{i}(2));
    else 
        YdimpI{i} = (Ydimp{i} - SptInt{i}(1))/(SptInt{i}(2)-SptInt{i}(1));
    end
elseif mod(Dindex{i},2) == 0
    if str2{i} == 'Y'
        YdimpI{i} = (Ydimp{i} - SptInt{i}(1))/(SptInt{i}(2)-SptInt{i}(1));
    else
        YdimpI{i} = (Ydimp{i} - SptInt{i}(2))/(SptInt{i}(1)-SptInt{i}(2));
    end
else 
    error('Cannot determine if dimple rim is even or odd')
end
end

maxY = 1;
minY = 0;

for i=1:size(y,2)
    Hpre{i} = (-1)*(lambda/(4*pi*n))*(acos((2*YdimpI{i} - (maxY + minY))/(maxY - minY))- 2*pi);
if mod(Dindex{i},2) == 1
    Hdimp{i} = Hpre{i} + (Dindex{i}-1)*(lambda/(4*n));
elseif mod(Dindex{i},2) == 0
    Hdimp{i} = Hpre{i} + (Dindex{i}-2)*(lambda/(4*n));
else
    error('Cannot assign thickness due to being unable to identify if dimple rim even or odd');
end
end

for i=1:size(y,2)
FilmCal{i} = x(FilmIdX{i});
end

for i=1:size(y,2)
FilmCal{i} = vertcat(Xdimp{i}(1:SptIdX{i}(1)-1),FilmCal{i});
Ht{i} = horzcat(Hdimp{i}(1:SptIdX{i}(1)-1).',Ht{i});
end


for i=1:size(y,2)
xref{i} = -fliplr(FilmCal{i}.');
Htref{i} = fliplr(Ht{i});
end

for i=1:size(y,2)
FilmX{i} = horzcat(xref{i}, FilmCal{i}.');
HT{i} = horzcat(Htref{i},Ht{i});
end

end

