function [ map ] = getLandmarks( mapFile )
%getMap Reads in Map file from given directory and outputs an array
%containing the landmark numbers and x and y positions
%
%For 10 landmarks the array is a 10x3 array where the 1st column is the
%landmark number, the 2nd column is x location (centimeters) and the 3rd
%column is the y position (cenitmeters)
%
%Input is the filename of the text file (including extentsions) in the
%current directory
%
%This is would be a quick way to read in the landmark locations during
%demostration on thursday

fid = fopen(mapFile);
tempMap = textscan(fid,'%f%f%c%f');
numLandmarks = length(tempMap{1});
map = zeros(numLandmarks,3);
for i = 1:numLandmarks
 map(i,1) = tempMap{1}(i);
 map(i,2) = tempMap{2}(i);
 map(i,3) = tempMap{4}(i);
end
fclose(fid);
end


