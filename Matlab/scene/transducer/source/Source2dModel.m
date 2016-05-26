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
            
            particleIndex = 0;
            quant = 360/this.numberOfParticles;
            angles = 0:(quant):360-quant;
            
            for i = 1:length(angles)
                particle = SoundParticle(this, angles(i));
                this.particles(i) = particle;
            end
            tic
            particlesLocal = this.particles;
            parfor j = 1:length(angles)
                particle = particlesLocal(j);
                particle.shoot(simulationContext);
                particlesLocal(j) = particle;
            end
            
            this.particles = particlesLocal;
            %for i = 1:length(angles)
            %    this.particles(i).shoot(simulationContext);
            %end
            
            %tic
            %for i = angles 
            %    particleIndex = particleIndex + 1;
            %    particle = SoundParticle(this, i);
            %    particle.shoot(simulationContext);
            %    this.particles(particleIndex) = particle;
            %end
            fprintf('time of full processing: %d [sec]\n', toc);
        end
        
        function drawRays(this, drawing2dContext)
            for i = 1:length(this.particles)
                this.particles(i).draw(drawing2dContext);
            end
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