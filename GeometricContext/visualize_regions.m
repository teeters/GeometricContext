function rimage = visualize_regions(img, segimage, sp_regions)
    %display each region in the image
    %sp_regions: list with region id for each superpixel
    %segimage: image with superpixel id for each actual pixel
    num_regions = max(sp_regions(:));
    [H,W] = size(segimage);
    
    %create an image of region ids
    rimage = segimage;
    for sp=1:length(sp_regions)
        rimage(segimage == sp) = sp_regions(sp);
    end
    
    image(imfuse(label2rgb(rimage), img, 'Scaling', 'joint'))
    %image(label2rgb(rimage))
        