%% input variables across multiple Matlab files
clear all; close all;

%basic properties
resolution = 0.56e-6; %micrometer / px
featureSize = 27.5e-6; %micrometer
sizeFeatureInPixels= round(featureSize/resolution);
angle=3.85; %degrees

%paths
addpath(genpath(pwd))
inputPath = fullfile(pwd,'Input');
outputPath  = fullfile(pwd,'Output');

% Cell profiler related settings
sizeImage = 2000; % creates 2000 X 2000 pixels

%outlier removal
excelFilenameNuclei = '57Tiles_Nuclei.csv';
excelFilenameActin = '57Tiles_IdentifyActin.csv';
excelFilenameNucleiRemoved = '57Tiles_outliersRemoved_Nuclei.csv';
excelFilenameActinRemoved = '57Tiles_outliersRemoved_Actin.csv';

%Images
rawBFfilename = '2023_01_24_ChannelFITC3,DIA-Ph3,DIA-Ph4,DAPI2,TRITC-1_Seq0000_DIA-Ph3.tif';
DapiLSfilename ='2023_01_24_ChannelFITC3,DIA-Ph3,DIA-Ph4,DAPI2,TRITC-1_Seq0000_DAPI2.tif';
fixedImageFilename = 'FixedPattern 6x6.tif';
channelNames = {'DIA-Ph3','DAPI2', 'FITC3', 'TRITC-1'}; % ChannelNames

%phase correlation
nFeaturesMovingImage = 5;

%manual selections
NucleiNrInterested = [];%[915, 21, 925, 1035, 540, 639, 591, 23, 381, 13,801,193,276 ]; % picks out nuclei for ... script
excludedNucleiNR = [];%[292;619;274;1001;296;654;819;843;837;640;470;301;115;535;302;632;002;1021;196;931;746;990;730;252;851]; % bad phase correlation allignments

meshStepSize = 5; % 5 pixels

% initialize scripts to use in a complete run
run_RotateRawImages = 0;
run_SelectTilesForCP = 0;
run_CropCPImages = 0;
run_outlierRemoval = 1;
run_FixedImagesCropper = 1;
run_PhaseCorrelationAllignment = 1;
run_QualityCheck = 1;
run_NucleiLocationOnFeatures = 0;
run_meshedLocations = 0;
run_ContinuousPathGif= 0;
run_gifSelectedNuclei = 0;
run_reconstruction = 1;
run_heatmap = 0;
run_PCA= 1;
%% Rotate rawimages for visualization purposes

if run_RotateRawImages == 1
    overwrite=0;
    RawImageFileName = '2023_01_24_ChannelFITC3,DIA-Ph3,DIA-Ph4,DAPI2,TRITC-1_Seq0000_%s.tif';
    rotateFilename ='%s_RotatedRaw.tif';
    RotateRawImages
end


%% Select CellProfiler input images (2000x2000 pixels)

if run_SelectTilesForCP ==1
    %filenames are: '2023_01_24_ChannelFITC3,DIA-Ph3,DIA-Ph4,DAPI2,TRITC-1_Seq0000_DIA-Ph3.tif'
    % or            'DIA-PH3_RotatedRaw.tif'
    BFfilename = '2023_01_24_ChannelFITC3,DIA-Ph3,DIA-Ph4,DAPI2,TRITC-1_Seq0000_DIA-Ph3.tif'; 

    SelectTilesForCP
end

%% crop images for CP
if run_CropCPImages == 1
    numberOfTiles = 100; % amount of tiles in SelectTilesForCP
    % excludedTiles = [1:4,7:13,19:22,30:31,40,61,70:71,80:82,89:94,97:100]; %exclude tilenumbers selected from SelectTilesForCP.mat
    % excludedTiles = [1:32,39:42,49:52,59:62,69:100]; % 24 tiles
    excludedTiles = [1:13,19:22,30:31,40:41,50:51,60:61,70:71,80:82,88:100];% 57 tiles

    channelNames = {'DIA-Ph3','DAPI2', 'FITC3', 'TRITC-1'}; % ChannelNames
    
    rawImageFileName = '2023_01_24_ChannelFITC3,DIA-Ph3,DIA-Ph4,DAPI2,TRITC-1_Seq0000_%s.tif'; %sprintf (cropImageFilename,channelNames)
    croppedImageFilename = '2023_01_24_Channel%s_TileNr%03d_LocationXX%05d_YY%05d.TIFF';
    CropCPImages
end

%% outlier removal. Remove miss segmented data from CP

if run_outlierRemoval == 1


    OutlierRemoval
end


%% Fixed Image creator

if run_FixedImagesCropper == 1;
    
    imageFilename = '2023_01_24_ChannelDIA-Ph3_TileNr043_LocationXX04001_YY08001.TIFF';
    amountOffeatures = 10; % value of 10 gives a 10x10 bigspace, So 10 features
    fixedImageCreator
end


%% PhaseCorrelation to acquire spatial information
if run_PhaseCorrelationAllignment == 1
    plots = 1;
    overwrite=1;

    PhaseCorrelationAllignment_BackupRotation
end


%% filter out the best 80%

if run_QualityCheck == 1
    plots =1;
    overwrite=1;

    QualityCheck
end
%% Nuclei location on bigspace and 1 feature
if run_NucleiLocationOnFeatures == 1;

    plots =1;
    overwrite=1;
    
    NucleiLocationOnFeatures
%     NucleiLocationOnFeaturesV2
end
%% features Vs selected nuclei plots
% if run_gifSelectedNuclei == 1
%     
%     CP_excel_feature = 'Intensity_MeanIntensity_CorrDNA';
%     gifSelectedNuclei
% 
% end
%% Gif Meshed locations nuclei
if run_meshedLocations == 1

    MeshedLocations
end
%%
if run_ContinuousPathGif ==1
    gifFilename= 'testJuul';
    ContinuousPathGif

end
%% reconstruction
if run_reconstruction == 1
    
    overwrite = 1;
    Reconstruction
end
%% Principal Components Analysis

if run_PCA == 1

    my_PCA

end


%% heat map
if run_heatmap == 1


%     featureHeatmap
end
