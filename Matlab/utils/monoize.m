function monoize(filename)
    [signal, fs] = audioread(filename);
    if size(signal, 2) == 2  
        signal = (signal(:, 1) + signal(:, 2))/2;
        audiowrite('mono.wav', signal, fs);
        disp('Job done!');
    else
        error('The file is not a stereo sound');
    end
end

