classdef Room2dModel < handle
    %--------------
    % Two dimensional model of a room where simulation takes place.
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        walls;
        medium;
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
        function this = Room2dModel(vertices, lines, materials, medium)
            Room2dModel.validateConstructorInput(vertices, lines, materials);
            this.walls = Wall2d.empty(0);
            for i = length(lines):-1:1
                originIndex = lines(i, 1);
                originVertex = Vec2d(vertices(2*originIndex - 1), vertices(2*originIndex));
                endIndex = lines(i, 2);
                endVertex = Vec2d(vertices(2*endIndex - 1), vertices(2*endIndex));
                this.walls(i) = Wall2d(originVertex, endVertex, materials(i), i);
            end
            this.medium = medium;
        end
        
        function [minLen, wall, reflectionDirVector] = reflect(this, ray)
            minLen = [];
            for i = 1:length(this.walls)
                [isTrue, len] = ray.intersectLineSegment(this.walls(i).getLine());
                if isTrue && (isempty(minLen) || (minLen > len))
                    wall = this.walls(i);
                    minLen = len;
                end
            end
            
            reflectionDirVector = ray.calcReflectionDirVector(wall.getLine()); 
        end
        
        function draw(this, drawing2dContext)
            Room2dModel.validateDrawInput(drawing2dContext);
            for i = 1:length(this.walls)
                this.walls(i).draw(drawing2dContext);
            end
        end
        %Getters
        function walls = getWalls(this)
            walls = this.walls;
        end
    end
    %--------------
    %Private static Methods
    %--------------
    methods (Static = true, Access = 'private')
        function validateConstructorInput(vertices, lines, materials)
            %if ((length(vertices)/2 ~= length(lines)) || (length(lines) ~= length(materials)))
            %    error('Invalid input arguments');
            %end
        end
        function validateDrawInput(drawing2dContext)
            if ~isa(drawing2dContext, 'Drawing2dContext');
                error('Invalid input argument');
            end
        end
    end
    
    methods(Access = 'public', Static = true) 
        
    end
end