classdef Hrtf < handle
    properties (GetAccess = 'private', SetAccess = 'private')
        leftEarDirectivity;
        rightEarDirectivity;
        azimuthResolution;
    end
    
    methods (Access = 'public')
        function this = Hrtf()
            this.azimuthResolution = 5;
            angles = 0:this.azimuthResolution:355;
            [leftEarFilenames, rightEarFilenames] = Hrtf.createFilenames(angles);
            this.leftEarDirectivity = Directivity2d(angles, leftEarFilenames, 'leftEar');
            this.rightEarDirectivity = Directivity2d(angles, rightEarFilenames, 'rightEear'); 
        end
        
        function [leftEarFilter, rightEarFilter] = getFilters(this, angle)
            roundedAngle = roundToNearestMultiple(angle, this.azimuthResolution);
            if (roundedAngle == 360)
                roundedAngle = 0;
            end
            leftEarFilter = this.leftEarDirectivity.getFilter(roundedAngle);
            rightEarFilter = this.rightEarDirectivity.getFilter(roundedAngle);
            if leftEarFilter.getFs() ~= leftEarFilter.getFs()
                error('Sampling rates don''t match');
            end
        end
    end
    
    methods (Access = 'private', Static = true)
        function [leftEarFilenames, rightEarFilenames] = createFilenames(angles)
            anglesLength = length(angles);
            leftEarFilenames = zeros(anglesLength, length('X0e000a.wav'));
            rightEarFilenames = zeros(anglesLength, length('X0e000a.wav'));
            
            for i = 1:length(angles)
                leftEarFilenames(i,:) = sprintf('L0e%03da.wav', angles(i));
                rightEarFilenames(i,:) = sprintf('R0e%03da.wav', angles(i));
            end
        end
    end
    
end

