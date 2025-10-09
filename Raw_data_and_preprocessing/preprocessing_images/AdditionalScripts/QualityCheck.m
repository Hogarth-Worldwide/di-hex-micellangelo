% bad allignments but high score ranks = [164, 266]
% with their corresponding nucleiNR    = [292, 619]
%open saved variables
peakcorr = open('peakcorr.mat').peakcorr;
ssimval = open('ssimval.mat').ssimval;
Txy = open('TxyModded.mat').TxyModded;

%open CP Excel
NucleiTable =readtable(excelFilenameNucleiRemoved);
tilenumbers = NucleiTable.Metadata_TileNumber;

%% peak correlation and SSIM

normPeak = normalize(peakcorr,'range');
normSSIM = normalize(ssimval,'range');
SSIM_peak = normSSIM + normPeak;

[peakcorrSorted, idxPeakcorr] = sort(normPeak,'descend');
[SSIMsorted, idxSSIM] = sort(normSSIM,'descend');
[SSIM_peakSorted, idxSSIM_peak] = sort(SSIM_peak,'descend');

scoreVal = [peakcorrSorted SSIMsorted SSIM_peakSorted]; % sorted by rank
scoreID = [idxSSIM_peak idxSSIM idxSSIM_peak]; %sorted by Rank

score=zeros(numel(idxPeakcorr),1);
for i = 1 : numel(idxPeakcorr)
    score(i) = abs(i - find(idxSSIM(i)==idxPeakcorr));
end



if not(round(cutoff_low_quality) == cutoff_low_quality)
    cutoff_low_quality = round(cutoff_low_quality* numel(idxSSIM_peak));
end

nucleiNRbyRank = idxSSIM_peak(1:cutoff_low_quality);
% sortedimprovedIDX = sort(improvedIDX);
TimprovedByRank = Txy(nucleiNRbyRank,:);


%% plot quality

if plots ==1
    figure; subplot(1,3,1)
    plot(1:numel(idxPeakcorr),peakcorrSorted,'*')
    title("PeakCorrelation sorted");xlabel('rank');ylabel('peakCorrelation')

    subplot(1,3,2)
    plot(1:numel(idxSSIM),SSIMsorted, '*')
    title("SSIMsorted");xlabel('rank');ylabel('SSIM')

    subplot(1,3,3)
    plot(1:numel(idxSSIM_peak),SSIM_peakSorted, '*')
    title("Peak + SSIM sorted");xlabel('rank');ylabel('SSIM')

    figure;
    plot(1:numel(idxSSIM),score,'*')
    title("Difference in indices");xlabel('idx idxSSIM');ylabel('abs(idx idxSSIM - idx idxpeakCorrelation)')
end

%%
if overwrite == 1;
    save(fullfile(inputPath,'MatlabSavedVariables','TimprovedByRank'), 'TimprovedByRank')
    save(fullfile(inputPath,'MatlabSavedVariables','nucleiNRbyRank'), 'nucleiNRbyRank')

    in =[pwd '\Output\Phasecorrelation\overlay'];
    out =[pwd '\Output\QualityCheck\PeakCorrelation'];
    A =dir( fullfile(in, '*.png') );
    fileNames = { A.name };
    for i = 1 : numel( idxPeakcorr )
        newName = fullfile(out, sprintf( 'peakCorrelationRank%04d_nucleinr%04d.png', i, idxPeakcorr(i)));
        copyfile(fullfile(in, fileNames{ idxPeakcorr(i) }), newName);
    end


    [SSIMsorted, idxSSIM] = sort(ssimval,'descend');
    in =[pwd '\Output\Phasecorrelation\overlay'];
    out =[pwd '\Output\QualityCheck\SSIM'];
    A =dir( fullfile(in, '*.png') );
    fileNames = { A.name };
    for i = 1 : numel( idxSSIM )
        newName = fullfile(out, sprintf( 'SSIMrank%04d_nucleinr%04d.png', i, idxSSIM(i)));
        copyfile( fullfile(in, fileNames{ idxSSIM(i) }), newName );
    end


    in =[pwd '\Output\Phasecorrelation\overlay'];
    out =[pwd '\Output\QualityCheck\SSIM+PeakCorrelation'];
    A =dir( fullfile(in, '*.png') );
    fileNames = { A.name };
    for i = 1 : numel( idxSSIM_peak )
        newName = fullfile(out, sprintf( 'peak_SSIMRank%04d_nucleinr%04d.png', i, idxSSIM_peak(i)));
        copyfile( fullfile(in, fileNames{ idxSSIM_peak(i) }), newName );
    end

    in =[pwd '\Output\Phasecorrelation\reconstruction_channels'];
    out =[pwd '\Output\QualityCheck\QualityCheckPassed'];
    A =dir( fullfile(in, '*.mat') );
    fileNames = { A.name };
    for i = 1 : numel( nucleiNRbyRank )
        try
            nucleiNR = nucleiNRbyRank(i);
            
            newName = fullfile(out, sprintf( 'reconstruction_NucleiNr%04d.png.mat', nucleiNR));
            copyfile( fullfile(in, sprintf("reconstruction_NucleiNr%04d_TileNumber%02d.png.mat", nucleiNR, tilenumbers(nucleiNR) )), newName );
        catch
            fprintf('could not copy nuclei nr %04d\n', nucleiNR)
        end
    end



end

