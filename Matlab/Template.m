classdef Template < handle
    %--------------
    % Short description
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        TYPE IN
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
        function this = Template(param)
            this.temp_property = param;
        end
        %Getters
        function param = getTempProperty(this)
            param = this.temp_property;
        end
    end
    %--------------
    %Private Methods
    %--------------
    methods (Access = private)
    end  
end