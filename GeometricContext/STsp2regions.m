function maps = STsp2regions(segDensity, spData, nSegments, spatial_weight)
    features = spData.features;
    features(:,21:23) = features(:,21:23) * spatial_weight;
    nMaps = length(nSegments);
    nSp = size(features, 1);
    maps = zeros(nSp, nMaps);
    
    for m=1:nMaps
        %hoiem's algorithm greedily assigns superpixels to clusters
        %based on pairwise affinity, which in turn is based on the
        %city-block distance in feature space. So this should be roughly
        %equivalent
        
        %maps is array with (superpixel_y, superpixel_x, map_index)
        %contains a numeric id for the cluster centroid of each superpixel
        num_clusters = min(nSegments(m), nSp);
        maps(:, m) = kmeans(features, num_clusters, 'Distance', 'cityblock');
    end
end
        