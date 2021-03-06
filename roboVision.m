%Vision System
%Lachlan Robinson

warning off;
set(0,'DefaultFigureWindowStyle','docked');
silent = 1;

lmColours = ['o' 'o' 'o'; %1
    'g' 'b' 'r'; %2
    'r' 'g' 'r'; %3
    'b' 'r' 'b'; %4
    'r' 'g' 'b'; %5
    'b' 'g' 'b'; %6
    'r' 'b' 'r'; %7
    'b' 'r' 'g'; %8
    'b' 'g' 'r'; %9
    'g' 'b' 'g'; %10 
    ];
lmPos = [0 0;%1
     1.24 1.76;%2
     1.62 0.64;%3
     0.31 1.52;%4
     1.24 0.45;%5
     1.48 1.42;%6
     0.94 1.42;%7
     0.63 0.36;%8
     1.24 0.83;%9
     0.71 0.83;%10
     ];
 
 cameraHeight = 320;
 cameraWidth = 240;
 pixelSize = 1.4*10^-6;
 focalLength = 3.6*10^-3;
 
 TapeHeight = 10*10^-2;
    
% 
% 2 ( GBR) x=1.24 y =1.76
% 3( RGR) x=1.62 y =0.64
% 4( BRB) x=0.31 y=1.52
% 5( RGB) x=1.24 y= 0.45
% 6( BGB) x=1.48 y = 1.42
% 7( RBR) x= 0.94 y = 1.42
% 8( BRG) x= 0.63 y= 0.36
% 9( BGR) x=1.24 y= 0.83
% 10(GBG) x = 0.71 y= 0.83

%% Aquire Images

im = img; s = size(img);
im = im.^1.1;
imshow(im)

%im = igamma(im,0.45);

%separate out RGB colours
red = double(im(:,:,1));
green = double(im(:,:,2));
blue = double(im(:,:,3));
if ~silent
imshow(im)

input('continue? ')
end

%% Chromacity coordinates

S = red+green+blue;
S = double(S);
r = red./S; g = green./S; b = blue./S;
if ~silent
%close all
figure
imshow(r)
figure
imshow(g)
figure
imshow(b)
input('continue? ')
end

%% Thresholding

sr = sort(r(:),'ascend'); sg = sort(g(:),'ascend'); sb = sort(b(:),'ascend');
a = size(r);
fullsize = a(1)*a(2);
pcent = 95;
pctile = round((pcent/100)*fullsize);
tr = .65; %sr(pctile);
tg = .55; %sg(round(.55*fullsize));
tb = .40; %sb(pctile);

tred = r>=tr; tgreen = g>=tg; tblue = b>=tb;
if ~silent
close all
figure
imshow(tred)
figure
imshow(tgreen)
figure
imshow(tblue)
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
tgreen = imopen(tgreen,se);
tblue = imopen(tblue,se);
if ~silent
close all
figure
imshow(tred)
figure
imshow(tgreen)
figure
imshow(tblue)
input('continue? ')
end

%% Blobs
blobLimit = 800;
blobUpper = 4500;

rb = iblobs(tred,'area',[blobLimit,blobUpper],'class',1,'greyscale','boundary','touch',0);
gb = iblobs(tgreen,'area',[blobLimit,blobUpper],'class',1,'greyscale','boundary','touch',0);
bb = iblobs(tblue,'area',[blobLimit,blobUpper],'class',1,'greyscale','boundary','touch',0);

if (length(bb) + length(gb) + length(rb) < 3)
    return;
end
if length(gb)>2
    gb = gb(1:2);
end

[rL, rmaxLabel, rparents, rclass, redge] = ilabel(tred);
[gL, gmaxLabel, gparents, gclass, gedge] = ilabel(tgreen);
[bL, bmaxLabel, bparents, bclass, bedge] = ilabel(tblue);

