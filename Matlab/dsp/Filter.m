classdef Filter < handle
    %--------------
    % Short description
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        amplitudeFreq;
        phaseFreq;
        complexTransmitance;
        aCoeffs;
        bCoeffs;
        impulseResponse;
        type;
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
        function this = Filter(type)
            this.type = type;
        end
        %Getters
        function type = getType(this)
            type = this.type;
        end
    end
    %--------------
    %Private Methods
    %--------------
end