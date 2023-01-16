
function [binsa, binaveragea, dataTable] = intensity_annulus(img_data, center)

% %This section finds the centre of the scattering pattern (if not elsewhere defined)
% %In the absence of anything else, we'll assume they're at 0,0 and defined thus.
center = round(center);
xcentre=center(1);
ycentre=center(2);

% %This section defines the annular parameters. Conversion to q-space will be tricky.
% %For now, we use x,y space.
% %Key points are dimensions of first circle, and annulus thickness.

radius=160;
thx=10;

%Calculate the magnitude of distance of each point in graph from centre
% rows = 1024;
rows = 512;
cols = rows;

x = 1:rows;
y = x;

[xx, yy] = meshgrid(x,y);
xx = xx ;
yy = yy ;

% Determine radius from center (as set above)
magnitude = sqrt((xx - xcentre).^2 + (yy - ycentre).^2);

% %Draw a set of x,y points for the circles chosen
theta = linspace(0, 2*pi, 314);
cx = radius*cos(theta);
cy = radius*sin(theta);
cxouter = (radius + thx)*cos(theta);
cyouter = (radius + thx)*sin(theta);

% 
% N = 100; %NUMBER OF POINTS IN ROW/COLUMN (SQUARED INTO GRID)
% maxq = 0.2; %MAX Q FOR GRID
% 
% % xq = linspace(min(BBY_data(:,1)),max(BBY_data(:,1)),N);
% % yq = linspace(min(BBY_data(:,2)),max(BBY_data(:,2)),N);
% xq = linspace(-maxq,maxq,N);
% yq = linspace(-maxq,maxq,N);
% 
% [xxq,yyq] = meshgrid(xq,yq);
% 
% 
% zzq = griddata(BBY_data(:,1),BBY_data(:,2),BBY_data(:,3),xxq,yyq, 'linear');
% figure(1)
% h = pcolor(xxq,yyq,zzq);
% set(gca,'ColorScale','log')
% set(h, 'EdgeColor', 'none');
% hold on
% plot(cx,cy,'w-','LineWidth', 5) 
% plot(cxouter,cyouter,'w-','LineWidth', 5)
% hold off




%Capture points that fall within the annular rings based on their magnitude

I_ann = radius<magnitude & magnitude<(radius + thx);
annul_i = double(img_data(I_ann));
annul_x = xx(I_ann)-xcentre;
annul_y = yy(I_ann)-ycentre;
% annul_i = select(:,3);
annul_mag = magnitude(I_ann);

%Plots the sectioned data
figure(2)
scatter(annul_x, annul_y);

% Display/K=1 annul_y vs annul_x
% ModifyGraph width={Plan,1,bottom,left}
% ModifyGraph mode=3,marker=16,msize=2,zColor(annul_y)={annul_i,*,*,Rainbow,0}

%Calculate the angles for the obtained points. Zero is twleve o clock (vertically up on y-axis)
for i = 1:length(annul_x)
% if annul_y(i) > 0
%     annul_ang(i) = -pi/2 + atan(annul_x(i)/annul_y(i));
% elseif annul_y(i) < 0
%     annul_ang(i) = atan(annul_x(i)/annul_y(i)) + pi/2;    
% end

if annul_y(i) > 0
    annul_ang(i) = atan(annul_x(i)/annul_y(i));
elseif annul_y(i) < 0
    annul_ang(i) = atan(annul_x(i)/annul_y(i)) + pi;    
end
end


%Plots the raw data points from the annulus as a function of angle
figure(3)
scatter(annul_ang, annul_i)

% Display/K=1 annul_i vs annul_ang
% ModifyGraph mode=3,marker=19,msize=2
% ModifyGraph msize(annul_i)=1,rgb(annul_i)=(65535,32768,32768)

%Sorts data to give as a function of increasing angle
[annul_ang, I_ang] = sort(annul_ang);
annul_x = annul_x(I_ang);
annul_y = annul_y(I_ang);
annul_i = annul_i(I_ang);
annul_mag = annul_mag(I_ang);
%Edit/K=1 annul_ang, annul_mag

%Smooths data to give a bit less noise...
%Duplicate/O annul_i,annul_i_smth;DelayUpdate
%Smooth 800, annul_i_smth
%AppendToGraph annul_i_smth vs annul_ang
%ModifyGraph lsize(annul_i_smth)=2,rgb(annul_i_smth)=(19729,1,39321)

%Binning the data
%Setting the bins

nbsa = 300;
deltheta = 2*pi/nbsa;
for ii = 1:nbsa
    %binsa(ii) = -pi+(deltheta)*ii;
    binsa(ii) = -pi/2+(deltheta)*ii;
end

% Variable nbsa=100 %number of bins
% Make/O/N=(nbsa) binsa
% Variable c5
% For(c5=0;c5<(nbsa);c5+=1)
% 	binsa[c5]=-pi+(pi/50)*c5
% Endfor

