classdef Material < handle %<attenuator
    %--------------
    % Short description
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        name;
        color;
        absorptionCoeff;
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
        function this = Material(name, color, absorptionCoeff)
            this.name = name;
            this.color = color;
            this.absorptionCoeff = absorptionCoeff;
        end
        
        %Getters
        function name = getName(this)
            name = this.name;
        end
        function color = getColor(this)
            color = this.color;
        end
        function absorptionCoeff = getAbsorptionCoeff(this)
            absorptionCoeff = this.absorptionCoeff;
        end
    end
    %--------------
    %Private Methods
    %--------------
end