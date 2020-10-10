function [FilmX, HT] = film_thickness(x,y, SptIdX, SptX, SptInt)
numimgs = size(y,2);


%%%% Define physical constants %%%%
lambda = 450;   %wavelength of light in nm
n = 1.33;       %refracrive index


%%%% Plot intensity profile and ask user if dimple is present %%%%
for i = 1:numimgs
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


%%%% Identify peak corresponding to dimple %%%%
for i=1:numimgs
if str{i} == 'Y'
plot(x,y(:,i))
hold on
scatter(SptX{i},SptInt{i})
hold off
    Q3 = 'Identify index of dimple? ';  %Prompts user to identify dimple rim
    Dindex{i} = input(Q3);
    Q4 = 'Apparent max? Y/N [Y]: ';     %Prompts user to identify if dimple rim is a maximum or minimum
    str2{i} = input(Q4, 's');
    if isempty(str2{i})
        str2{i} = 'Y';
    end
end
end

%%%% Assign film thickness %%%%
for i=1:numimgs
if str{i} == 'Y' %If there is a dimple rim, then film thickness has minimum at dimple rim
for ii=1:Dindex{i} - 1 %Assign height inside dimple
       if str2{i} == 'Y' %If the dimple rim gives an apparent maximum
   DimpleL{i}(ii) = ((Dindex{i} -ii) + 2) * (lambda/(4*n)); 
       else %If the dimple rim gives an apparent minimum
   DimpleL{i}(ii) = (Dindex{i} -ii + 1) * (lambda/(4*n));       
       end
end
   lengthSptIdx = cellfun('length',SptIdX); 
   for ii = 1:lengthSptIdx(i) - Dindex{i} %Assign height outside dimple
       if str2{i} == 'Y'
   DimpleR{i}(ii) = (ii + 2)*(lambda/(4*n));
       else
   DimpleR{i}(ii) = (ii + 1)*(lambda/(4*n));       
       end
   end
   
   for ii=1:Dindex{i} - 1
      DimpleLx{i}(ii) = SptIdX{i}(ii); %Find index of x values inside dimple
   end
   for ii=1:lengthSptIdx(i) - Dindex{i}
      DimpleRx{i}(ii) = SptIdX{i}(ii + Dindex{i}); %Find index of x values outside dimple. Surely there is a better way? 
   end
   
   FilmIdX{i} = horzcat(DimpleLx{i}, DimpleRx{i});
   Ht{i} = horzcat(DimpleL{i}, DimpleR{i});
   
else %If there is no dimple rim, then film thickness only increases outward from the centre
for ii=1:lengthSptIdx(i)
    Ht{i}(ii) = ii*(0.25*lambda/n);
    FilmIdX = SptIdX;
end
end
end

for i=1:numimgs
FilmCal{i} = x(FilmIdX{i});
end

for i=1:numimgs
xref{i} = -fliplr(FilmCal{i}.');
Htref{i} = fliplr(Ht{i});
end

for i=1:numimgs
FilmX{i} = horzcat(xref{i}, FilmCal{i}.');
HT{i} = horzcat(Htref{i},Ht{i});
end

end

