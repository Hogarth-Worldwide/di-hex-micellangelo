%open fixed image
fixed = imread(fixedImageFilename);
load('TxyModded.mat')
TxyModdedIntersted = TxyModded(NucleiNrInterested,:);

%load excel data
NucleiTable =readtable(excelFilename);
CP_Feature = NucleiTable.(CP_excel_feature)(NucleiNrInterested,1);
tilenumbers = NucleiTable.Metadata_TileNumber(NucleiNrInterested,1);

nucleiLocations = round(TxyModdedIntersted + (nFeaturesMovingImage * sizeFeatureInPixels/2));
NucleiLocationOneFeature= round(mod(nucleiLocations,sizeFeatureInPixels));
NucleiLocationOneFeature(NucleiLocationOneFeature ==0) = round(sizeFeatureInPixels);
%create plot




%% Make a gif
fig = figure('Position', get(0, 'Screensize'));
subplot(2,2,2)
imshow(fixed(101:151,101:151))
hold on
XY = [NucleiLocationOneFeature(:,1) NucleiLocationOneFeature(:,2)];
plot(XY(:,1),XY(:,2),'*')

x = XY(:,1);
y = XY(:,2);
a=NucleiNrInterested'; b = num2str(a); c = cellstr(b);
dx = 0.1; dy = 0.1;
text(x+dx, y+dy, c, 'Color',[1 1 1],'FontSize',8);

subplot(2,2,4)
p = plot(1:numel(CP_Feature),CP_Feature,'*'); hold on
p = plot(1:numel(CP_Feature),CP_Feature,'o',"MarkerFaceColor","red");


for i = 1:numel(NucleiNrInterested)
    nucleinr=NucleiNrInterested(i);

    filename= sprintf('Nuclei_BF_NucleiNr%04d_TileNumber%02d.png',nucleinr,tilenumbers(i));
    microscopeImage = imread(fullfile(outputPath,'Microscope_Dapi_BF',filename));
    
    subplot(2,2,[1 3])
    imshow(microscopeImage)
    title(sprintf('%d: NucleiNr %d',i,nucleinr))    

    subplot(2,2,4)
    p.MarkerIndices = i;
    set(gca,'xtick',[1:numel(NucleiNrInterested)],'XTickLabel',NucleiNrInterested)
    xlabel('Nuclei Nr')
    ylabel('Nuclei intergrated intensity');

    frame=getframe(fig);
    im{i} = frame2im(frame);
end
    
filename = "testAnimated.gif"; % Specify the output file name
for idx = 1:numel(NucleiNrInterested)
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,"gif","LoopCount",Inf,"DelayTime",1);
    else
        imwrite(A,map,filename,"gif","WriteMode","append","DelayTime",0.5);
    end
end


%% info about all images in the GIF
figure;
tiledlayout('flow','TileSpacing','compact')
nexttile
imshow(fixed(101:151,101:151))
hold on
XY = [nucleiLocations(:,1) nucleiLocations(:,2)];
plot(XY(:,1),XY(:,2),'*')

x = XY(:,1);
y = XY(:,2);
a=NucleiNrInterested'; b = num2str(a); c = cellstr(b);
dx = 0.1; dy = 0.1;
text(x+dx, y+dy, c, 'Color',[1 1 1]);

nexttile
plot(1:numel(CP_Feature),CP_Feature,'*')
set(gca,'xtick',[1:numel(NucleiNrInterested)],'XTickLabel',NucleiNrInterested)
xlabel('Nuclei Nr')
ylabel('Nuclei intergrated intensity');

for i = 1:numel(NucleiNrInterested)
    nexttile
    nucleinr=NucleiNrInterested(i);
    % get the original dapi+BF
    filename= sprintf('Nuclei_BF_NucleiNr%04d_TileNumber%02d.png',nucleinr,tilenumbers(i));
    microscopeImage = imread(fullfile(outputPath,'Microscope_Dapi_BF',filename));

    imshow(microscopeImage)
    title(sprintf('%d\n NucleiNr %04d\n %f',i,nucleinr,CP_Feature(i)))
end



