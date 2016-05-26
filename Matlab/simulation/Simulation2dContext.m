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
        filtersMap;
        
        imageSources;
        
        leftEarFilter;
        rightEarFilter;
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
            this.initializeFilters();
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
            this.sourceModel.setNumberOfParticles(2000);
            
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
        
        function start(this)
            this.sourceModel.shootParticles(this);
            this.calcImpulseResponse();
        end
        
        function calcImpulseResponse(this)
            impulse = [1];
            particles = this.sourceModel.getParticles();
            leftChannel = 0;
            rightChannel = 0;
            x=0;
            imageSourcesCounter = 0;
            tic
            for i = 1:length(particles)
                soundParticle = particles(i);
                if soundParticle.isReceived()
                    receptions = soundParticle.getReceptions();
                    for j = 1%:length(receptions)
                        if this.isImageSourceConsidered(soundParticle, j)
                            x = x+1; 
                            continue;
                        end
                        imageSourcesCounter = imageSourcesCounter + 1;
                        imageSource = ImageSource2d(soundParticle, j);
                        this.imageSources = [this.imageSources imageSource];
                        [leftEarImpulseResponse, rightEarImpulseResponse] = this.receiverModel.binauralize(imageSource, impulse, this);
                        leftChannel = Dsp.addBuffers(leftChannel, leftEarImpulseResponse);
                        rightChannel = Dsp.addBuffers(rightChannel, rightEarImpulseResponse);
                    end
                    
               end
            end
            fprintf(1, 'Image sources processing time: %d [sec]\n', toc);
            time = 1/this.settings.simulation.sampleRate:1/this.settings.simulation.sampleRate:length(leftChannel)/this.settings.simulation.sampleRate;
            this.leftEarFilter = Filter(1, leftChannel, this.settings.simulation.sampleRate, 'leftEar');
            this.rightEarFilter = Filter(1, rightChannel, this.settings.simulation.sampleRate, 'rightEar');
            figure();
            plot(time, leftChannel);
            title('Left channel IR');
            figure();
            plot(time, rightChannel);
            title('Right channel IR');
            imageSourcesCounter
        end
        
        function result = isImageSourceConsidered(this, particle, receptionNo)
            reception = particle.getReception(receptionNo);
            receptionWalls = reception.getWalls();
            for i=1:length(this.imageSources)
                if isequal(this.imageSources(i).getWalls(), receptionWalls)
                    result = true;
                    return;
                end
            end
            result = false;
        end
        
        function auralize(this, filename)
            frameLength = this.settings.dsp.frameLength;
            fileReader = dsp.AudioFileReader(filename, 'SamplesPerFrame', frameLength);
            i = info(fileReader);
            if (i.NumChannels ~= 1)
                error('To many channels. Cannot auralize a stereo sound. First convert to mono.');
            end
            
            %TO DO: Check how to choose a device? Speakers/file. It is
            %necessary to choose if the sound should be played or just
            %saved to a new file.
            deviceWriter = audioDeviceWriter('SampleRate', fileReader.SampleRate);
            
            %I assume that both ears' impulse responses are of equal
            %length.
            impulseResponseLength = length(this.leftEarFilter.getCoeffsB());
            
            if (impulseResponseLength ~= 1)
                overlapLength = impulseResponseLength - 1;
                leftEarOverlap  = zeros(overlapLength, 1);
                rightEarOverlap = zeros(overlapLength, 1);
                
                while ~isDone(fileReader)
                    rightEarOverlap = [rightEarOverlap; zeros(frameLength - overlapLength, 1)];
                    leftEarOverlap = [leftEarOverlap; zeros(frameLength - overlapLength, 1)];
                    chunk = step(fileReader);
                    processedLeftEarChunk = Dsp.filter(chunk, this.leftEarFilter);
                    processedRightEarChunk = Dsp.filter(chunk, this.rightEarFilter);
                    chunkToPlay(:,1) = leftEarOverlap(1:frameLength) + processedLeftEarChunk(1:frameLength);
                    chunkToPlay(:,2) = rightEarOverlap(1:frameLength) + processedRightEarChunk(1:frameLength);
                    leftEarOverlap(end+1:end+min(frameLength, overlapLength)) = 0;
                    rightEarOverlap(end+1:end+min(frameLength, overlapLength)) = 0;
                    leftEarOverlap = processedLeftEarChunk(frameLength+1:end) + leftEarOverlap(frameLength+1:end);
                    rightEarOverlap = processedRightEarChunk(frameLength+1:end) + rightEarOverlap(frameLength+1:end);
                    play(deviceWriter, chunkToPlay);
                end
            else
                while ~isDone(fileReader)
                    chunk = step(fileReader);
                    chunkToPlay(:,1) = Dsp.filter(chunk, this.leftEarFilter);
                    chunkToPlay(:,2) = Dsp.filter(chunk, this.rightEarFilter);
                    play(deviceWriter, chunkToPlay);
                end
            end
            
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
        
        function settings = getSettings(this)
            settings = this.settings;
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
            
            this.settings.roomModel.vertices = [[50 100] [1250 100] [1250 1600] [50 1600]]; 
            this.settings.roomModel.lines = [1 2; 2 3; 3 4; 4 1];
            material = Material('wood', [.7 .5 0], this.filtersMap('woodenWall'));
            this.settings.roomModel.materials = [material, ...
                                                material, ...
                                                material, ...
                                                material];
            this.settings.roomModel.medium = 'air';
            
            this.settings.sourceModel.positionX = 1000;
            this.settings.sourceModel.positionY = 1400;
            this.settings.sourceModel.positionVector = Vec2d(this.settings.sourceModel.positionX, this.settings.sourceModel.positionY);
            this.settings.sourceModel.directionAngle = 180; %in degrees
            this.settings.sourceModel.realSize = 0.5; %in meters 
            this.settings.sourceModel.soundPowerLevel = 100; % dB
            this.settings.sourceModel.directivityFactor = 1; %Full sphere radiation (Q = 1)
            

            this.settings.receiverModel.positionX = 200;
            this.settings.receiverModel.positionY = 250;
            this.settings.receiverModel.positionVector = Vec2d(this.settings.receiverModel.positionX, this.settings.receiverModel.positionY);
            this.settings.receiverModel.directionAngle = 40; %in degrees
            this.settings.receiverModel.realSize = 0.4; %in meters
            
            this.settings.simulation.energyThreshold = 5;
            this.settings.simulation.temperature = 21; %Celsius
            this.settings.simulation.speedOfSound = 331.5 + 0.6*this.settings.simulation.temperature; %m/s
            this.settings.simulation.timeThreshold = 3; %seconds
            this.settings.simulation.distanceThreshold = this.settings.simulation.timeThreshold * this.settings.simulation.speedOfSound; 
            this.settings.simulation.sampleRate = 44100;
            
            this.settings.dsp.frameLength = 4096;
            this.checkSceneSanity();
        end
        
        function initializeFilters(this)
            this.filtersMap = containers.Map('KeyType','char','ValueType','any');
            this.filtersMap('woodenWall') = Filter(1, 0.9, 44100, 'wood'); %[0; 0; 0; 0.1; 0.2; 0.3; 0.2; 0.1; 0; 0; 0]
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