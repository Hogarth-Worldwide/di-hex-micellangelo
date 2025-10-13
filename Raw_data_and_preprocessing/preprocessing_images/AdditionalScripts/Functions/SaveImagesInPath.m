function [] = SaveImagesInPath(I,path,fileName)
%SAVEIMAGESINPATH Summary of this function goes here
%   Detailed explanation goes here
if not(isfolder(path))
    mkdir(path)
end

try
    imwrite(I,fullfile(path,fileName))
catch
    %save as array
    save(fullfile(path,[fileName, '.mat']), 'I')

end

