classdef SoundParticle < handle
    properties (GetAccess = 'private', SetAccess = 'private')
        initialSettings;
        rays; %container
        startEnergy;
        distance;
        filters; %container
    end
    %--------------
    %Constants
    %--------------
    %-----------------------------------------------------------
    %--------------
    %Public Methods
    %--------------
    methods (Access = 'public')
        %Constructor
        function this = SoundParticle(sourceModel, angle, startEnergy)
            this.initialSettings.angle = sourceModel.getDirectionAngle() + angle;
            this.initialSettings.originVector = sourceModel.getPositionVector();
            %this.rays(1) = Ray2d(originVector, angle);
            this.distance = 0;
            this.startEnergy = startEnergy;
            this.filters = Filter.empty(0);
        end
        
        function shoot(this, simulation2dContext)
            distanceThreshold = simulation2dContext.getDistanceThreshold();
            
            originVector = this.initialSettings.originVector;
            angle = this.initialSettings.angle;
            directionVector = Vec2d(cos(2*pi*angle/360), sin(2*pi*angle/360));
            
            while (this.distance <= distanceThreshold)
                this.rays = [this.rays Ray2d(originVector, directionVector)];
                ray = this.rays(end);
                [intersectsReceiver, distRec, angle] = SoundParticle.intersectReceiver(ray, simulation2dContext.getReceiverModel());
                [distWall, wall, directionVector] = SoundParticle.reflect(ray, simulation2dContext.getRoomModel());
                
                if intersectsReceiver && (distRec < distWall)
                    ray.setLength(distRec);
                    this.distance = this.distance + calcSizeInMeters(abs(distRec));
                    this.filters(end + 1) = Filter('HRTF'); %pamietac o dodaniu odpowiedniego k¹ta
                    break; 
                end
                
                this.filters(end + 1) = Filter(wall.getMaterial());
                ray.setLength(distWall);
                this.distance = this.distance + calcSizeInMeters(abs(distWall));
                originVector = ray.getEndVector();
            end
            
            if (this.distance > distanceThreshold)
                excess = this.distance - distanceThreshold;
                ray.setLength(ray.getLength() - calcSizeInPixels(excess));
            end
        end
        
        function draw(this, drawing2dContext)
            for i = 1:length(this.rays)
                this.rays(i).draw(drawing2dContext);
            end
        end 
        
        function distance = getDistance(this)
            distance = this.distance;
        end
        function startEnergy = getStartEnergy(this)
            startEnergy = this.startEnergy;
        end
        function lastFilter = getLastFilter(this)
            lastFilter = this.filters(end).getType();
        end
    end
    
    methods(Access = 'private', Static = true) 
        function [minLen, wall, reflectionDirVector] = reflect(ray, roomModel)
            walls = roomModel.getWalls();
            minLen = [];
            for i = 1:length(walls)
                line = walls(i).getLine();
                [isTrue, len] = ray.intersectLineSegment(line);
                if isTrue && (isempty(minLen) || (minLen > len))
                    wall = walls(i);
                    minLen = len;
                end
            end
            
            reflectionDirVector = ray.calcReflectionDirVector(wall.getLine()); 
        end
        
        function [isTrue, len, angle] = intersectReceiver(ray, receiverModel)
            [isTrue, len, point] = ray.intersectCircle(receiverModel.getShape());
            if isTrue
                disp(point.getX());
                disp(point.getY());
                dirVec = point - receiverModel.getShape().getCenter();
                disp('dirvec: \n');
                x = dirVec.getX();
                y = dirVec.getY();
                disp(dirVec.getX());
                disp(dirVec.getY());
                angle = (180/pi) * atan(dirVec.getY()/dirVec.getX());
                if (x < 0)
                    angle = angle + 180;
                end
                angle = angle - receiverModel.getDirectionAngle();
                
                return;
            end
            angle = 0;
        end
        
    end
    %--------------
    %Private Methods
    %--------------
end