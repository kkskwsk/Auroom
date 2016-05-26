classdef Material < handle %<attenuator
    %--------------
    % Short description
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        name;
        color;
        filter;
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
        function this = Material(name, color, filter)
            this.name = name;
            this.color = color;
            this.filter = filter;
        end
        
        %Getters
        function name = getName(this)
            name = this.name;
        end
        function color = getColor(this)
            color = this.color;
        end
        function filter = getFilter(this)
            filter = this.filter;
        end
    end
    %--------------
    %Private Methods
    %--------------
end