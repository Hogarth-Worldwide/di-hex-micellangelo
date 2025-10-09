% initialization
blocksize = 5; % 3 = 3x3, only do uneven squares
xInterest = [112:2:145]';
yInterest = repmat(106,length(xInterest),1);
pixelsOfInterest = [xInterest, yInterest];

sizeMesh = round(sizeFeatureInPixels/meshStepSize);

fixed = imread(fixedImageFilename);
fixednorm=uint16(65535*mat2gray(fixed));

TimprovedByRank = open('TimprovedByRank.mat').TimprovedByRank;
nucleiNRbyRank = open('nucleiNRbyRank.mat').nucleiNRbyRank;
NucleiTable =readtable(excelFilenameNucleiRemoved);
tilenumbers = NucleiTable.Metadata_TileNumber;

%filter out nucleiNr manually;
remove = ismember(nucleiNRbyRank,excludedNucleiNR);

TimprovedByRank_excluded = TimprovedByRank;
TimprovedByRank_excluded(remove,:) = [];

nucleiNRbyRank_excluded = nucleiNRbyRank;
nucleiNRbyRank_excluded(remove,:) = [];

% nucleiLocations = round(TimprovedByRank_excluded + (nFeaturesMovingImage * sizeFeatureInPixels/2));
% NucleiLocationOneFeature= round(mod(nucleiLocations,sizeFeatureInPixels));
% NucleiLocationOneFeature(NucleiLocationOneFeature ==0) = round(sizeFeatureInPixels);

nucleiLocation = round(TimprovedByRank_excluded); % + (nFeaturesMovingImage * sizeFeatureInPixels/2));
NucleiLocationOneFeature=round(TimprovedByRank);

averageDapiImage = uint16(zeros(151,151,length(pixelsOfInterest)));
for i = 1:length(pixelsOfInterest)
    middlexy = pixelsOfInterest(i,:);
    middle = round(blocksize/2);
    idxROI = [];
    for j = 1:blocksize
        nucleiOnPixelx = find(ismember(NucleiLocationOneFeature(:,1), (middlexy(1)-middle+j) )); % finds all values on x value

        for k = 1:blocksize
            idxROI = [idxROI ,nucleiOnPixelx(find(NucleiLocationOneFeature(nucleiOnPixelx,2) == (middlexy(2)-middle +k) ))'];
        end
    end

    nucleiNRinROI = nucleiNRbyRank_excluded(idxROI);
    stackDapiImage = uint16(zeros(151,151));


    figure('Position', get(0, 'Screensize'))

    T = tiledlayout(1,2);
    t = tiledlayout(T,'flow','TileSpacing','compact');
    sgtitle(sprintf('loc (x,y) = (%d,%d)',middlexy(1), middlexy(2)))

    for j = 1:numel(nucleiNRinROI)
        nucleinr = nucleiNRinROI(j);
        tilenumber = tilenumbers(nucleinr);
        filename= sprintf('Nuclei_NucleiNr%04d_TileNumber%02d.png',nucleinr,tilenumber);
        dapiImage = imread(fullfile(outputPath,'Phasecorrelation','dapi',filename));
        middle = round(length(dapiImage)/2);
        stackDapiImage=stackDapiImage + (dapiImage(middle-round(sizeFeatureInPixels+25):middle+round(sizeFeatureInPixels+25),middle-round(sizeFeatureInPixels+25):middle+round(sizeFeatureInPixels+25)...
            )/ length(nucleiNRinROI)*2);


        nexttile(t)
        imshow(dapiImage)
        title(sprintf('Nuclei NR: %d',nucleinr))
    end
    averageDapiImage(:,:,i) =stackDapiImage;

    t = tiledlayout(T,'flow');
    t.Layout.Tile=2;
    nexttile(t)
    imshow(averageDapiImage(:,:,i))
    title('Stacked average nuclei')


    nexttile(t)
    imshow(fixednorm(1:155,1:155))
    xlim([100 155]);ylim([100 155])
    hold on
    XY = [NucleiLocationOneFeature(:,1) NucleiLocationOneFeature(:,2)];
    plot(XY(:,1),XY(:,2),'*')
    x = XY(:,1);
    y = XY(:,2);
    a=nucleiNRbyRank_excluded; b = num2str(a); c = cellstr(b);
    dx = 0.1; dy = 0.1;
    text(x+dx, y+dy, c, 'Color',[1 1 1],'FontSize',7);
end

nucleiNRbyRank_excluded(idxROI)

%%

fig = figure('Position', get(0, 'Screensize'));
T = tiledlayout(2,2,'TileSpacing','tight','Padding','tight');
t2 = tiledlayout(T,'flow','TileSpacing','tight','Padding','tight');
t2.Layout.Tile=3;
t2.Layout.TileSpan = [1 2];

nexttile(T,2)
imshow(fixednorm/3); hold on
p = plot(pixelsOfInterest(:,1),pixelsOfInterest(:,2), '*');
p = plot(pixelsOfInterest(:,1),pixelsOfInterest(:,2),'o','MarkerFaceColor','red');

for i = 1:size(averageDapiImage,3)
    nexttile(t2)
    imshow(averageDapiImage(:,:,i))
    title(sprintf('frame: %d', i))
end

for i = 1:size(averageDapiImage,3)
    x = pixelsOfInterest(i,1);
    y = pixelsOfInterest(i,2);

    %crops a dapi image from 151x151 to 51 x 51
    middle = round(151/2);
    cropxy = 25; % 25 pixels
    beginCrop = middle - cropxy; endCrop = middle + cropxy;
    croppedDapi = averageDapiImage(beginCrop:endCrop, beginCrop:endCrop , i);


    fixedMeanDapi = fixednorm/3;
    fixedMeanDapi(y-cropxy:y+cropxy,x-cropxy:x+cropxy) = fixedMeanDapi(y-cropxy:y+cropxy,x-cropxy:x+cropxy) + croppedDapi;

    nexttile(T,1)
    imshow(fixedMeanDapi);hold on
%     plot(xmeshcenters(i),ymeshcenters(i), '*','Color','b')
    title(sprintf('loc (x,y) = (%d,%d)',middlexy(1), middlexy(2)))

    nexttile(T,2)
    p.MarkerIndices = i;
    frame=getframe(fig);
    im{i} = frame2im(frame);
    title(sprintf('loc (x,y) = (%d,%d)',middlexy(1), middlexy(2)))

end



filename = "meanNucleiSlowTest.gif"; % Specify the output file name
for idx = 1:length(pixelsOfInterest)
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,"gif","LoopCount",Inf,"DelayTime",2);
    else
        imwrite(A,map,filename,"gif","WriteMode","append","DelayTime",1);
    end
end

filename = "meanNucleiFastTest.gif"; % Specify the output file name
for idx = 1:length(pixelsOfInterest)
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,"gif","LoopCount",Inf,"DelayTime",0.5);
    else
        imwrite(A,map,filename,"gif","WriteMode","append","DelayTime",0.1);
    end
end
