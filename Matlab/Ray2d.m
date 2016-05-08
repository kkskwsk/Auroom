classdef Ray2d < handle
    properties (GetAccess = 'private', SetAccess = 'private')
        originVector;
        directionVector;
        length;
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
        function this = Ray2d(originVector, directionVector)
            this.originVector = originVector;
            this.directionVector = directionVector;
            this.length = 0;
        end
        
        function dirVector = calcReflectionDirVector(this, line)
            lineNormalVector = line.getNormalVector;
            c1 = -dot([lineNormalVector.getX(), lineNormalVector.getY()], [this.directionVector.getX(), this.directionVector.getY()]);
            dirVector = this.directionVector + (line.getNormalVector() * 2 * c1);
        end
        
        function [isTrue, len] = intersectLineSegment(this, line)
            %if ~isa(line, 'Line2d')
            %    error('Given object is of improper type');
            %end
            
            %A linear equation has to be solved. It is going to be
            %represented with matrices in a form prepared using parametric
            %line equations. Form: Ax = b
            %indexes:
            % o - ray origin vector, d - ray direction vector, 
            % a - origin point of line segment, b- endpoint of line segment
            % Parameters: l - parameter of the line segment equation, if
            % the ray intersects the segment its value is from 0 to 1
            % t - parameter of the ray, it will tell us what the length of
            % the ray has to be.
            %[Xd, Xa-Xb] [l] = [Xa - Xo]
            %[Yd, Ya-Yb] [t]   [Ya - Yo]
            
            Xo = this.originVector.getX();
            Yo = this.originVector.getY();
            Xd = this.directionVector.getX();
            Yd = this.directionVector.getY();
            Xa = line.getOriginVertex().getX();
            Ya = line.getOriginVertex().getY();
            Xb = line.getEndVertex().getX();
            Yb = line.getEndVertex().getY();
            A = [Xd, Xa - Xb; Yd, Ya - Yb];
            B = [Xa - Xo; Ya - Yo];
            params = linsolve(A, B);
            
            if (params(2) < 0) || (params(2) > 1) || (params(1) < 0.0001)
                isTrue = false;
                len = 0;
                return;
            end
            
            isTrue = true;
            len = params(1);
        end
        function [isTrue, len, point] = intersectCircle(this, circle)
            rayOriginCircleCenterVector = circle.getCenter() - this.originVector;
            v = Vec2d.dotProd(rayOriginCircleCenterVector, this.directionVector);
            squaredRadius = circle.getRadius()^2;
            disc = squaredRadius - Vec2d.dotProd(rayOriginCircleCenterVector, rayOriginCircleCenterVector) + v^2;
            if (disc < 0)
                isTrue = false;
                len = 0;
                point = 0;
            else
                d = sqrt(disc);
                len = v - d;
                isTrue = true;
                point = this.originVector + this.directionVector*len;
                disp('Point of incidence:');
                disp(point.getX());
                disp(point.getY());
            end
        end
        
        function draw(this, drawing2dContext)
            Ray2d.validateInput(drawing2dContext);
            Line2d(this.originVector, this.getEndVector(), 'green').draw(drawing2dContext);
        end
        
        %Getters
        function endVector = getEndVector(this)
            endVector = Vec2d(this.originVector.getX() + this.length*this.directionVector.getX(), this.originVector.getY() + this.length*this.directionVector.getY());
        end
        function length = getLength(this)
            length = this.length;
        end
        %Setters
        function setLength(this, length)
            this.length = length;
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