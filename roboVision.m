%Vision Controlled Robot Arm
%Lachlan Robinson and Simon Pratt

clc; close all; warning off;
set(0,'DefaultFigureWindowStyle','docked');
silent = 1;

%% Aquire Images

im = iread('DSC00038.JPG'); s = size(im);

if prod(s(1:2))>1.7e6
    im = iscale(im,.2);
end

idisp(im)

fObject = [0, 0, 0];
fsizes = {};
for i = 1:3

disp('1 2 3 4 5 6 rT rS rC gT gS gC');

fObject(i) = input('Input selection here: ');

fsizes{i} = input('Input sizes here: ', 's');

end
%im = igamma(im,0.45);
red = double(im(:,:,1));
green = double(im(:,:,2));
blue = double(im(:,:,3));
if ~silent
idisp(im)
figure
idisp(red)
figure
idisp(green)
figure
idisp(blue)
input('continue? ')
end

%% Chromacity coordinates

S = red+green+blue;
S = double(S);
r = red./S; g = green./S; b = blue./S;
if ~silent
close all
figure
idisp(r)
figure
idisp(g)
figure
idisp(b)
input('continue? ')
end

%% Thresholding

sr = sort(r(:),'ascend'); sg = sort(g(:),'ascend'); sb = sort(b(:),'ascend');
a = size(r);
fullsize = a(1)*a(2);
pcent = 95;
pctile = round((pcent/100)*fullsize);
tr = sr(pctile);
tg = sg(pctile);
tb = sb(pctile);

tred = r>=tr; tgreen = g>=tg; tblue = b>=tb;
if ~silent
close all
figure
idisp(tred)
figure
idisp(tgreen)
figure
idisp(tblue)
input('continue? ')
end
% pred = sum(sum(tred))/fullsize;
% pgreen = sum(sum(tgreen))/fullsize;
% pblue = sum(sum(tblue))/fullsize;

%% Morphological filtering

se = ones(7);
% tred = imorph(tred, ones(7), 'Opening');
% tgreen = imorph(tgreen, ones(7), 'Opening');
% tblue = imorph(tblue, ones(7), 'Opening');
tred = imopen(tred,se);
tgreen = imopen(tgreen,se);
tblue = imopen(tblue,se);
if ~silent
close all
figure
idisp(tred)
figure
idisp(tgreen)
figure
idisp(tblue)
input('continue? ')
end

%% Blobs

rb = iblobs(tred,'area',[300,inf],'class',1,'greyscale','boundary');
gb = iblobs(tgreen,'area',[300,inf],'class',1,'greyscale','boundary');
bb = iblobs(tblue,'area',[300,inf],'class',1,'greyscale','boundary');

[rL, rmaxLabel, rparents, rclass, redge] = ilabel(tred);
[gL, gmaxLabel, gparents, gclass, gedge] = ilabel(tgreen);
[bL, bmaxLabel, bparents, bclass, bedge] = ilabel(tblue);

rLb = iblobs(rL,'area',[300,inf],'greyscale','boundary');
gLb = iblobs(gL,'area',[300,inf],'greyscale','boundary');
bLb = iblobs(bL,'area',[300,inf],'greyscale','boundary');

rLb = rLb(2:end);
gLb = gLb(2:end);
bLb = bLb(2:end);

%% Calibration bounding boxes

close all
figure
idisp(tblue);
for i = 1:max(size(bb))
    if (bb(i).class == 1)
        bb(i).plot_box
        bb(i).plot
    end
end
input('continue? ')

%% Other shapes

close all
tos = tred + tgreen;
osb = iblobs(tos,'area',[300,inf],'class',1,'greyscale','boundary');
figure
idisp(tos)
osb.plot

%% Shape vectors

rTriangles = [];
gTriangles = [];

rSquares = [];
gSquares = [];

rCircles = [];
gCircles = [];

% for i = 1:max(size(osb))
%     if (osb(i).circularity >= 0.85)
%         osb(i).plot_box('blue')
%     end
%     if ((osb(i).circularity < 0.85) .* (osb(i).circularity >= 0.65))
%         osb(i).plot_box('red')
%     end
%     if (osb(i).circularity < 0.65)
%         osb(i).plot_box('green')
%     end
% end

[rTriangles, rSquares, rCircles] = shapeTest(rb, rTriangles, rSquares, rCircles);
[gTriangles, gSquares, gCircles] = shapeTest(gb, gTriangles, gSquares, gCircles);

rb(rTriangles).plot_box('red');
gb(gTriangles).plot_box('red');

% 
% rb(rSquares).plot_box('red');
% gb(gSquares).plot_box('red');


input('Red on triangles - continue? ')

idisp(tos);
osb.plot;
gb.plot_box('blue');

