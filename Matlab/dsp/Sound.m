classdef Sound < handle
    properties(GetAccess = 'private', SetAccess = 'private')
        buffer;
        sampleRate;
        bitsPerSample
    end
    
    methods (Access = 'public')
        function this = Sound(filename, bitsPerSample, buffer, sampleRate)
            if filename ~= 0 
                [this.buffer,this.sampleRate] = audioread(filename);
                this.buffer = this.buffer/(max(max(this.buffer)));
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
                soundsc(this.buffer, this.sampleRate, this.bitsPerSample);
            else
                sound(this.buffer, this.sampleRate, this.bitsPerSample);
            end
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