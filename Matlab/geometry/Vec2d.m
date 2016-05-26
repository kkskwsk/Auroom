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
        
        function r = eq(vec1, vec2)
            if (vec1.x == vec2.x && vec1.y == vec2.y)
                r = true;
            else
                r = false;
            end
        end
        
        function r = plus(vec1, vec2)
            r = Vec2d(vec1.x + vec2.x, vec1.y + vec2.y);
        end
        
        function r = minus(vec1, vec2)
            r = Vec2d(vec1.x - vec2.x, vec1.y - vec2.y);
        end
        function r = mtimes(vec1, scalar)
            r = Vec2d(vec1.x * scalar, vec1.y * scalar);
        end
        
        function normalizedVector = normalize(this)
            length = sqrt(this.x^2 + this.y^2);
            normalizedVector = Vec2d(this.x/length, this.y/length);
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