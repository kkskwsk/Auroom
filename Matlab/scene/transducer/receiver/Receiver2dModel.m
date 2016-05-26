classdef Receiver2dModel < handle %mog³oby dziedziczyæ po Transducer
    %--------------
    % Short description
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        positionVector;
        shape;
        directionAngle; %in degrees
        realSize;
        hrtf;
        %freqResponse;
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
        function this = Receiver2dModel(positionVector, directionAngle, realSize)
            this.positionVector = positionVector;
            this.directionAngle = directionAngle;
            this.realSize = realSize;
            size = calcSizeInPixels(this.realSize);
            radius = size/2;
            this.shape = Circle2d(positionVector, radius, 'black');
            tic
            this.hrtf = Hrtf();
            fprintf(1, 'Time of loading HRTF: %d [sec]', toc);
        end
        
        function [isTrue, len, angle] = intersect(this, ray)
            [isTrue, len, point] = ray.intersectCircle(this.shape);
            if isTrue
                angle = this.findRelativeAngle(point);
                return;
            end
            angle = 0;
        end
        
        function angle = findRelativeAngle(this, point)
            dirVec = point - this.getShape().getCenter();
            angle = (180/pi) * atan(dirVec.getY()/dirVec.getX());
            if (dirVec.getX() < 0)
                angle = angle + 180;
            end
            angle = angle - this.getDirectionAngle();
        end
        
        function distance = calcDistanceFromImageSource(this, imageSource)
            imageSourcePosition = imageSource.getPositionVector();
            distance = calcSizeInMeters(Line2d(this.positionVector, imageSourcePosition, 0).getLength());
        end
        
        function [leftEarImpulseResponse, rightEarImpulseResponse] = binauralize(this, imageSource, impulse, simulationContext)
            %filtracja zwi¹zana z odbiciami od œcian
            %tic
            filteredBuffer = impulse * imageSource.getWallFilter().getCoeffsB();
            %filteredBuffer = Dsp.filter(impulse, imageSource.getWallFilter());
            %fprintf(1, 'Przetwarzanie odbicia od œcian: %d [sec]\n', toc);
            
            %dodane opóŸnienie
            %tic
            distance = this.calcDistanceFromImageSource(imageSource);
            delayTime = distance / simulationContext.getSpeedOfSound();
            delaySamples = round(delayTime * simulationContext.getSettings().simulation.sampleRate);
            filteredBuffer = delay(filteredBuffer, delaySamples);
            %fprintf(1, 'Przetwarzanie opóŸnienia: %d [sec]\n', toc);
            
            %filtracja zwi¹zana z przebyt¹ odleg³oœci¹ oraz transmitancj¹
            %oœrodka
            %tic
            attFactor = 1/(distance);
            %filteredBuffer = Dsp.filter(filteredBuffer, getAirFilter(distance));
            filteredBuffer = filteredBuffer.*attFactor;
            %fprintf(1, 'Przetwarzanie propagacji przez medium: %d [sec]\n', toc);
            %filtracja binauralna (HRTF)
            %tic
            imageSourcePositionVector = imageSource.getPositionVector();
            directionVector = this.getPositionVector() - imageSourcePositionVector;
            directionVector = directionVector.normalize();
            ray = Ray2d(imageSourcePositionVector, directionVector); 
            [~, ~, angle] = this.intersect(ray);
            
            angle = angle*(-1);
            if (angle > 360)
                angle = angle - 360;
            end
            
            if angle < 0
                angle = 360 + angle;
            end
            
            [leftEarFilter, rightEarFilter] = this.hrtf.getFilters(angle);
            leftEarImpulseResponse = Dsp.filter(filteredBuffer, leftEarFilter);
            rightEarImpulseResponse = Dsp.filter(filteredBuffer, rightEarFilter);
            %fprintf(1, 'Przetwarzanie binauralne: %d [sec]\n', toc);
        end
        
        function filter = getHrtf(this, imageSource)
            imageSourcePosition = imageSource.getPosition();
            direction = this.getPositionVector() - imageSourcePosition;
            ray = Ray2d(imageSourcePosition, direction.normalize());
            [isTrue, len, angle] = intersectReceiver(this, ray);
            filter = this.hrtf.getFilter(angle);
        end
        
        function draw(this, drawing2dContext)
            Receiver2dModel.validateInput(drawing2dContext);
            filled = 0;
            this.shape.draw(filled, drawing2dContext);
            directionLine = Line2d();
            directionLine.initWithAngleLength(this.positionVector, ...
                                                this.directionAngle, this.shape.getRadius(), 'black');
            directionLine.draw(drawing2dContext);
        end
        %Getters
        function positionX = getPositionX(this)
            positionX = this.positionVector.getX();
        end
        function positionY = getPositionY(this)
            positionY = this.positionVector.getY();
        end
        function positionVector = getPositionVector(this)
            positionVector = this.positionVector;
        end
        function shape = getShape(this)
            shape = this.shape;
        end
        function directionAngle = getDirectionAngle(this)
            directionAngle = this.directionAngle;
        end
        function realSize = getRealSize(this)
            realSize = this.realSize;
        end
    end
    %--------------
    %Private Methods
    %--------------
    methods (Access = 'private', Static = true)
        function validateInput(drawing2dContext)
            if ~isa(drawing2dContext, 'Drawing2dContext')
                error('Invalid input argument');
            end
        end
    end 
    
    methods (Access = 'public', Static = true)
        
    end
end