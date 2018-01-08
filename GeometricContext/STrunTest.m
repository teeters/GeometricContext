function [labels, conf_map] = ...
    STrunTest(outdir)
%modified copy of APPtestDirectory for evaluating the system on test_dir


% [labels, conf_map] = APPtestDirectory(segDensity, vClassifier,
%                                   hClassifier, imdir, imsegs, varargin)
%
% Gets the geometry for each image with superpixels given by imsegs.
%
% Input:
%   segDensity: structure giving probability of 2 sp having same label
%   vClassifier: segment classifier for ground/vert/sky
%   hClassifier: segment classifier for subclassses of vert
%   imdir: the image directory 
%   imfn: the image filenames
%   varargin{1} (optional): the output directory for displaying results
% Output:
%   labels: structure containing labeling results for each image
%   conf_map: the likelihoods for each sp for each class for each image
%
% Copyright(C) Derek Hoiem, Carnegie Mellon University, 2005
% Current Version: 1.0  09/30/2005

DO_PARALLEL = 0; % for running multiple parallel processes on directory

load('/home/teeters/Documents/Classes/computer_vision/final_project/GeometricContext/data/classifiers_08_22_2005.mat'); %gives us segment_density, horz_classifier, vert_classifier
segDensity = segment_density;
vClassifier = vert_classifier;
hClassifier = horz_classifier;
load('/home/teeters/Documents/Classes/computer_vision/final_project/GeometricContext/src/dataset/allimsegs2.mat');
all_imsegs = imsegs;
all_names = {imsegs.imname};
fnames = {'alley01.jpg', 'city10.jpg'};
imdir = 'test_dir/images';

for f = 1:length(fnames)
           
    fn = fnames{f};
    %get imsegs data for the file
    imsegs = all_imsegs(strcmp(all_names, fn));
    bn = strtok(fn, '.');  
    
    if ~DO_PARALLEL || ~exist(outdir) || ~exist([outdir '/' bn '.c.mat'])
        
        if ~exist(outdir, 'file')
           mkdir(outdir);
        end

        if DO_PARALLEL % to mark as being processed
            touch([outdir '/' bn '.c.mat']);
        end        
            
        image = im2double(imread([imdir, '/', fn]));
        
%         tmp = im2superpixels(image);
%         tmp.imname = fn;
%         imsegs(f) = tmp;

        if size(image, 3) == 3 

            disp(['processing image ' fn]);

            [labels(f), conf_map(f), maps{f}, pmaps(f)] = ...
                    APPtestImage(image, imsegs, vClassifier, hClassifier, segDensity);               
            true_labels(f).horz_labels = imsegs.hlabels;
            true_labels(f).vert_labels = imsegs.vlabels;
            % for generating context
            [cimages, cnames] = APPclassifierOutput2confidenceImages(imsegs, conf_map(f));
            
            %ST: calculate what percentage of superpixels were labeled
            %correctly
            %err_rates(f) = sum(imsegs(f).labels == labels)/imsegs(f).nseg
            
            if 1

                limage = APPgetLabeledImage(image, imsegs, labels(f).vert_labels, labels(f).vert_conf, ...
                    labels(f).horz_labels, labels(f).horz_conf);          
                imwrite(limage, [outdir, '/', bn, '.l.jpg']);
                imwrite(image, [outdir, '/', fn]);

                % for generating context
                glabels = labels(f);
                gconf_map = conf_map(f);
                gmaps = maps{f};
                gpmaps = pmaps(f);
                save([outdir '/' bn '.c.mat'], 'glabels', 'gconf_map', 'cimages', 'cnames', 'gmaps', 'gpmaps', 'imsegs');

                % make a vrml file
                APPwriteVrmlModel(imdir, imsegs, labels(f), outdir);    
            end

        end

	drawnow;

    end
    
end

%compute accuracy statistics
[horz_acc, vert_acc, horz_confusion, vert_confusion] = ...
    STcheckAccuracy(labels, true_labels)
save([outdir '/err.mat'], 'horz_acc', 'vert_acc', 'horz_confusion', ...
    'vert_confusion', 'labels', 'true_labels');

for f = 1:length(fnames)
    labels(f).imname = fnames{f};
end
