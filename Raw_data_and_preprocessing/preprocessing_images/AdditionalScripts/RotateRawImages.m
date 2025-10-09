

% open Raw BF image
% t = Tiff(rawBFfilename);
% imageData = read(t);
% imageNorm = uint16(65535*mat2gray(imageData));
% 
% middleLocation = round(length(imageNorm)/2) - 2500;
% getptsSize = 200;
% Igetpts = imageNorm(middleLocation:middleLocation+getptsSize,middleLocation:middleLocation+getptsSize);

fixed = imread(fixedImageFilename);
fixednorm=uint16(65535*mat2gray(fixed));


fig = figure('Position', get(0, 'Screensize'));
tiledlayout('flow','TileSpacing','tight','Padding','tight')
nexttile(1)
Igetpts=fixednorm;
imshow(Igetpts)
[xi,yi] = getpts

%% calculate 3rd point for right-angled triangle

for i = 1:2:length(xi)
    abc = [ xi(i:i+1,:) yi(i:i+1,:) ;xi(i) yi(i+1);xi(i) yi(i)];

    v1=[abc(1,:) - abc(2,:)]';
    v2=[abc(3,:) - abc(2,:)]';
    angle= subspace(v1, v2);
    angle_deg(round(i/2)) = rad2deg(angle);

    nexttile(1)
    line(abc(:,1),abc(:,2),'color','r')
    text(abc(2,1),abc(2,2), string(angle_deg(round(i/2)))+char(176),'color', 'b')
    X=[abc(1,1),abc(1,2);abc(2,1),abc(2,2)];
    d = mod(pdist(X,'euclidean'),sizeFeatureInPixels);
    text(abc(1,1),abc(1,2),string(d),'color', 'b')

end


title('original')

nexttile(2)
imshow(imrotate(Igetpts,mean(angle_deg),'nearest','crop'))
title('Rotated Nearest neighbour')

nexttile(3)
imshow(imrotate(Igetpts,mean(angle_deg),'bilinear','crop'))
title('rotated Bilinear')

[rows, columns, numberOfColorChannels] = size(fixednorm);
hold on;
lineSpacing = sizeFeatureInPixels; % Whatever you want.
for row = 1 : lineSpacing : rows
    line([1, columns], [row, row], 'Color', 'r', 'LineWidth', 1);
end
for col = 1 : lineSpacing : columns
    line([col, col], [1, rows], 'Color', 'r', 'LineWidth', 1);
end
%%

if overwrite ==1
    clear imageData imageNorm
    for i = 1:numel(channelNames)

        % open the rawdata image
        filename = sprintf(RawImageFileName,string(channelNames(i)));
        imgTemp = imread(filename,'tif');
        %rotate image
        imgTemp = imrotate(imgTemp,mean(angle_deg),'bilinear','crop');

        filename = sprintf(rotateFilename,string(channelNames(i)));
        path = fullfile(inputPath,'RawDataRotated');
        SaveImagesInPath(imgTemp,path,filename)

        

    end
end