%Filling the bins
binindexa = zeros(1,nbsa);
bintotala = zeros(1,nbsa);

for iii = 1:nbsa-1
    for iv = 1:length(annul_i)
        if annul_ang(iv)>binsa(iii)
			if annul_ang(iv)<binsa((iii + 1))
                binindexa(iii) = binindexa(iii) + 1;
                bintotala(iii) = bintotala(iii) + annul_i(iv);
            end
        end
    end
end

%Averages the data in the bins, and plots it
binaveragea = bintotala./binindexa;
binsa = binsa.';
binaveragea = binaveragea.';

figure(4)
scatter(binsa, binaveragea)
dataTable=[];

% dataTable = table(binsa, binaveragea);
% 
% if saveSet == 1
%     folder = '2D_annular_sector_extraction/Annular/';
%     type = '.dat';
%     path = strcat(folder, fileInput, type);
%     
%     writetable(dataTable, path, 'Delimiter', '\t');
% end

end

% --------------------------------------------------------------------------
% Sector averaging function %
% --------------------------------------------------------------------------

function [bins, binaverage, dataTable] = sector(BBY_data, fileInput, saveSet)
%// SECTOR DATA AVERAGING BASED ON ANGLE
% //This routine extracts 'normal' 1D profiles from defined angular sectors.

% //This section finds the centre of the scattering pattern (if not elsewhere defined)
% //In the absence of anything else, we'll assume they're at 0,0 and defined thus.
% Variable xcent, ycent
xcentre=0;
ycentre=0;

%//Defines the sector location (angle) and width (rads)
sectcent=0; %SET TO 0 FOR VERTICAL, YOU CAN FIGURE OUT HORIZONTAL
sectwid=pi/20; %CHANGE THIS

N = 100; %NUMBER OF POINTS IN ROW/COLUMN (SQUARED INTO GRID)
maxq = 0.2; %MAX Q FOR GRID

% xq = linspace(min(BBY_data(:,1)),max(BBY_data(:,1)),N);
% yq = linspace(min(BBY_data(:,2)),max(BBY_data(:,2)),N);
xq = linspace(-maxq,maxq,N);
yq = linspace(-maxq,maxq,N);

[xxq,yyq] = meshgrid(xq,yq);
zzq = griddata(BBY_data(:,1),BBY_data(:,2),BBY_data(:,3),xxq,yyq);
figure(1)
contourf(xxq,yyq,zzq);

%Calculate the magnitude of distance of each point in graph from centre, and its angle
BBY_data_sqrd = BBY_data.^2;
mag = sqrt((BBY_data_sqrd(:,1) + BBY_data_sqrd(:,2)));

sectang = zeros(length(BBY_data(:,1)),1);
for i = 1:size(BBY_data,1)
if BBY_data(i,2) > 0
    sectang(i) = atan(BBY_data(i,1)./BBY_data(i,2));
elseif BBY_data(i,2) < 0
    sectang(i) = atan(BBY_data(i,1)./BBY_data(i,2)) + pi;
end
end

%//Sets up the angular limits for the sectors as defines

cwmax=sectcent+(0.5*sectwid); 
cwmin=sectcent-(0.5*sectwid);
cwmax_ref=sectcent+(0.5*sectwid)+pi;
cwmin_ref=sectcent-(0.5*sectwid)+pi;
% Print cwmax, cwmin, cwmax_ref, cwmin_ref

%//Plots the sectors on the graph

radi=0.18;

figure(1)
hold on

sectorline1_x = zeros(1,2);
sectorline1_y = zeros(1,2);
sectorline2_x = zeros(1,2);
sectorline2_y = zeros(1,2);
% Make/O/N=2 sectorline1_x, sectorline1_y, sectorline2_x, sectorline2_y
sectorline1_x(1)=radi*sin(sectcent+(0.5*sectwid));
sectorline1_x(2)=-1*(radi*sin(sectcent+(0.5*sectwid)));

sectorline1_y(1)=radi*cos(sectcent+(0.5*sectwid));
sectorline1_y(2)=-1*(radi*cos(sectcent+(0.5*sectwid)));

sectorline2_x(2)=radi*sin(sectcent-(0.5*sectwid));
sectorline2_x(1)=-1*(radi*sin(sectcent-(0.5*sectwid)));

sectorline2_y(2)=radi*cos(sectcent-(0.5*sectwid));
sectorline2_y(1)=-1*(radi*cos(sectcent-(0.5*sectwid)));

plot(sectorline1_x,sectorline1_y, 'LineWidth', 1.5)
hold on
plot(sectorline2_x,sectorline2_y, 'LineWidth', 1.5)
% 
% AppendtoGraph sectorline1_y vs sectorline1_x
% ModifyGraph lsize(sectorline1_y)=2,rgb(sectorline1_y)=(65535,65535,65535)
% AppendtoGraph sectorline2_y vs sectorline2_x
% ModifyGraph lsize(sectorline2_y)=2,rgb(sectorline2_y)=(65535,65535,65535)

