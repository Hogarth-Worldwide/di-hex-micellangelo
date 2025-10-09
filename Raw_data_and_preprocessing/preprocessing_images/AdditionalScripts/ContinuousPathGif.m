% initialization
blocksize = 5; % 3 = 3x3, only do uneven squares
GIFstepsize=5; %1 is slow but more continuity


NucleiTable =readtable(excelFilenameNucleiRemoved);
fixed = imread(fixedImageFilename);
fixednorm=uint16(65535*mat2gray(fixed));

TimprovedByRank = open('TimprovedByRank.mat').TimprovedByRank;
nucleiNRbyRank = open('nucleiNRbyRank.mat').nucleiNRbyRank;
TxyOnFixed = open('TxyOnFixed.mat').TxyOnFixed;

NucleiTable =readtable(excelFilenameNucleiRemoved);
tilenumbers = NucleiTable.Metadata_TileNumber;

%filter out nucleiNr manually;
remove = ismember(nucleiNRbyRank,excludedNucleiNR);

TimprovedByRank_excluded = TimprovedByRank;
TimprovedByRank_excluded(remove,:) = [];

nucleiNRbyRank_excluded = nucleiNRbyRank;
nucleiNRbyRank_excluded(remove,:) = [];

TxyOnFixed_excluded = round(TxyOnFixed);
TxyOnFixed_excluded(remove,:) = [];


% nucleiLocations = round(TimprovedByRank_excluded + (nFeaturesMovingImage * sizeFeatureInPixels/2));
% NucleiLocationOneFeature= round(mod(nucleiLocations,sizeFeatureInPixels));
% NucleiLocationOneFeature(NucleiLocationOneFeature ==0) = round(sizeFeatureInPixels);

% nucleiLocation = round(TimprovedByRank_excluded); % + (nFeaturesMovingImage * sizeFeatureInPixels/2));
% NucleiLocationOneFeature=round(TimprovedByRank);

figure('Position', get(0, 'Screensize'))
tiledlayout('flow')
nexttile
imshow(fixednorm); hold on
% scatter(TxyOnFixed_excluded(:,1),TxyOnFixed_excluded(:,2))
[xi,yi] = getpts;
xi= round(xi); yi=round(yi);
scatter(xi,yi,'filled')
%%
interpolatedXY=[];
for i = 1:length(xi)-1
    p1 = [xi(i) yi(i)];
    p2 = [xi(i+1) yi(i+1)];

    dx = abs( round(p2(1)-p1(1)) );
    dy = abs( round(p2(2)-p1(2)) );
    
    dxy = round(norm(p1 - p2));
    if dx >= dy
        xtemp= round(linspace(p1(1),p2(1),dx+1))';
        ytemp= round(linspace(p1(2),p2(2),dx+1))';
    elseif dy>dx
        xtemp=round(linspace(p1(1),p2(1),dy+1))';
        ytemp=round(linspace(p1(2),p2(2),dy+1))';
    end
    interpolatedXY=[interpolatedXY; xtemp ytemp];
    plot(xtemp,ytemp)
end
drawnow
% plot(interpolatedXY(:,1),interpolatedXY(:,2))
%%
pixelsOfInterest=interpolatedXY(1:GIFstepsize:length(interpolatedXY),:);
averageDapiImage = uint16(zeros(149,149,length(pixelsOfInterest)));
maxI = round(length(fixednorm)/sizeFeatureInPixels);
sizeIJ= length(nucleiNRbyRank_excluded);
for i = 1:length(pixelsOfInterest)

    middlexy = pixelsOfInterest(i,:);
    middle = round(blocksize/2);
    idxROI = [];
    for j = 1:blocksize
        nucleiOnPixelx = find(ismember(TxyOnFixed_excluded(:,1), (middlexy(1)-middle+j) )); % finds all values on x value

        for k = 1:blocksize
            idxROI = [idxROI ,nucleiOnPixelx(find(TxyOnFixed_excluded(nucleiOnPixelx,2) == (middlexy(2)-middle +k) ))'];
        end
    end
    

    I = TxyOnFixed_excluded(idxROI,3);
    J = TxyOnFixed_excluded(idxROI,4);
    idxNuclei = idxROI - (sizeIJ*(J-1)+ sizeIJ*(maxI)*(I-1))';

    nucleiNRinROI = nucleiNRbyRank_excluded(idxNuclei);
    stackDapiImage = uint16(zeros(149,149));


    figure('Position', get(0, 'Screensize'),'visible', 'off')

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
    imshow(fixednorm/3)
    hold on
    XY = [TxyOnFixed_excluded(idxROI,1) TxyOnFixed_excluded(idxROI,2)];
    plot(XY(:,1),XY(:,2),'*')
    
    filename=fullfile(outputPath, 'ContinuousGIF/Frames',[gifFilename ,'_',sprintf('Frame%03d ',i) ]);
    saveas(gcf,filename,'png')
end

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



filename = fullfile(outputPath,'ContinuousGIF',[gifFilename '_slow.gif']); % Specify the output file name
for idx = 1:length(pixelsOfInterest)
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,"gif","LoopCount",Inf,"DelayTime",2);
    else
        imwrite(A,map,filename,"gif","WriteMode","append","DelayTime",1);
    end
