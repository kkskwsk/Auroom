classdef Sound < handle
    properties(GetAccess = 'private', SetAccess = 'private')
        buffer;
        sampleRate;
        bitsPerSample
        
        audioPlayer;
    end
    
    methods (Access = 'public')
        function this = Sound(filename, bitsPerSample, buffer, sampleRate)
            if filename ~= 0 
                [this.buffer,this.sampleRate] = audioread(filename);
                if size(this.buffer,2) == 2
                    this.buffer(:,1) = this.buffer(:,1) + this.buffer(:,2);
                    this.buffer(:,2) = [];
                end
                this.buffer = this.buffer/(max(this.buffer)+0.7); %¿eby nie przesterowa³o
                this.bitsPerSample = bitsPerSample;
                this.audioPlayer = audioplayer(this.buffer, this.sampleRate);
                return;
            end
            this.bitsPerSample = 16;
            this.buffer = buffer;
            this.sampleRate = sampleRate;
            this.audioPlayer = audioplayer(this.buffer, this.sampleRate);
        end
        
        function draw(this)
            t=1/this.sampleRate:1/this.sampleRate:length(this.buffer)/this.sampleRate;
            figure();
            plot(t, this.buffer);
            title('Audio file');
            ylabel('Sample level');
            xlabel('Time [s]');
        end
        
        function r = mrdivide(buf1, divider)
            r = Sound(0, 0, buf1.buffer/divider, buf1.getSampleRate());
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
                
            r = Sound(0, buf1.bitsPerSample, buf1.buffer + buf2.buffer, buf1.sampleRate);
        end
        
        function play(this, scale)
            if scale
                %soundsc(this.buffer, this.sampleRate, this.bitsPerSample);
            else
                play(this.audioPlayer);
                %sound(this.buffer, this.sampleRate, this.bitsPerSample);
            end
        end
        
        function pause(this)
            pause(this.audioPlayer);
        end
        function resume(this)
            resume(this.audioPlayer);
        end
        function stop(this)
            stop(this.audioPlayer);
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