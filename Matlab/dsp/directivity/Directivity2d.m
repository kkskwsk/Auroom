classdef Directivity2d < handle
    properties (GetAccess = 'private', SetAccess = 'private')
        filtersMap;
        type;
    end
    
    methods (Access = 'public')
        function this = Directivity2d(angles, filenames, type)
            this.filtersMap = containers.Map('KeyType','double','ValueType','any');
            for i = 1:length(angles)
                fprintf(1, '%s\n', filenames(i,:));
                this.filtersMap(angles(i)) = audioread(sprintf('%s', filenames(i,:)));
            end
            this.type = type;
        end
        
        function filter = getFilter(this, angle)
            filter = Filter(1, this.filtersMap(angle), 44100, this.type);  
        end
    end
    
    methods (Access = private)
    end  
end