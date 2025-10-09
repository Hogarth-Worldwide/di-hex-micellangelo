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

disp('I am here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')


%open DAPI largescale image
tDapi = Tiff(DapiLSfilename);
imageDataDAPI = read(tDapi);
imageNormDAPI = uint16(65535*mat2gray(imageDataDAPI)); % normalize for vision

disp('I am here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')

%open fixed image (4x4)
fixed = imread(fixedImageFilename);
fixednorm=uint16(65535*mat2gray(fixed));

%calculate amount of pixels in X and Y direction in 1 feature.
sizeFeatureInPixels= featureSize/resolution;

%allocate memory
ssimval = zeros(amountNuclei,1);
peakcorr= zeros(amountNuclei,1);
Txy= zeros(amountNuclei,2);
moving =uint16(zeros(251,251,amountNuclei));
for i = 1:amountNuclei

    % allignment 3x3 on 4x4
    temp_loc_nuc = [NW_XX(i),NW_YY(i)] + locationNuclei(i,:);

    temp_NW_loc_MovingI = temp_loc_nuc - (nFeaturesMovingImage * sizeFeatureInPixels/2);

    x=temp_NW_loc_MovingI(1);y=temp_NW_loc_MovingI(2);

    moving(:,:,i)=imageNorm(y:y + nFeaturesMovingImage * sizeFeatureInPixels,...
        x:x + nFeaturesMovingImage * sizeFeatureInPixels);

    [tform, peakcorr(i,1)] = imregcorr(moving(:,:,i),fixednorm,'translation');
    Rfixed = imref2d(size(fixednorm));
    movingNew = imwarp(moving(:,:,i),tform,OutputView=Rfixed);
    imageImfused = imfuse(fixednorm,movingNew,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);

    % calculate SSIM value
    ssimval(i,1) =ssim(movingNew,fixednorm);
    % translation
    Txy(i,:) = tform.T(3,[1,2]);
    

end
%% rotation
x = Txy(1:amountNuclei,1) + round(size(moving,1)/2);
y=Txy(1:amountNuclei,2) + round(size(moving,1)/2);
v=[x,y]';

theta=-angle;
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
x_center = (round(length(fixed)/2));
y_center = (round(length(fixed)/2));
center = repmat([x_center; y_center], 1, length(v));
s = v - center;     % shift points in the plane so that the center of rotation is at the origin
so = R*s;           % apply the rotation about the origin
vo = so + center;

x_rotated = vo(1,:);
y_rotated = vo(2,:);

figure
tiledlayout('flow')

nexttile
imshow(fixednorm)
hold on
scatter(x,y)
% scatter(x_rotated,y_rotated)

nexttile
imshow(imrotate(fixednorm,-theta,'bilinear','crop'));
hold on


TxyModdedRotated = mod([x_rotated;y_rotated],sizeFeatureInPixels)'; % put in one feature [-30 75] becomes [20 25]
TxyModdedRotated(TxyModdedRotated < 0.5) = TxyModdedRotated(TxyModdedRotated < 0.5)+sizeFeatureInPixels;% makes sure that [50 43] becomes [50 43] and not [0 43]

scatter(TxyModdedRotated(:,1),TxyModdedRotated(:,2))
% scatter(TxyModdedRotated(:,1)+100,TxyModdedRotated(:,2)+100)
% scatter(TxyModdedRotated(:,1)+150,TxyModdedRotated(:,2)+100)
% scatter(TxyModdedRotated(:,1)+100,TxyModdedRotated(:,2)+150)
% scatter(TxyModdedRotated(:,1)+150,TxyModdedRotated(:,2)+150)


Xtemp = TxyModdedRotated(:,1) + 2*sizeFeatureInPixels;
Ytemp = TxyModdedRotated(:,2) + 2*sizeFeatureInPixels;
scatter(Xtemp,Ytemp)
% % scatter(Xtemp,Ytemp)
% 
% X=zeros(length(Xtemp),1);
% Y=zeros(length(Ytemp),1);
% for i = 1:size(Xtemp,2)
%     X=[X;Xtemp(:,i)];
%     Y=[Y;Ytemp(:,i)];
% end
% scatter(X,Y)
plot(x_center, y_center,'bo')


%% rotation back
x2 = TxyModdedRotated(1:amountNuclei,1);
y2=TxyModdedRotated(1:amountNuclei,2);


% v=[x2,y2]';
v=[Xtemp,Ytemp]';
theta=angle;
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
x_center = (round(length(fixed)/2));
y_center = (round(length(fixed)/2));
center = repmat([x_center; y_center], 1, length(v));
s = v - center;     % shift points in the plane so that the center of rotation is at the origin
so = R*s;           % apply the rotation about the origin
vo = so + center;

x_rotated = vo(1,:);
y_rotated = vo(2,:);

nexttile
imshow(fixednorm)
hold on
scatter(x,y)

nexttile 
imshow(fixednorm)
hold on

dy=sind(angle)*sizeFeatureInPixels;
dx=cosd(angle)*sizeFeatureInPixels;

scatter(x_rotated,y_rotated)
scatter(x_rotated +dx,y_rotated+dy)
scatter(x_rotated +dx*2,y_rotated+dy*2)
% scatter(x_rotated,y_rotated)
% scatter(x_rotated,y_rotated)

%%
    TxyModded=[x_rotated;y_rotated]';
for i = 1:amountNuclei
    movingtemp = moving(:,:,i);


    % Dapi images
    % cut out the nuclei
    xbound = xboundmax(i)-xboundmin(i);
    ybound = yboundmax(i)-yboundmin(i);
    dx = ceil(xbound/2);
    dy = ceil(ybound/2);
    temp_loc_nuc = [NW_XX(i),NW_YY(i)] + locationNuclei(i,:);
    x=temp_loc_nuc(1);y=temp_loc_nuc(2);
    imageNuclei=imageNormDAPI(y-dy:y+dy,x-dx:x+dx);


    % pad to 151 x 151 array with black pixels around it
    try
        dx = size(movingtemp,2) - size(imageNuclei,2);
        dy = size(movingtemp,1) - size(imageNuclei,1);
        padNuclei = padarray(imageNuclei, [dy/2 dx/2],0,'both');

        % real microscope image
        ImageDapi_BF = movingtemp + (padNuclei*2);
        
        padNucleiSmall = padNuclei( round(length(padNuclei)/2) - sizeFeatureInPixels : round(length(padNuclei)/2) + sizeFeatureInPixels, ...
            round(length(padNuclei)/2) - sizeFeatureInPixels : round(length(padNuclei)/2) + sizeFeatureInPixels);
        
        % reconstruction -- now all channels
        imageReconstructionDapi = uint16(zeros(size(fixednorm)));
        imageReconstructionYap = uint16(zeros(size(fixednorm)));
        imgeReconstructionActin = uint16(zeros(size(fixednorm)));

        % 
        middleX = round(TxyModded(i,1)); middleY = round(TxyModded(i,2));
        xstart = middleX-sizeFeatureInPixels; xend = middleX + sizeFeatureInPixels;
        ystart = middleY-sizeFeatureInPixels; yend = middleY + sizeFeatureInPixels;
        imageReconstructionDapi(round(ystart:yend),round(xstart:xend)) = padNucleiSmall;
        imageReconDapiBF = 2*imageReconstructionDapi + fixednorm;

        if plots== 1

%             imshow(imageImfused)
            % imshow(imageNuclei)
            % imshow(ImageDapi_BF)
%             imshow(imageReconDapiBF)

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
