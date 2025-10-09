
t = Tiff(BFfilename);
imageData = read(t);
imageNorm = uint16(65535*mat2gray(imageData));



numberOfTiles = floor( size(imageData,1) / sizeImage) ^ 2;
disp('number of tiles:')
disp(numberOfTiles)
tileNumberCells = cellstr(num2str([1:numberOfTiles]'));
xTileNumber = round(sizeImage/2) : sizeImage: sizeImage * sqrt(numberOfTiles);
yTileNumber = xTileNumber;

figure; imshow(imageNorm); hold on
for i = sizeImage:sizeImage:size(imageData,1)
    line([i i],[0 size(imageData,1)])
    line([0 size(imageData,1)], [i i])
end
for i = 1:numel(xTileNumber)
    for j = 1:numel(yTileNumber)
        text(xTileNumber(i),yTileNumber(j),tileNumberCells((j-1)*sqrt(numberOfTiles)+i),'color',[1,1,1])
    end
end






