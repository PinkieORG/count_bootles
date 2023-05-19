% Variables

se1 = strel('disk', 5);
se2 = strel('disk', 10);
se3 = strel('disk', 20);
se4 = strel('disk', 30);

i = imread('images/bottle_crate_12.png');
sz = size(i);

marker = uint8(zeros(sz));
marker(1,:) = 255;
marker(:,1) = 255;
marker(sz(1),:) = 255;
marker(:,sz(2)) = 255;

% For cycle through all the images

for c = 1:24
    input = imread(sprintf("images/bottle_crate_%02d.png", c));

    % First branch
    rev = 255-input;
    ero = imerode(rev, se1);
    marker = min(ero, marker);    
    rec = imreconstruct(marker, ero);
    diff = ero - rec;
    
    dil = imdilate(diff, se1);
    dil_diff = dil - diff;
    clo = imclose(dil_diff, se1);
    
    
    [centers, radii, metric] = imfindcircles(dil_diff, [10,50]);
    im = false(sz);
    for i = 1:size(centers)
        im(uint64(centers(i, 2)), uint64(centers(i, 1))) = true;
    end
    im_dil = imdilate(im, se2);    
    
    % Second branch

    t = graythresh(input);
    thresh = imbinarize(input, t);
    white_caps = imopen(thresh, se3);
    too_big_seed = imopen(white_caps, se4);
    too_big = imreconstruct(too_big_seed, white_caps);
    white_caps = white_caps - too_big;
    
    % Output
    
    output = im_dil + white_caps;
    sprintf('Image:                bottle_crate%02d.png\nNumber of bottles     %2d', c, bwconncomp(output).NumObjects)
end



