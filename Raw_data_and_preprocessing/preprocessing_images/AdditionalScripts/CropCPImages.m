%% Create selected (2000 x 2000 pixels) images for CP

includedTiles = 1:numberOfTiles;
includedTiles(ismember(includedTiles, excludedTiles))=[];


for i = 1:numel(channelNames)

    filename = sprintf(rawImageFileName,string(channelNames(i)));

    t = Tiff(filename);
    imageData = read(t);
    imageNorm = uint16(65535*mat2gray(imageData));

    for j =1:numel(includedTiles)
        currentTile = includedTiles(j);
        [NW_xx, NW_yy]=NW_corner_CPTile(currentTile,sizeImage,numberOfTiles);

        tempImage = imageData(NW_yy:NW_yy + sizeImage-1,...
                              NW_xx: NW_xx + sizeImage-1);
        
        path=fullfile(inputPath,'CP_input_images');
        filename=sprintf(croppedImageFilename,string(channelNames(i)),currentTile,NW_xx,NW_yy);
        SaveImagesInPath(tempImage,path,filename)

    end

end
