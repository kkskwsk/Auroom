classdef Circle2d < handle
    properties (GetAccess = 'private', SetAccess = 'private')
        center;
        radius;
        color;
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
        function this = Circle2d(center, radius, color)
            if (nargin ~= 0)
                this.center = center;
                this.radius = radius;
                this.color = color;
            end
        end
        
        function draw(this, filled, drawing2dContext)
            Circle2d.validateInput(drawing2dContext);
            if (filled)
                shapeType = 'filledCircle';
            else
                shapeType = 'circle';
            end
            shape = insertShape(drawing2dContext.getCanvas, shapeType, ...
                                [this.center.getY(), ...
                                 this.center.getX(),    ...
                                 this.radius],   ...
                                 'Color', this.color,      ...
                                 'LineWidth', drawing2dContext.getLineWidth());
            drawing2dContext.setCanvas(shape);
        end
        %Getters
        function center = getCenter(this)
            center = this.center;
        end
        function radius = getRadius(this)
            radius = this.radius;
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