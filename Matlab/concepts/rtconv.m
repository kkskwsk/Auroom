clear all
close all

clear all;
clear classes;
close all;

addpath ../config;
configInitPath;

frameLength = 2048;
fileReader = dsp.AudioFileReader('monodp.wav', 'SamplesPerFrame', frameLength);
deviceWriter = audioDeviceWriter('SampleRate', fileReader.SampleRate);
impulseResp = [1;0.5;0.8;0.2;0.8;-0.7;0.1];%[1; zeros(50000,1); 0.7; zeros(50000,1); 0.5];
filter = Filter(1, impulseResp, fileReader.SampleRate, 'costam');
if (length(impulseResp) ~= 1)
    overlapLength = length(impulseResp)-1;
    overlap = zeros(overlapLength, 1);
    
    while ~isDone(fileReader)
        overlap = [overlap; zeros(frameLength - overlapLength, 1)];
        chunk = step(fileReader);
        processedChunk = Dsp.filter(chunk, filter);
        chunkToPlay = overlap(1:frameLength) + processedChunk(1:frameLength);
        overlap(end+1:end+min(frameLength, overlapLength)) = 0;
        overlap = processedChunk(frameLength+1:end) + overlap(frameLength+1:end);
        play(deviceWriter, chunkToPlay);
    end
else
     while ~isDone(fileReader)
        chunk = step(fileReader);
        processedChunk = Dsp.filter(chunk, filter);
        play(deviceWriter, processedChunk);
    end
end