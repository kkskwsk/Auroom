global directoriesToAdd;
directoriesToAdd = [{'dsp'}, {'geometry'}, {'scene'}, {'scene/room'}, {'scene/transducer'}, ...
    {'scene/transducer/receiver'}, {'scene/transducer/source'}, {'simulation'}];

for i = 1:length(directoriesToAdd)
    addpath(directoriesToAdd{i});
end