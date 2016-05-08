classdef Drawing2dContext < handle
    %--------------
    %This is a context class for drawing the scene.
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        canvas;
        lineWidth;
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
        function this = Drawing2dContext(canvasSizeX, canvasSizeY, lineWidth)
            if ~(isnumeric(canvasSizeX) && isnumeric(canvasSizeY) && isnumeric(lineWidth))
                error('Input values must be numeric.')
            end
            this.canvas = ones(canvasSizeX, canvasSizeY);
            this.lineWidth = lineWidth;
        end
        
        %Getters
        function canvas = getCanvas(this)
            canvas = this.canvas;
        end
        function lineWidth = getLineWidth(this)
            lineWidth = this.lineWidth;
        end
        %Setters
        function setCanvas(this, canvas)
            this.canvas = canvas;
        end
    end
    %--------------
    %Private Methods
    %--------------
    
end
