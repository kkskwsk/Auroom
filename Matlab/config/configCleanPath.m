global directoriesToAdd;

for i = 1:length(directoriesToAdd)
    fprintf(1, 'Removing dir: %s\n', directoriesToAdd{i});
    rmpath(directoriesToAdd{i});
end