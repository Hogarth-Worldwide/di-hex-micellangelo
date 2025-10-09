


nucleiNR = open('nucleiNRbyRank_excluded.mat').nucleiNRbyRank_excluded;

NucleiTable =readtable(excelFilenameNucleiRemoved);
tilenumbers = NucleiTable.Metadata_TileNumber;

f=figure('visible','off');
for i = 1:numel(nucleiNR)

    nucleinr = nucleiNR(i);
    tilenumber = tilenumbers(nucleinr);

    % get the original dapi+BF
    filename= sprintf('Nuclei_BF_NucleiNr%04d_TileNumber%02d.png',nucleinr,tilenumber);
    microscopeImage = imread(fullfile(outputPath,'Phasecorrelation','Microscope_Dapi_BF',filename));

    % get the reconstruction image
    filename= sprintf('reconstruction_NucleiNr%04d_TileNumber%02d.png',nucleinr,tilenumber);
    reconstructionImage = imread(fullfile(outputPath,'Phasecorrelation','reconstruction',filename));

    % get the nuclei channel only
    filename= sprintf('Nuclei_NucleiNr%04d_TileNumber%02d.png',nucleinr,tilenumber);
    dapiImage = imread(fullfile(outputPath,'Phasecorrelation','dapi',filename));

    %get the phase correlation allignment image
    filename= sprintf('OverlayTopographies_NucleiNr%04d_TileNumber%02d.png',nucleinr,tilenumber);
    overlayAllignmentImage = imread(fullfile(outputPath,'Phasecorrelation','overlay',filename));



    subplot(2,2,1)
    imshow(microscopeImage)
    title('Microscopy Image')

    subplot(2,2,2)
    imshow(reconstructionImage)
    title('Reconstructed Image')

    subplot(2,2,3)
    imshow(overlayAllignmentImage)
    title('PhaseCorrelation allignment')

    subplot(2,2,4)
    imshow(dapiImage)
    title('Dapi Channel')
    
    sgtitle(sprintf('NucleiNr%04d', nucleinr))
    if overwrite ==1
        filename = sprintf( 'combinedReconstruction_nucleiNr%04d_tilenumber%02d.png',nucleinr,tilenumber);
        saveas(gcf,fullfile(outputPath,'combinedReconstruction',filename));
    
    end
    i
end





