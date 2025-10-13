%create fixed image
t = Tiff(imageFilename,'r' );
imageData = read(t);
I = imageData;
imageNorm = uint16(65535*mat2gray(I));


imagedata = zeros(ceil(sizeFeatureInPixels)*amountOffeatures);

fig = figure('Position', get(0, 'Screensize'));
tiledlayout('flow')
nexttile
imshow(imageNorm);
title('image to crop from');
impixelinfo;


imagedata = I(YYstart: (YYstart +round(sizeFeatureInPixels)*amountOffeatures),...
(XXstart: (XXstart +round(sizeFeatureInPixels)*amountOffeatures)));
image1 = imagedata;

path=fullfile(inputPath,'FixedImages');
SaveImagesInPath(image1,path,sprintf('FixedPattern %dx%d.tif',amountOffeatures,amountOffeatures))

nexttile
imshow(uint16(65535*mat2gray(image1)))
title(sprintf('fixed image %dx%d feature bigspace',amountOffeatures,amountOffeatures))