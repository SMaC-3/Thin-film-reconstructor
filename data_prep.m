function [x, y] = data_prep(filename, worksheet)
imgdata = xlsread(fullfile('Interferometry data', filename),worksheet);
numrows = size(imgdata,1);
numcol = size(imgdata, 2);

x = imgdata(2:numrows,1:1);
y = imgdata(2: numrows,2:numcol);
end
 