end

filename = fullfile(outputPath,'ContinuousGIF',[gifFilename '_fast.gif']); % Specify the output file name
for idx = 1:length(pixelsOfInterest)
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,"gif","LoopCount",Inf,"DelayTime",0.5);
    else
        imwrite(A,map,filename,"gif","WriteMode","append","DelayTime",0.25);
    end
end
%%
fig = figure('Position', get(0, 'Screensize'));
tiledlayout('flow')
nexttile
imshow(fixednorm/3); hold on
p = plot(pixelsOfInterest(:,1),pixelsOfInterest(:,2), '*');
    x = pixelsOfInterest(1:3:length(pixelsOfInterest),1);
    y = pixelsOfInterest(1:3:length(pixelsOfInterest),2);
    a=[1:3:length(pixelsOfInterest)]'; b = num2str(a); c = cellstr(b);
    dx = 0.1; dy = 0.1;
    text(x+dx, y+dy, c, 'Color',[1 1 1],'FontSize',7.5);

[minx maxx] = bounds(pixelsOfInterest(:,1));
[miny maxy] = bounds(pixelsOfInterest(:,2));
xlim([minx-10,maxx+10])
ylim([miny-10,maxy+10])

feature1={};
xlength = 1:length(pixelsOfInterest);
meany =[];
err =[];
meany2=[];
err2 =[];
for i = 1:length(pixelsOfInterest)

    middlexy = pixelsOfInterest(i,:);
    middle = round(blocksize/2);
    idxROI = [];
    for j = 1:blocksize
        nucleiOnPixelx = find(ismember(TxyOnFixed_excluded(:,1), (middlexy(1)-middle+j) )); % finds all values on x value

        for k = 1:blocksize
            idxROI = [idxROI ,nucleiOnPixelx(find(TxyOnFixed_excluded(nucleiOnPixelx,2) == (middlexy(2)-middle +k) ))'];
        end
    end
    I = TxyOnFixed_excluded(idxROI,3);
    J = TxyOnFixed_excluded(idxROI,4);
    idxNuclei = idxROI - (sizeIJ*(J-1)+ sizeIJ*(maxI)*(I-1))';
    nucleiNRinROI = nucleiNRbyRank_excluded(idxNuclei);
    localFeatureValue = NucleiTable.AreaShape_Area(nucleiNRinROI,1); %Intensity_MeanIntensity_CorrDNA
    localFeatureValue2 = NucleiTable.Intensity_MeanIntensity_CorrDNA(nucleiNRinROI,1)
    feature1(i) = {localFeatureValue};
    
    y=localFeatureValue;
    meany(i)= mean(y);
    err(i) = std(y',[],2)/sqrt(size(y,1));

    y=localFeatureValue2;
    meany2(i)=mean(y)
    err2(i) = std(y',[],2)/sqrt(size(y,1));
end
    nexttile(2)
    errorbar(meany, err,'*','Color','r','LineStyle','-.'); hold on
    title('Area')
    xlabel('Path NR')
    ylabel('Area in pixels')
    grid on

    nexttile(3)
    nexttile(4)
    errorbar(meany2, err2,'*','Color','r','LineStyle','-.'); hold on
    title('Mean Intensity')
    xlabel('Path NR')
    ylabel('Mean Intensity')
    grid on
% NucleiTable.(CP_excel_feature)(NucleiNrInterested,1);
