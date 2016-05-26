function delayedBuffer = delay(buffer, samples)
delayedBuffer = zeros(length(buffer) + samples, 1);
delayedBuffer(samples + 1:end, 1) = buffer;
end