%//Sort the original data by angle, to make things easy...

[sectang, sortI] = sort(sectang);
mag = mag(sortI,:);
BBY_data = BBY_data(sortI,:);

%//Selects the data by angular condition using a set of logic gates

seccrop_BBY_data = zeros(size(BBY_data));
seccrop_mag = zeros(size(mag));
seccrop_ang = zeros(size(sectang));

seccrop_BBY_data(cwmin<sectang & sectang<cwmax,:) = BBY_data(cwmin<sectang & sectang<cwmax,:);
seccrop_mag(cwmin<sectang & sectang<cwmax) = mag(cwmin<sectang & sectang<cwmax);
seccrop_ang(cwmin<sectang & sectang<cwmax) = sectang(cwmin<sectang & sectang<cwmax);

seccrop_BBY_data(cwmin_ref<sectang & sectang<cwmax_ref,:) = BBY_data(cwmin_ref<sectang & sectang<cwmax_ref,:);
seccrop_mag(cwmin_ref<sectang & sectang<cwmax_ref) = mag(cwmin_ref<sectang & sectang<cwmax_ref);
seccrop_ang(cwmin_ref<sectang & sectang<cwmax_ref) = sectang(cwmin_ref<sectang & sectang<cwmax_ref);

% Removing large error points above threshold magnitude and intensity

if size(BBY_data,2) == 4
seccrop_BBY_data(seccrop_mag>0.12 & seccrop_BBY_data(:,3)>20 & seccrop_BBY_data(:,4)>10,:) = 0;
seccrop_mag(seccrop_mag>0.12 & seccrop_BBY_data(:,3)>20 & seccrop_BBY_data(:,4)>10) = 0;
seccrop_ang(seccrop_mag>0.12 & seccrop_BBY_data(:,3)>20 & seccrop_BBY_data(:,4)>10) = 0;
end

%//Get rid of zeros

seccrop_BBY_data = seccrop_BBY_data(seccrop_BBY_data(:,3)~=0,:);
seccrop_mag = seccrop_mag(seccrop_mag~=0);
seccrop_ang = seccrop_ang(seccrop_ang~=0);


%//Sorting the data by magnitude (i.e. q)

[seccrop_mag, magIsort] = sort(seccrop_mag);
seccrop_BBY_data = seccrop_BBY_data(magIsort,:);
seccrop_ang = seccrop_ang(magIsort);


%//Plot the raw sector data
figure(2)
scatter(seccrop_mag, seccrop_BBY_data(:,3)) 

%//Binning the data
%//Setting the bins
nbs=100; %//number of bins
scale = 1e-3;
%step = round(log(radi/scale))/nbs;

minMag = min(seccrop_mag);
maxMag = max(seccrop_mag);
% step = round(log((maxMag - minMag)/scale))/nbs;

logMinMag = log10(minMag);
logMaxMag = log10(maxMag);
logLinear = linspace(logMinMag, logMaxMag, nbs);

bins = 10.^logLinear;

% step = maxMag/nbs;
% 
% bins = zeros(nbs,1);
% %bins(1) = minMag;
% for ii = 1:nbs
%     bins(ii) = minMag + (ii-1)*step; 
% end

%Filling the bins
binindex = zeros(1,nbs);
bintotal = zeros(1,nbs);

for iii = 1:nbs-1
    for iv = 1:length(seccrop_BBY_data(:,3))
        if seccrop_mag(iv)>=bins(iii)
			if seccrop_mag(iv)<=bins((iii + 1))
                binindex(iii) = binindex(iii) + 1;
                bintotal(iii) = bintotal(iii) + seccrop_BBY_data(iv,3);
            end
        end
    end
end

%Averages the data in the bins, and plots it
%Binning nans occur when there is a gap in the data larger than the step
%size ie does not meet binning condition. This gives zero intensity and
%binindex -- zero/zero = nan
bintotal = bintotal(bintotal~=0).';
bins = bins(binindex~=0).';
binindex = binindex(binindex~=0).';
binaverage = bintotal./binindex;



figure(3)
loglog(bins, binaverage,'o')

dataTable = table(bins, binaverage);

% prompt = 'would you like to save this data set? Y/N [Y]: ';
% user = input(prompt, 's');
% if isempty(user)
%     str = 'Y';
% end


% if str == 'Y'
%     prompt2 = 'Please input a filename: ';
%     fileInput = input(prompt2, 's');

if saveSet == 1
    
    folder = '';
    type = '.dat';
    path = strcat(folder, fileInput, type);
    
    writetable(dataTable, path, 'Delimiter', '\t');
end

end

