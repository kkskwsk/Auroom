classdef SoundBuffer < handle
    properties(GetAccess = 'private', SetAccess = 'private')
        buffer;
        sampleRate;
        bitsPerSample
    end
    
    methods (Access = 'public')
        function this = SoundBuffer(filename, bitsPerSample, buffer, sampleRate)
            if filename ~= 0 
                [this.buffer,this.sampleRate] = audioread(filename);
                this.buffer = this.buffer/(max(this.buffer));
                t=1/this.sampleRate:1/this.sampleRate:length(this.buffer)/this.sampleRate;
                figure();
                plot(t, this.buffer);
                title('Input audio file');
                ylabel('Sample level');
                xlabel('Time [s]');
                
                this.bitsPerSample = bitsPerSample;
                return;
            end
            this.bitsPerSample = 16;
            this.buffer = buffer;
            this.sampleRate = sampleRate;
        end
        
        function r = plus(buf1, buf2)
            len1 = length(buf1.buffer);
            len2 = length(buf2.buffer);
            if len1 ~= len2
                if len2 > len1
                    buf1.buffer = padarray(buf1.buffer, [len2-len1 0], 0, 'post');
                else
                    buf2.buffer = padarray(buf2.buffer, [len1-len2 0], 0, 'post');
                end
            end
                
            r = SoundBuffer(0, buf1.bitsPerSample, buf1.buffer + buf2.buffer, buf1.sampleRate);
        end
        
        function play(this, scale)
            if scale
                soundsc(this.buffer, this.sampleRate, this.bitsPerSample);
            else
                sound(this.buffer, this.sampleRate, this.bitsPerSample);
            end
        end
        
        function [success, soundBuffer] = process(this, soundParticle, simulationContext)
            if ~strcmp(soundParticle.getLastFilter(),'HRTF')
                success = false;
                soundBuffer = 0;
                return;
            end
            distance = soundParticle.getDistance();
                
            %attenuation = -20*log10(distance);
            attFactor = 1/(distance^2);%10^(attenuation/20);
            totalEnergyFactor = soundParticle.getStartEnergy() * attFactor;
            
            delayTime = distance/simulationContext.getSpeedOfSound();
            delaySamples = round(delayTime*this.sampleRate);
            newSoundBuffer = this.delay(delaySamples);
            newSoundBuffer.buffer = newSoundBuffer.buffer*totalEnergyFactor;
            success = true;
            soundBuffer = newSoundBuffer;
        end
        
        function soundBuffer = delay(this, samples)
            delayed = zeros(length(this.buffer)+samples, 1);
            delayed(samples + 1:end, 1) = this.buffer;
            soundBuffer = SoundBuffer(0, this.bitsPerSample, delayed, this.sampleRate);
        end
        
        function sampleRate = getSampleRate(this)
            sampleRate = this.sampleRate;
        end
        function bitsPerSample = getBitsPerSample(this)
            bitsPerSample = this.bitsPerSample;
        end
        function buffer = getBuffer(this)
            buffer = this.buffer;
        end
    end
end