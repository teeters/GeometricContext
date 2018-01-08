function maps = density_kmeans(segDensity, spData, nSegments)
    %kmeans clustering using the learned segdensity matrix as 
    % a distance measure
    features = spData.features;
    nSp = size(features, 1);
    nFeatures = size(features,2);
    nMaps = length(nSegments);
    maps = zeros(nSp, nMaps);
    max_iters = 100;

    for n = 1:length(nSegments)
        num_regions = nSegments(n);
        
        %compute initial centroids
        pind = randperm(nSp);
        centroids = zeros(num_regions, nFeatures);
        for r=1:num_regions
            centroids(r,:) = features(pind(r),:);
        end
        
        mindist = Inf(nSp, 1);
        i=0;
        updating = 1;
        while updating && i<max_iters
            for r=1:num_regions
                %compute distance from centroid to each superpixel
                dists = abs(features - centroids(r,:));
                %now for each feature, add up the log likelihood of sharing a
                %region with the centroid based on distance for that feature
                density_dists = zeros(nSp, 1);
                for f=1:nFeatures
                    density_dists = density_dists+1 - getKdeLikelihood(...
                        segDensity(f).log_ratio, segDensity(f).x, dists(:,f));
                end
                %where this region's density distance is lowest, update cluster
                %labels and mindist
                minidx = density_dists < mindist;
                mindist(minidx) = density_dists(minidx);
                maps(minidx, n) = r;
            end
           
           %now update centroids
           new_centroids = zeros(num_regions, nFeatures);
           for r = 1:num_regions
               new_centroids(r,:) = mean(features(maps(:,n)==r));
           end
           %check for significant change
           if norm(abs(new_centroids-centroids))/norm(centroids) <.001
               updating=false;
           else
               centroids=new_centroids;
               i = i+1;
           end
        end
        %check for empty regions
        pind = randperm(nSp);
        for r=1:num_regions
            if sum(maps(:, n)==r) == 0
                maps(pind(r), n) = r; %just assign it a random superpixel
            end
        end
    end