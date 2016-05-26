classdef Wall2d < handle
    %--------------
    % Short description
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        line;
        material;
        id;
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
        function this = Wall2d(originVertex, endVertex, material, id)
            if (nargin > 0)
                this.line = Line2d(originVertex, endVertex, material.getColor());
                this.material = material;
                this.id = id;
            end
        end
        
        function draw(this, drawing2dContext)
            Wall2d.validateInput(drawing2dContext);
            this.line.draw(drawing2dContext);
        end
        
        %Getters
        function line = getLine(this)
            line = this.line;
        end
        function material = getMaterial(this)
            material = this.material;
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