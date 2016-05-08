classdef Vec2d < handle
    %--------------
    % Short description
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        x;
        y;
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
        function this = Vec2d(x, y)
            this.x = x;
            this.y = y;
        end
        
        function length = getLength(this)
            length = sqrt(this.x^2 + this.y^2);
        end
        
        function r = plus(vec1, vec2)
            r = Vec2d(vec1.getX() + vec2.getX(), vec1.getY() + vec2.getY());
        end
        
        function r = minus(vec1, vec2)
            r = Vec2d(vec1.getX() - vec2.getX(), vec1.getY() - vec2.getY());
        end
        function r = mtimes(vec1, scalar)
            if isa(scalar, 'Vec2d')
                error('bad input');
            end
            r = Vec2d(vec1.getX() * scalar, vec1.getY() * scalar);
        end
        
        %Getters
        function x = getX(this)
            x = this.x;
        end
        function y = getY(this)
            y = this.y;
        end
        
        %Setters
        function x = setX(this, x)
            this.x = x;
        end
        function y = setY(this, y)
            this.y = y;
        end
    end
    %--------------
    %Private Methods
    %--------------
    methods (Static = true, Access = 'public')
        function angle = calcAngle(vec1, vec2)
            angleRad = acos(dot([vec1.x, vec1.y], [vec2.x, vec2.y])/(vec1.getLength() * vec2.getLength()));
            angle = angleRad * (180/pi);
        end
        function r = dotProd(vec1, vec2)
            r = dot([vec1.x vec1.y], [vec2.x vec2.y]);
        end
        
    end
end