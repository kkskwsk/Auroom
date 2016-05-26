classdef Dsp
    %DSP operations module
    
    properties
    end
    
    methods (Access = 'public', Static = true)
        function result = filter(soundBuffer, filter)
            if (1 == filter.getCoeffsA())
                result = Dsp.freqDomainConv(soundBuffer, filter.getCoeffsB());
            else
                result = filter(filter.getCoeffsB(), filter.getCoeffsA(), soundBuffer);
            end
        end
        
        function result = timeDomainConv(s, h)
            result = conv(s, h);
        end
        
        %cyclic (FFT) convolution
        function result = freqDomainConv(s, h)
            sLength = length(s);
            hLength = length(h);
            
            %Append zeros in the end for the same length (cyclic
            %convolution)
            s = [s; zeros(hLength - 1, 1)];
            h = [h; zeros(sLength - 1, 1)];
            
            s_spk = fft(s);
            h_spk = fft(h);
            
            result_spk = s_spk .* h_spk;
            
            result = ifft(result_spk);
        end
        
        function buffer = addBuffers(a, b)
            len1 = length(a);
            len2 = length(b);
            if len1 ~= len2
                if len2 > len1
                    a = padarray(a, [len2-len1 0], 0, 'post');
                else
                    b = padarray(b, [len1-len2 0], 0, 'post');
                end
            end
            
            buffer = a + b;
        end
        
    end
end

