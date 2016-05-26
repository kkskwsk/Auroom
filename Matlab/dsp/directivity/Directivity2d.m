classdef Directivity2d < handle
    properties (GetAccess = 'private', SetAccess = 'private')
        filtersMap;
    end
    
    methods (Access = 'public')
        function this = Directivity2d(type)
            if strcmp(type, 'hrtf')
            
            end
        end
        
        function filter = getFilter(this, angle)
            filter = 
        end
    end
    
    methods (Access = private)
    end  
end