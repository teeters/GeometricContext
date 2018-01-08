function spdata = STgetSuperpixelFeatures(image, imsegs)
    [doog_filters, texton_data] = APPgetImageFilters;

    % compute features
    spdata = APPgetSpData(image, doog_filters, texton_data.tim, imsegs);
    [spdata.hue, spdata.sat, tmp] = rgb2hsv(image);