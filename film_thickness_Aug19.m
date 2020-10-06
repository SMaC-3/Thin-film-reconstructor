function [FilmX, HT] = film_thickness_Aug19(x,y, SptIdX, SptX, SptInt)
numimgs = size(y,2);


%%%% Define physical constants %%%%
lambda = 450;   %wavelength of light in nm
n = 1.33;       %refracrive index
factor = (lambda/(4*n)); 


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
lengthSptIdx = cellfun('length',SptIdX); 

for i=1:numimgs
if str{i} == 'Y' %If there is a dimple rim, then film in thinest at dimple rim
       if str2{i} == 'Y' %If the dimple rim gives an apparent maximum
   a{i} = 1:lengthSptIdx(i)-1;
   b{i} = abs(a{i} - (Dindex{i}-0.5)) + 2.5;
   c{i} = b{i}*factor;
       
       else %If the dimple rim gives an apparent minimum
   a{i} = 1:lengthSptIdx(i)-1;
   b{i} = abs(a{i} - (Dindex{i}-0.5)) + 1.5;
   c{i} = b{i}*factor;
       end
       
d{i} = find(SptIdX{i}~=SptIdX{i}(Dindex{i}));
e{i} = SptIdX{i}(d{i});

  else %If there is no dimple rim, then film thickness only increases outward from the centre
for ii=1:lengthSptIdx(i)
    Ht{i}(ii) = ii*(0.25*lambda/n);
    FilmIdX = SptIdX;
end
end
end



for i=1:numimgs
FilmCal{i} = x(e{i}); %does this need to be done separately?
end

for i=1:numimgs
xref{i} = -fliplr(FilmCal{i}.');
Htref{i} = fliplr(c{i});
end

for i=1:numimgs
FilmX{i} = horzcat(xref{i}, FilmCal{i}.');
HT{i} = horzcat(Htref{i},c{i});
end

end

