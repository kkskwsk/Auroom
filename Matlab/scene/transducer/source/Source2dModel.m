classdef Source2dModel < handle
    %--------------
    % Short description
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        positionVector;
        shape;
        directionAngle; %in degrees
        realSize;
        soundPowerLevel;
        directivityFactor;
        numberOfParticles;
        particles;
        %directivity;
        %freqResponse;
        %diaphragmRadius;
        %nearFieldBorder;
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
        function this = Source2dModel(positionVector, directionAngle, realSize, soundPowerLevel, directivityFactor)
            this.positionVector = positionVector;
            this.directionAngle = directionAngle;
            this.realSize = realSize;
            this.soundPowerLevel = soundPowerLevel;
            this.directivityFactor = directivityFactor;
            size = calcSizeInPixels(this.realSize);
            radius = size/2;
            this.shape = Circle2d(positionVector, radius, 'black');
            this.numberOfParticles = 0;
            this.particles = SoundParticle.empty(0);
        end
        
        function draw(this, drawing2dContext)
            Source2dModel.validateInput(drawing2dContext);
            filled = 1;
            this.shape.draw(filled, drawing2dContext);
            directionLine = Line2d();
            directionLine.initWithAngleLength(this.positionVector, ...
                                                this.directionAngle, this.shape.getRadius(), 'black');
            directionLine.draw(drawing2dContext);
        end
        
        function shootParticles(this, simulationContext)
            if this.numberOfParticles == 0
                error('number of particles is not initialized');
            end
            
            FID = fopen('simulation_log.txt', 'a');
            
            tic;
            j = 0;
            quant = 360/this.numberOfParticles;
            angles = 0:(quant):360-quant;
            startEnergy = 1/this.numberOfParticles;
            
            for i = angles 
                j = j+1;
                particle = SoundParticle(this, i, startEnergy); 
                particle.shoot(simulationContext);
                this.particles(j) = particle;
            end
            
            fprintf(FID, 'Number of particles: %d, Simulation time: %f seconds\n', length(this.particles), toc);
            fclose(FID);
        end
        
        function drawRays(this, drawing2dContext)
            tic;
            FID = fopen('simulation_log.txt', 'a');
            for i = 1:length(this.particles)
                this.particles(i).draw(drawing2dContext);
            end
            fprintf(FID, 'Drawing time: %f seconds\n', drawing2dContext.getLineWidth(), toc);
            fclose(FID);
        end
        
        %Getters
        function positionVector = getPositionVector(this)
            positionVector = this.positionVector;
        end
        function directionAngle = getDirectionAngle(this)
            directionAngle = this.directionAngle;
        end
        function particles = getParticles(this)
            particles = this.particles;
        end
        %Setters
        function setNumberOfParticles(this, numberOfParticles)
            this.numberOfParticles = numberOfParticles;
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