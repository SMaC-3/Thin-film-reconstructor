function saveData(T, path, name)

if ~exist(path,'dir')
    mkdir(path);
end

type = '.txt';
full_path = strcat(path, name, type);

if istable(T) == 1
    writetable(T, full_path, 'Delimiter','\t');

elseif iscell(T) == 1
     writecell(T, full_path, 'Delimiter','\t');

else
    disp("Did not recognise as either table or cell. Data not saved")

end
