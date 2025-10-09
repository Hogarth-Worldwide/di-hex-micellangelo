function [NW_xx,NW_yy] = NW_corner_CPTile(tilenumber,sizeImage,numberOfTiles)
%NW_corner_CPTile Get NW corner for specific tilenumber

sizex = sqrt(numberOfTiles);
sizey=sizex;

NW_xx = 1 + sizeImage * rem(tilenumber-1,sizex);
NW_yy = 1 + sizeImage * floor(tilenumber/sizey);
end