classdef Filter < handle
    %--------------
    % Short description
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        aCoeffs;
        bCoeffs;
        fs;
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
        function this = Filter(aCoeffs, bCoeffs, fs, type)
            this.aCoeffs = aCoeffs;
            this.bCoeffs = bCoeffs;
            this.fs = fs;
            this.type = type;
        end
        %Getters
        function type = getType(this)
            type = this.type;
        end
        
        function aCoeffs = getCoeffsA(this)
            aCoeffs = this.aCoeffs;
        end
        
        function bCoeffs = getCoeffsB(this)
            bCoeffs = this.bCoeffs;
        end
        
        function fs = getFs(this)
            fs = this.fs;
        end
        
    end
    %--------------
    %Private Methods
    %--------------
end