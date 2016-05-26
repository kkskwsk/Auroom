classdef ImageSource2d < handle
    properties
        positionVector;
        walls;
        wallFilter;
    end
    methods (Access = 'public')
        function this = ImageSource2d(soundParticle, receptionNo)
            reception = soundParticle.getReception(receptionNo);
            lastRay = reception.getLastRay();
            backtraceImageSourceRay = Ray2d(lastRay.getEndVector(), lastRay.getDirectionVector()*(-1));
            backtraceImageSourceRay.setLength(calcSizeInPixels(reception.getDistance()));
            this.positionVector = backtraceImageSourceRay.getEndVector();
            this.walls = reception.getWalls();
            if isequal(this.walls, reception.getWalls())
                1;
            end
            this.calcFilter();
        end
        
        function positionVector = getPositionVector(this)
            positionVector = this.positionVector();
        end
        function walls = getWalls(this)
            walls = this.walls;
        end
        function wallFilter = getWallFilter(this)
            wallFilter = this.wallFilter;
        end
        
    end
    
    methods (Access = 'private')
        function calcFilter(this)
            %consider angle on source
            %neglected because of complicated translations
            resultImpulseResponse = 1;
            
            for i = 1:length(this.walls)
                tempFilter = this.walls(i).getMaterial().getFilter();
                resultImpulseResponse = Dsp.filter(resultImpulseResponse, tempFilter);
            end
            this.wallFilter = Filter(1, resultImpulseResponse, 44100, 'filter');
        end
    end
    
end

