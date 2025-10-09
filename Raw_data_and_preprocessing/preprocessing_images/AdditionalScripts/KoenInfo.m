ActinTable =readtable(excelFilename);
tilenumbers = ActinTable.Metadata_TileNumber;
NW_XX = ActinTable.Metadata_NW_XX;
NW_YY = ActinTable.Metadata_NW_YY;
locationActin =round([ActinTable.Location_Center_X ActinTable.Location_Center_Y]);
locationActinNotRounded =[ActinTable.Location_Center_X ActinTable.Location_Center_Y];
xboundmin = ActinTable.AreaShape_BoundingBoxMinimum_X;
xboundmax = ActinTable.AreaShape_BoundingBoxMaximum_X;
yboundmin = ActinTable.AreaShape_BoundingBoxMinimum_Y;
yboundmax = ActinTable.AreaShape_BoundingBoxMaximum_Y;
amountcells = numel(NW_XX);




xbound = xboundmax-xboundmin;
ybound = yboundmax-yboundmin;
% dx = ceil(xbound/2);
% dy = ceil(ybound/2);
% x=temp_loc_nuc(1);y=temp_loc_nuc(2);
% imageNuclei=imageNormDAPI(y-dy:y+dy,x-dx:x+dx);

figure;
tiledlayout('flow')
nexttile
histfit(xbound)
xlabel('X pixels Boundingbox')
ylabel('n')
title('Xbound')
xlim([0 800])
ylim([0 100])

nexttile
boxplot(xbound)
xlabel(string(amountcells))
ylabel('X pixels Boundingbox')
title('Xbound')
ylim([0 1000])

nexttile
histfit(ybound)
xlabel('Y pixels Boundingbox')
ylabel('n')
title('Ybound')
xlim([0 800])
ylim([0 100])

nexttile
boxplot(ybound)
xlabel(string(amountcells))
ylabel('Y pixels Boundingbox')
title('Ybound')
ylim([0 1000])

figure;
scatter(xbound,ybound)
xlabel('xbound pixels')
ylabel('ybound pixels')
hold on
line([0,400],[400,400])
line([400,400],[0,400])