input('Blue on greens - continue? ')

%% Shapes from list

pixelCoords = [];

allShapes = {rb(rTriangles), rb(rSquares), rb(rCircles), gb(gTriangles), gb(gSquares), gb(gCircles)};
allIndices = {rTriangles, rSquares, rCircles, gTriangles, gSquares, gCircles};

theShape = [0, 0, 0];
%fObject = [0, 0, 0];

for i = 1:3

iobs = [0, 0];
for j = 1:(length(allShapes{fObject(i)}))
    iobs(j) = allShapes{fObject(i)}(j).area_;
end

if strcmp(fsizes{i}, 'large')
    theShape(i) = find(iobs == max(iobs));
elseif strcmp(fsizes{i}, 'small')
    theShape(i) = find(iobs == min(iobs));
else
    error('Invalid size chosen')
end

%disp(theShape)
% 
allShapes{fObject(i)}(theShape(i)).plot_box('red')

input('continue? ')

end

% input('continue? ')
%% Selected shapes binary image

% index(1) = allIndices{fObject(1)}(theShape(1));
% index(2) = allIndices{fObject(2)}(theShape(2));
% index(3) = allIndices{fObject(3)}(theShape(3));

ucent(1) = allShapes{fObject(1)}(theShape(1)).uc;
vcent(1) = allShapes{fObject(1)}(theShape(1)).vc;
ucent(2) = allShapes{fObject(2)}(theShape(2)).uc;
vcent(2) = allShapes{fObject(2)}(theShape(2)).vc;
ucent(3) = allShapes{fObject(3)}(theShape(3)).uc;
vcent(3) = allShapes{fObject(3)}(theShape(3)).vc;

ruCent = rb.uc; rvCent = rb.vc;
guCent = gb.uc; gvCent = gb.vc;

rLuCent = rLb.uc; rLvCent = rLb.vc;
gLuCent = gLb.uc; gLvCent = gLb.vc;

RoG = [0, 0, 0];
RG = {rL, gL};

Tol = 5;

indexu = {};
indexv = {};
index = [0, 0, 0];

for count = 1:3
    if fObject(count)<4
        indexu{count} = find((rLuCent+Tol>ucent(count)) .* (rLuCent-Tol<ucent(count)));
        indexv{count} = find((rLvCent+Tol>vcent(count)) .* (rLvCent-Tol<vcent(count)));
        for counter = 1:length(indexv{count})
            temp = indexv{count};
            if ~isempty(find(indexu{count} == temp(counter)))
            index(count) = indexu{count}(find(indexu{count} == temp(counter)));
            end
        end   
        RoG(count) = 1;
        shape(count) = rLb(index(count))
    else
        indexu{count} = find((gLuCent+Tol>ucent(count)) .* (gLuCent-Tol<ucent(count)));
        indexv{count} = find((gLvCent+Tol>vcent(count)) .* (gLvCent-Tol<vcent(count)));
        for counter = 1:length(indexv{count})
            temp = indexv{count};
            if ~isempty(find(indexu{count} == temp(counter)))
            index(count) = indexu{count}(find(indexu{count} == temp(counter)));
            end
        end
        RoG(count) = 2;
        shape(count) = gLb(index(count));
    end
    allShapes{fObject(count)}(theShape(count))
end

Bshape = {};

for count = 1:3
    theLabel = shape(count).label;
    Bshape{count} = RG{RoG(count)} == theLabel;
end

BinSS = Bshape{1}+Bshape{2}+Bshape{3};

close all
idisp(BinSS);
for count = 1:3
    shape(count).plot
    shape(count).plot_box
end
input('continue? ');

%% Homography

%blue circles
bt = min(bb.vc);
br = max(bb.uc);
bbot = max(bb.vc);
bl = min(bb.uc);

bsize = bb.area_;
bigbindex = find(bsize == max(bsize));
bigbu = bb(bigbindex).uc;
bigbv = bb(bigbindex).vc;

PB = double([bl bt; br bt; br bbot; bl bbot]');   %bigbu bigbv;

QB = double([20 20; 20 380; 380 380; 380 20]');

%QB = [20 20;200 20;380 20;20 200;200 200;380 200;20 380;200 380;380 380]';
H = homography(PB,QB);
% P1 = [100 100;200 200;300 300;400 400]';
% Q1 = P1*2;
% H = homography(P1,Q1)

clear location

for i = 1:3
    centroid(:,i) = [shape(i).uc; shape(i).vc];
end

for i = 1:3
    location{i} = homtrans(H, centroid(:,i));
end

H
location1 = location{1}/10-20
location2 = location{2}/10-20
location3 = location{3}/10-20

a = [location1'; location2'; location3';];

%algorithm3_2