rLb = iblobs(rL,'area',[blobLimit,blobUpper],'greyscale','boundary');
gLb = iblobs(gL,'area',[blobLimit,blobUpper],'greyscale','boundary');
bLb = iblobs(bL,'area',[blobLimit,blobUpper],'greyscale','boundary');

rLb = rLb(2:end);
gLb = gLb(2:end);
bLb = bLb(2:end);

%% bounding boxes
totalImage = tblue*0;
if (max(size(bb)) ~= 0)
    totalImage = totalImage + tblue;
end
if (max(size(rb)) ~= 0)
    totalImage = totalImage + tred;
end
if (max(size(gb)) ~= 0)
    totalImage = totalImage + tgreen;
end

if ~silent
close all
figure
imshow(totalImage);
end

fail = 0;

if (max(size(bb)) ~= 0)
% for i = 1:max(size(bb))
%     if (bb(i).class == 1)
%         bb(i).plot_box('blue')
%         bb(i).plot
%     end
% end
else
    fail = 1;
end

if (max(size(rb)) ~= 0)
%     for i = 1:max(size(rb))
%     if (rb(i).class == 1)
%         rb(i).plot_box('red')
%         rb(i).plot
%     end
%     end 
else
    fail = fail+1;
end

if (max(size(gb)) ~= 0)
%     for i = 1:max(size(gb))
%     if (gb(i).class == 1)
%         gb(i).plot_box('green')
%         gb(i).plot
%     end
%     end
else
    fail = fail+1;
end

if fail == 3
    return;
end

if ~silent
input('continue? ')
close all
figure
imshow(totalImage);
end
%% Shape vectors

rTriangles = [];
gTriangles = [];
bTriangles = [];
rSquares = [];
gSquares = [];
bSquares = [];
rCircles = [];
gCircles = [];
bCircles = [];

[rTriangles, rSquares, rCircles] = shapeTest(rb, rTriangles, rSquares, rCircles);
[gTriangles, gSquares, gCircles] = shapeTest(gb, gTriangles, gSquares, gCircles);
[bTriangles, bSquares, bCircles] = shapeTest(bb, bTriangles, bSquares, bCircles);


if (~isempty(rSquares))
rb(rSquares).plot_box('red');
end

if (~isempty(bSquares))
bb(bSquares).plot_box('blue');
end

if (~isempty(gSquares))
gb(gSquares).plot_box('green');
end

if ~silent
input('continue? ')
end

%% Shapes from list
clear Stripes
clear ucent
clear vcent
allShapes = {rb(rSquares), gb(gSquares), bb(bSquares)};
check = length(rb(rSquares)) + length(gb(gSquares)) + length(bb(bSquares));
if check>3
    return
end
index = 1;
for i = 1:3
    for j = 1:length(allShapes{i})
        ucent(index) = allShapes{i}(j).uc;
        vcent(index) = allShapes{i}(j).vc;
        if (i==1) Stripes(index) = 'r'; end;
        if (i==2) Stripes(index) = 'g'; end;
        if (i==3) Stripes(index) = 'b'; end;
        index = index + 1;
    end
end

if (max(vcent) > (cameraHeight / 2))
   return; 
end
if (min(vcent) < (cameraHeight /20))
   return;
end

vcent2 = sort(vcent);
order = vcent2;
for i = 1:length(vcent)
    order(i) = find(vcent == vcent2(i));
end
Stripes = Stripes(order);

%%
lmNumber = 0;

for i = 1:length(lmColours)
    temp = (lmColours(i,:) == Stripes);
    if (sum(temp) == 3)
        lmNumber = i;
    end
end

%disp(lmNumber)

pixelHeight = max(vcent)-min(vcent);

Z = (8*10^-2*focalLength)/(pixelHeight*pixelSize)/10;

X = (median(ucent) - cameraWidth/2)*pixelSize*Z/(focalLength)*10;

Bearing = atan2(X,Z);

disp([lmNumber sqrt(Z^2 + X^2) Bearing*180/pi]);




