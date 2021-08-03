function saveData(T, path, name)

if ~exist(path,'dir')
    mkdir(path);
end

type = '.txt';
full_path = strcat(path, name, type);

writetable(T, full_path, 'Delimiter','\t');

end
