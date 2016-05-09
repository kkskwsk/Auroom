classdef Receiver2dModel < handle %mog³oby dziedziczyæ po Transducer
    %--------------
    % Short description
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        positionVector;
        shape;
        directionAngle; %in degrees
        realSize;
        %directivity;
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
end