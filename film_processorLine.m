%close all

%--------------------------------------------------------------------------
% Import information - USER TO MODIFY
%--------------------------------------------------------------------------

%---Index of files to be procesed------------------------------------------
save_check = 0; % 1 = save info, 0
%= do not save info
%--------------------------------------------------------------------------

%---main branch directory info---------------------------------------------
folder = "/Volumes/T7/Thin films/MultiCam/Xgum/1000ppm_Xgum/1000ppm_Xgum_0p1mMKCl_0p2umF_run9/";

if ~exist(folder,'dir')
    folder = pwd;
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%---Select file manually for film analysis-------------------------
disp('Select the thin film data to analyse (films-plot.txt)');
[film_plot_file, film_plot_path] = uigetfile(strcat(folder,'*.txt'),...
    'Select the thin film data to analyse', 'MultiSelect','on');

if iscell(film_plot_file) == 0
    film_plot_file = {film_plot_file};
end

numFilms = length(film_plot_file);

radius_bar = cell(numFilms,1);
height_bar = cell(numFilms,1);
dr = cell(numFilms,1);
dimpVol = cell(numFilms,1);

for i = 1:numFilms
    
    T_film = readtable(strcat(film_plot_path, film_plot_file{i}));
    file_parts = split(film_plot_file{i},{'-','.'});
    fileNum = num2str(str2num(file_parts{4}));

    radius = T_film.radius_micron_;
    red_film = T_film.red_film;
    blue_film = T_film.blue_film;

    radius_bar{i} = 0.5*(radius(2:end) + radius(1:end-1));
    height_bar{i} = 0.5*(red_film(2:end) + red_film(1:end-1));
    dr{i} = radius(2:end) - radius(1:end-1);

    dimpVol{i}= 2*pi.*radius_bar{i}.*(height_bar{i}/1000).*dr{i};

end