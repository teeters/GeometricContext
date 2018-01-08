function [labels, conf_map, maps, pmaps] = STrunImageTest()
    %get a test image and run APPtestImage on it
    
    %make sure to add data, src and all subfolders to path
    load('classifiers_08_22_2005.mat'); %gives us horz_classifier and vert_classifier
    load('allimsegs2.mat'); %gives us imsegs for all test images
    test_imsegs = imsegs(1);
    test_im = imread(test_imsegs.imname);
    [labels, conf_map, maps, pmaps] = APPtestImage(test_im, test_imsegs, ...
    vert_classifier, horz_classifier, segment_density)