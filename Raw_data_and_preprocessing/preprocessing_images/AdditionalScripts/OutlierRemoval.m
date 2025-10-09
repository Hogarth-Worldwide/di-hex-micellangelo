
%load exceltables

tableNuclei =readtable(excelFilenameNuclei);
tableActin = readtable(excelFilenameActin);


QC_classification = tableNuclei.QC_classification;

% first of all, remove those rows which have been classified as negatives:
idxNegatives = find(strcmp(QC_classification,'negative'));
% Get the length of the array
arrayLength = length(idxNegatives);
% Display the length
disp(['Number of outlier from classification: ', num2str(arrayLength)]);

tableActin([idxNegatives], :) = [];
tableNuclei([idxNegatives], :) = [];

% now continue with the traditional outlier filtering based on area:
actinMajorAxis = tableActin.AreaShape_MajorAxisLength;
actinMinorAxis = tableActin.AreaShape_MinorAxisLength;

xboundmin = tableActin.AreaShape_BoundingBoxMinimum_X;
xboundmax = tableActin.AreaShape_BoundingBoxMaximum_X;
yboundmin = tableActin.AreaShape_BoundingBoxMinimum_Y;
yboundmax = tableActin.AreaShape_BoundingBoxMaximum_Y;

nucleiArea = tableNuclei.AreaShape_Area;
actinArea = tableActin.AreaShape_Area;

actinMeanIntensity = tableActin.Intensity_MeanIntensity_CorrActin;
tilenumbers = tableActin.Metadata_TileNumber;
NW_XX = tableActin.Metadata_NW_XX;
NW_YY = tableActin.Metadata_NW_YY;

xbound = xboundmax-xboundmin;
ybound = yboundmax-yboundmin;

%%
dxArea = actinArea ./ nucleiArea;
% MSE = 1/length(dxArea) * sum(dxArea.^2)
c = linspace(1,1,length(dxArea));

figure('Position', get(0, 'Screensize'));
tiledlayout('flow')
nexttile

scatter(actinMajorAxis,actinMinorAxis,[],log10(dxArea))
xlabel('Cell MajorAxis');ylabel('Cell MinorAxis')
title('MajorAxis vs MinorAxis with colormap: areaCell - areaNuclei')
cb1 = colorbar;
cb1.Label.String = 'log10(dxArea)';
% ylim([0 1200])

nexttile
scatter3(actinMajorAxis,actinMinorAxis,log10(dxArea),[],log10(dxArea))
xlabel('Cell MajorAxis');ylabel('Cell MinorAxis');zlabel('log10(dxArea)')
title('MajorAxis vs MinorAxis vs log10(dxArea)')
cb2 = colorbar;
cb2.Label.String = 'log10(dxArea)';
% set(gca, 'Zscale', 'log')

nexttile
scatter(xbound,ybound,[],log10(dxArea))
xlabel('Cell MajorAxis');ylabel('Cell MinorAxis')
title('MajorAxis vs MinorAxis with colormap: areaCell - areaNuclei')
cb1 = colorbar;
cb1.Label.String = 'log10(dxArea)';


nexttile
scatter3(xbound,ybound,log10(dxArea),[],log10(dxArea))
xlabel('Cell MajorAxis');ylabel('Cell MinorAxis');zlabel('log10(dxArea)')
title('MajorAxis vs MinorAxis vs log10(dxArea)')
cb2 = colorbar;
cb2.Label.String = 'log10(dxArea)';
%%
figure(2)
tiledlayout('flow')
nexttile
plot(log10(dxArea), '*')
xlim([0 length(dxArea)])
xlabel('Nuclei'),ylabel('log10(dxArea)')

nexttile
cla
boxplot(log10(dxArea))

h = findobj('Tag','Lower Whisker');
lowerWhisker = get(h,'YData');
minimumValue = lowerWhisker(1);
%minimumValue = 0.65;

log10Area = log10(dxArea);

idxOutliers= find(log10Area < minimumValue);

[log10AreaSorted idxSorted] = sort(log10Area(idxOutliers));


figure('Position', get(0, 'Screensize'));
tiledlayout('flow','Padding','tight','TileSpacing','tight')
for i = 1:numel(idxSorted)
    currentidx = idxSorted(i);
    idxOutlier=idxOutliers(currentidx);
    tilenumber = tilenumbers(idxOutlier);

    xstart = xboundmin(idxOutlier)+1; xend = xboundmax(idxOutlier)+1;
    ystart = yboundmin(idxOutlier)+1; yend = yboundmax(idxOutlier)+1;
    xbound = xend-xstart;
    ybound = yend-ystart;

    
    path = fullfile(outputPath,'CP_Output_Koen\No_Neighbours\Dapi_BF_Actin_outlines');
    filename = sprintf('ChannelDAPI2_TileNr%03d_LocationXX%05d_YY%05d',tilenumber,NW_XX(idxOutlier),NW_YY(idxOutlier));
    tempI = imread(fullfile(path,filename),'tiff');


%     imshow(tempI)
    tempI = padarray(tempI,[1 1],'post');

    tempCroppedI = tempI(ystart:yend,xstart:xend,:);

    nexttile
    imshow(tempCroppedI)
    title(sprintf('log10(dxArea) %02f',log10(dxArea(idxOutlier))))
end

TnewActin =tableActin ; 
TnewActin([idxOutliers],:) =[];

TnewNuclei=tableNuclei; 
TnewNuclei([idxOutliers],:)=[];

filename = fullfile(outputPath,"CP_Output_Koen","Excel",'outliersRemoved_Actin.csv');
writetable(TnewActin,filename)

filename = fullfile(outputPath,"CP_Output_Koen","Excel",'outliersRemoved_Nuclei.csv');
writetable(TnewNuclei,filename)