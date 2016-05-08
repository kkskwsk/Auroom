function sizeInMeters = calcSizeInMeters(pixels)
    meter2pixelRatio = 1/200; %200 px = 1 m
    sizeInMeters = pixels * meter2pixelRatio;
end