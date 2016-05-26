classdef Line2d < handle
    %--------------
    % Short description
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        originVertex;
        endVertex;
        normalVector;
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
        function this = Line2d(originVertex, endVertex, color)
            if (nargin ~= 0)
                this.originVertex = originVertex;
                this.endVertex = endVertex;
                this.normalVector = this.calcNormal();
                this.color = color;
            end
        end
        
        function initWithAngleLength(this, originVertex, angle, length, color)
            endX = originVertex.getX() + length * cosd(angle);
            endY = originVertex.getY() + length * sind(angle);
            this.endVertex = Vec2d(endX, endY);
            this.originVertex = originVertex;
            this.normalVector = this.calcNormal();
            this.color = color;
        end
        
        function normalVector = calcNormal(this)
            subtr = this.endVertex - this.originVertex;
            rX = subtr.getY();
            rY = -subtr.getX();
            length = sqrt(rX^2 + rY^2);
            normalVector = Vec2d(rX/length, rY/length);
        end
        
        function draw(this, drawing2dContext)
            Line2d.validateInput(drawing2dContext);
            shape = insertShape(drawing2dContext.getCanvas, 'line', ...
                                [this.originVertex.getY(), ...
                                 this.originVertex.getX(), ...
                                 this.endVertex.getY(),    ...
                                 this.endVertex.getX()],   ...
                                 'Color', this.color,      ...
                                 'LineWidth', drawing2dContext.getLineWidth());
            drawing2dContext.setCanvas(shape);
        end
        %Getters
        function originVertex = getOriginVertex(this)
            originVertex = this.originVertex;
        end
        function endVertex = getEndVertex(this)
            endVertex = this.endVertex;
        end
        function normalVector = getNormalVector(this)
            normalVector = this.normalVector;
        end
        function length = getLength(this)
            translatedToOrigin = this.endVertex - this.originVertex;
            length = sqrt(translatedToOrigin.getX()^2 + translatedToOrigin.getY()^2); 
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