classdef Simulation2dContext < handle
    %--------------
    %This is a context class for the whole simulation.
    %--------------
    properties (GetAccess = 'private', SetAccess = 'private')
        roomModel;
        sourceModel;
        receiverModel;
        drawingContext;
        settings;
        distanceThreshold;
        speedOfSound;
        sound;
        synthesizedSound;
        info;
    end
    %--------------
    %Constants
    %--------------
    properties (Constant = true, GetAccess = 'private')
        DRAWING_CANVAS_SIZE_X = 2000;
        DRAWING_CANVAS_SIZE_Y = 2000;
        DRAWING_LINE_WIDTH = 5;
    end
    %-----------------------------------------------------------
    %--------------
    %Public Methods
    %--------------
    methods (Access = 'public')
        function this = Simulation2dContext()
            %init all properties
            this.info = 'Symulacja testowa Kacpra';
            
            this.initSettings();
            
            this.roomModel = Room2dModel(this.settings.roomModel.vertices, ...
                                         this.settings.roomModel.lines, ...
                                         this.settings.roomModel.materials, ...
                                         this.settings.roomModel.medium);
                                     
            this.sourceModel = Source2dModel(this.settings.sourceModel.positionVector, ...
                                             this.settings.sourceModel.directionAngle, ...
                                             this.settings.sourceModel.realSize, ...
                                             this.settings.sourceModel.soundPowerLevel, ...
                                             this.settings.sourceModel.directivityFactor);
            this.receiverModel = Receiver2dModel(this.settings.receiverModel.positionVector, ...
                                                 this.settings.receiverModel.directionAngle, ...
                                                 this.settings.receiverModel.realSize);
            this.drawingContext = Drawing2dContext(this.settings.drawing.canvasSizeX, ... 
                                                   this.settings.drawing.canvasSizeY, ...
                                                   this.settings.drawing.lineWidth);
            this.distanceThreshold = this.settings.simulation.distanceThreshold;
            this.speedOfSound = this.settings.simulation.speedOfSound;

        end
        
        function drawScene(this)
            this.roomModel.draw(this.drawingContext); % funkcje powinny sie nazywac po prostu "draw"
            this.sourceModel.draw(this.drawingContext);
            this.receiverModel.draw(this.drawingContext);
            this.sourceModel.drawRays(this.drawingContext);
        end
        
        function showScene(this)
            figure();
            imshow(this.drawingContext.getCanvas());
        end
        
        function processGeometry(this)
            this.sourceModel.setNumberOfParticles(2000);
            this.sourceModel.shootParticles(this);
        end
        
        function processSounds(this, filename)
            sound = SoundBuffer(filename, 16, 0, 0);
            this.sound = sound;
            synthesizedBuffer = SoundBuffer(0, sound.getBitsPerSample(), [0], sound.getSampleRate());
            particles = this.sourceModel.getParticles();
            
            for i = 1:length(particles)
                [isSuccess, soundBuffer] = sound.process(particles(i), this);
                if isSuccess
                    synthesizedBuffer = synthesizedBuffer + soundBuffer;
                end
            end
            this.synthesizedSound = synthesizedBuffer;
            figure();
            t=1/synthesizedBuffer.getSampleRate():1/synthesizedBuffer.getSampleRate():length(synthesizedBuffer.getBuffer())/synthesizedBuffer.getSampleRate();
            plot(t, synthesizedBuffer.getBuffer());
            title('Processed audio file');
            ylabel('Sample level');
            xlabel('Time [s]');
        end
        
        function playSynthBuf(this)
            this.synthesizedSound.play(1);
        end
        
        function playOriginalBuf(this)
            this.sound.play(1);
        end
        
        %Getters
        function roomModel = getRoomModel(this)
            roomModel = this.roomModel;
        end
        
        function receiverModel = getReceiverModel(this)
            receiverModel = this.receiverModel;
        end
        
        function distanceThreshold = getDistanceThreshold(this)
            distanceThreshold = this.distanceThreshold;
        end
        
        function speedOfSound = getSpeedOfSound(this)
            speedOfSound = this.speedOfSound;
        end
    end
    %--------------
    %Private Methods
    %--------------
    methods (Access = 'private')
        function initSettings(this)
            this.settings.drawing.canvasSizeX = this.DRAWING_CANVAS_SIZE_X;
            this.settings.drawing.canvasSizeY = this.DRAWING_CANVAS_SIZE_Y;
            this.settings.drawing.lineWidth = this.DRAWING_LINE_WIDTH;
            
            this.settings.roomModel.vertices = [[50 100] [1700 70] [1800 1900] [50 1600] [1900 1000]]; 
            this.settings.roomModel.lines = [1 2; 2 5; 5 3; 3 4; 4 1];
            this.settings.roomModel.materials = [Material('wood', [.7 .5 0], 0), ...
                                                Material('wood', [.7 .5 0], 0), ...
                                                Material('wood', [.7 .5 0], 0), ...
                                                Material('wood', [.7 .5 0], 0), ...
                                                Material('wood', [.7 .5 0], 0)];
            this.settings.roomModel.medium = 'air';
            
            this.settings.sourceModel.positionX = 200;
            this.settings.sourceModel.positionY = 250;
            this.settings.sourceModel.positionVector = Vec2d(this.settings.sourceModel.positionX, this.settings.sourceModel.positionY);
            this.settings.sourceModel.directionAngle = 30; %in degrees
            this.settings.sourceModel.realSize = 0.5; %in meters
            this.settings.sourceModel.soundPowerLevel = 100; % dB
            this.settings.sourceModel.directivityFactor = 1; %Full sphere radiation (Q = 1)
            

            this.settings.receiverModel.positionX = 1200;
            this.settings.receiverModel.positionY = 1300;
            this.settings.receiverModel.positionVector = Vec2d(this.settings.receiverModel.positionX, this.settings.receiverModel.positionY);
            this.settings.receiverModel.directionAngle = 200; %in degrees
            this.settings.receiverModel.realSize = 0.3; %in meters
            
            this.settings.simulation.energyThreshold = 5;
            this.settings.simulation.temperature = 21; %Celsius
            this.settings.simulation.speedOfSound = 331.5 + 0.6*this.settings.simulation.temperature; %m/s
            this.settings.simulation.timeThreshold = 10; %seconds
            this.settings.simulation.distanceThreshold = this.settings.simulation.timeThreshold * this.settings.simulation.speedOfSound; 
            
            this.checkSceneSanity();
        end
        
        function checkSceneSanity(this)
            %(canvas size/room position) sanity
            vertices = this.settings.roomModel.vertices;
            drawingSettings = this.settings.drawing;
            for i = 1:2:length(vertices)
                if (vertices(i) >= drawingSettings.canvasSizeX) || (vertices(i + 1) >= drawingSettings.canvasSizeY)
                    error('Scene sanity check failed. There are vertices placed out of the scene.');
                end
            end
            %(room/source position) sanity
            %TO ADD POINT IN POLYGON CHECK
            %(room/receiver position) sanity
            %(receiver/source position) sanity - near field border
        end
    end
end