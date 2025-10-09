%% Phase correlation allignment
errors =[];

%load excel table
NucleiTable =readtable(excelFilenameNucleiRemoved);
tilenumbers = NucleiTable.Metadata_TileNumber;
NW_XX = NucleiTable.Metadata_NW_XX;
NW_YY = NucleiTable.Metadata_NW_YY;
locationNuclei =round([NucleiTable.Location_Center_X NucleiTable.Location_Center_Y]);
locationNucleiNotRounded =[NucleiTable.Location_Center_X NucleiTable.Location_Center_Y];
xboundmin = NucleiTable.AreaShape_BoundingBoxMinimum_X;
xboundmax = NucleiTable.AreaShape_BoundingBoxMaximum_X;
yboundmin = NucleiTable.AreaShape_BoundingBoxMinimum_Y;
yboundmax = NucleiTable.AreaShape_BoundingBoxMaximum_Y;
amountNuclei = numel(NW_XX);

%open BF largescale image
t = Tiff(rawBFfilename);
imageData = read(t);
imageNorm = uint16(65535*mat2gray(imageData)); % normalize for vision

%open DAPI largescale image
tDapi = Tiff(DapiLSfilename);
imageDataDAPI = read(tDapi);
imageNormDAPI = uint16(65535*mat2gray(imageDataDAPI)); % normalize for vision


%open fixed image (4x4)
fixed = imread(fixedImageFilename);
fixednorm=uint16(65535*mat2gray(fixed));

%calculate amount of pixels in X and Y direction in 1 feature.
sizeFeatureInPixels= featureSize/resolution;

%allocate memory
ssimval = zeros(amountNuclei,1);
peakcorr= zeros(amountNuclei,1);
Txy= zeros(amountNuclei,2);
TxyModded= zeros(amountNuclei,2);
for i = 1:amountNuclei

    % allignment 3x3 on 4x4
    temp_loc_nuc = [NW_XX(i),NW_YY(i)] + locationNuclei(i,:);

    temp_NW_loc_MovingI = temp_loc_nuc - (nFeaturesMovingImage * sizeFeatureInPixels/2);

    x=temp_NW_loc_MovingI(1);y=temp_NW_loc_MovingI(2);

    moving=imageNorm(y:y + nFeaturesMovingImage * sizeFeatureInPixels,...
        x:x + nFeaturesMovingImage * sizeFeatureInPixels);

    [tform, peakcorr(i,1)] = imregcorr(moving,fixednorm,'translation');
    Rfixed = imref2d(size(fixednorm));
    movingNew = imwarp(moving,tform,OutputView=Rfixed);
    imageImfused = imfuse(fixednorm,movingNew,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);

    % calculate SSIM value
    ssimval(i,1) =ssim(movingNew,fixednorm);
    % translation
    Txy(i,:) = tform.T(3,[1,2]);
    TxyModded(i,:) = round(mod(Txy(i,:),sizeFeatureInPixels)); % put in one feature [-30 75] becomes [20 25]
    TxyModded(TxyModded == 0) = round(sizeFeatureInPixels);% makes sure that [50 43] becomes [50 43] and not [0 43]

    % Dapi images
    % cut out the nuclei
    xbound = xboundmax(i)-xboundmin(i);
    ybound = yboundmax(i)-yboundmin(i);
    dx = ceil(xbound/2);
    dy = ceil(ybound/2);
    x=temp_loc_nuc(1);y=temp_loc_nuc(2);
    imageNuclei=imageNormDAPI(y-dy:y+dy,x-dx:x+dx);


    % pad to 151 x 151 array with black pixels around it
    try
        dx = size(moving,2) - size(imageNuclei,2);
        dy = size(moving,1) - size(imageNuclei,1);
        padNuclei = padarray(imageNuclei, [dy/2 dx/2],0,'both');

        % real microscope image
        ImageDapi_BF = moving + padNuclei*2;

        % reconstruction
        imageReconstructionDapi = uint16(zeros(size(fixednorm)));



        xstart = TxyModded(1); xend = round(xstart + sizeFeatureInPixels * nFeaturesMovingImage);
        ystart = TxyModded(2); yend = round(ystart + sizeFeatureInPixels * nFeaturesMovingImage);
        imageReconstructionDapi(ystart:yend,xstart:xend) = padNuclei;
        imageReconDapiBF = 2*imageReconstructionDapi + fixednorm;

        if plots== 1

            imshow(imageImfused)
            % imshow(imageNuclei)
            % imshow(ImageDapi_BF)

        end

        if overwrite == 1


            filename = sprintf('OverlayTopographies_NucleiNr%04d_TileNumber%02d.png',i,tilenumbers(i));
            path= [outputPath '\Phasecorrelation\overlay\'];
            SaveImagesInPath(imageImfused,path,filename)

            filename = sprintf('Nuclei_NucleiNr%04d_TileNumber%02d.png',i,tilenumbers(i));
            path = [outputPath '\Phasecorrelation\dapi\'];
            SaveImagesInPath(padNuclei,path,filename)

            filename = sprintf('Nuclei_BF_NucleiNr%04d_TileNumber%02d.png',i,tilenumbers(i));
            path = [outputPath '\Phasecorrelation\Microscope_Dapi_BF\'];
            SaveImagesInPath(ImageDapi_BF,path,filename)

            filename = sprintf('reconstruction_NucleiNr%04d_TileNumber%02d.png',i,tilenumbers(i));
            path = [outputPath '\Phasecorrelation\reconstruction\'];
            SaveImagesInPath(imageReconDapiBF,path,filename)



        end

        if mod(i,100) == 0
            disp(string(i)+"/"+string(amountNuclei))
        end

    catch
        errors=[errors i]
    end
end
if overwrite ==1
    save(fullfile(inputPath,'MatlabSavedVariables','Txy'), 'Txy')
    save(fullfile(inputPath,'MatlabSavedVariables','ssimval'), 'ssimval')
    save(fullfile(inputPath,'MatlabSavedVariables','peakcorr'), 'peakcorr')
    save(fullfile(inputPath,'MatlabSavedVariables','TxyModded'), 'TxyModded')
end
errors
