% Code written by Joshua P. King, SMaCLab, Monash University, Australia
% 2022

%   ________  ___      ___       __       ______   ___            __       _______   
%  /"       )|"  \    /"  |     /""\     /" _  "\ |"  |          /""\     |   _  "\  
% (:   \___/  \   \  //   |    /    \   (: ( \___)||  |         /    \    (. |_)  :) 
%  \___  \    /\\  \/.    |   /' /\  \   \/ \     |:  |        /' /\  \   |:     \/  
%   __/  \\  |: \.        |  //  __'  \  //  \ _   \  |___    //  __'  \  (|  _  \\  
%  /" \   :) |.  \    /:  | /   /  \\  \(:   _) \ ( \_|:  \  /   /  \\  \ |: |_)  :) 
% (_______/  |___|\__/|___|(___/    \___)\_______) \_______)(___/    \___)(_______/  
                                                                                   

% SMaCLab website can be found here:
% https://sites.google.com/view/smaclab

%--------------------------------------------------------------------------

function [norm_data, norm_files, num_films] =...
    findFile_2D_norm(film_path, selected)

all_films_struct = dir(fullfile(film_path, '*.txt'));
all_films_cell = struct2cell(all_films_struct).';
all_films_names = all_films_cell(:,1);
file_parts = split(all_films_names, {'-'});
file_num = str2double(file_parts(:,3));


%--------------------------------------------------------------------------
num_films = length(selected);
%--------------------------------------------------------------------------
if selected == 0
    % select all files
    norm_files = all_films_names;
    
else
    [~, selected_I] = ismember(selected, file_num);
    norm_files = all_films_names(selected_I);

end

norm_data = cell(num_films,1);

parfor i =1:num_films
   norm_data{i} = readmatrix(fullfile(film_path,...
       norm_files{i})); 
end

end