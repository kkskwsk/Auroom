clear all;
clear classes;
close all;

addpath ../config;
configInitPath;

simulationContext = Simulation2dContext();
simulationContext.drawScene();
simulationContext.processGeometry();
simulationContext.processSounds('impulse.wav');
rirObject = simulationContext.getSynthBuf();
rirBuffer = rirObject.getBuffer();
rirBuffer = rirBuffer/max(rirBuffer);

signalObject = Sound('jeckyll.wav', 16, 0, 0);
signalBuffer = signalObject.getBuffer();
signalFs = signalObject.getSampleRate();

%Time domain filtering (convolution)
tdfiltered = conv(signalBuffer, rirBuffer);
time = 1/signalFs:1/signalFs:length(tdfiltered)/signalFs;
figure();
plot(time, tdfiltered);
title('Time domain filtered signal');
xlabel('Time [s]');
ylabel('Amplitude');

%Frequency domain filtering (multiplication)
N = length(signalBuffer);
L = length(rirBuffer);
signalBuffer = [signalBuffer; zeros(L-1, 1)];
rirBuffer = [rirBuffer; zeros(N-1, 1)];
rirFft = fft(rirBuffer);
signalFft = fft(signalBuffer);
fdfilteredFft = signalFft .* rirFft;
fdfiltered = ifft(fdfilteredFft);
time = 1/signalFs:1/signalFs:length(fdfiltered)/signalFs;
figure();
plot(time, fdfiltered);
title('Frequency domain filtered signal');
xlabel('Time [s]');
ylabel('Amplitude');

%differences
difference = fdfiltered - tdfiltered;
figure();
plot(time, difference);
title('Difference between results');
xlabel('Time [s]');
ylabel('Amplitude');
