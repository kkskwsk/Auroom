sourceDirectoriesToAdd = [{'dsp'}, {'geometry'}, {'scene'}, {'scene/room'}, {'scene/transducer'}, {'scene/transducer/receiver'}, {'scene/transducer/source'}, {'simulation'}];
multimediaDirectoriesToAdd = [{'../../multimedia/used'}];

global directoriesToAdd;
directoriesToAdd = cat(2, sourceDirectoriesToAdd, multimediaDirectoriesToAdd);

for i = 1:length(directoriesToAdd)
    addpath(directoriesToAdd{i});
end