clear all;
clear classes;
close all;

addpath config;
configInitPath;

simulationContext = Simulation2dContext();
simulationContext.drawScene();
simulationContext.showScene();
simulationContext.processGeometry();
simulationContext.processSounds('impulse.wav');
simulationContext.playSynthBuf();
simulationContext.processSounds('jeckyll.wav');
simulationContext.playSynthBuf();
simulationContext.processSounds('gunshot.wav');
simulationContext.playSynthBuf();
%simulationContext.processSounds('queen.wav');
%simulationContext.playSynthBuf();

configCleanPath;
rmpath config;