clear all;
clear classes;
close all;

simulationContext = Simulation2dContext();
simulationContext.drawScene();
simulationContext.processGeometry();
simulationContext.processSounds('impulse.wav');
simulationContext.playSynthBuf();
simulationContext.processSounds('drums.wav');
simulationContext.playSynthBuf();
simulationContext.processSounds('gunshot.wav');
simulationContext.playSynthBuf();
simulationContext.processSounds('queen.wav');
simulationContext.playSynthBuf();