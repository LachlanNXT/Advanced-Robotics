close all; clear all; clc;
% 
%% Connect to the Rasp Pi
% Get you Pi's IP (type hostname -I into Pi terminal)
IP = '172.19.226.39';
pb = PiBot(IP);

% Get Image from Camera
% img = pb.getImageFromCamera();
% 
% while(isempty(img))
% 
% img = pb.getImageFromCamera();
% pause(.1);
% 
% end
img2 = imread('test2.png');
img = flip(img2,2);
img = idouble(img);

% figure;
% imshow(img);

% known values of camera
focal_length = 3.6;
beacon_height = 100;
sensor_height = 2.74;
image_height = 320;



% set-up markers
landmark_RADIUS = 0.025;

GBR = [1.24, 1.76];         %marker 1
RGR = [1.62, 0.64];         %marker 2
BRB = [0.31, 1.52];         %marker 3
RGB = [1.24, 0.45];         %marker 4
BGB = [1.48, 1.42];         %marker 5
RBR = [0.94, 1.42];         %marker 6
BRG = [0.63, 0.36];         %marker 7
BGR = [1.24, 0.83];         %marker 8
GBG = [0.71, 0.83];         %marker 9

% GBR = lmPos(1,:);
% RGR = lmPos(2,:);
% BRB = lmPos(3,:);
% RGB = lmPos(4,:);
% BGB = lmPos(5,:);
% RBR = lmPos(6,:);
% BRG = lmPos(7,:);
% BGR = lmPos(8,:);
% GBG = lmPos(9,:);



% setup colours
red = img(:,:,1);
green = img(:,:,2);
blue = img(:,:,3);
y = red + green + blue;
r = red./y;
g = green./y;
b = blue./y;
grey = rgb2gray(img);

% set-up binarys
redbinary = (r>0.6);
greenbinary = (g>.52);
bluebinary = (b>.3);
whitebinary = (g>.5) & (r<.35) & (b<.1);
blackbinary = grey < 0.06;

% displays colours
% figure;
% imshow(r)
% figure;
% imshow(g)
% figure;
% imshow(b)

% clean up binaries
redbinaryclean = iopen(redbinary, ones(5,5));
greenbinaryclean = iopen(greenbinary, ones(6,6));
bluebinaryclean = iopen(bluebinary, ones(5,6));
whitebinaryclean = iopen(whitebinary, ones(8,8));
blackbinaryclean = iopen(blackbinary, ones(5,5));

% displays colours
% figure;
% imshow(redbinaryclean)
% figure;
% imshow(greenbinaryclean)
% figure;
% imshow(bluebinaryclean)
% figure;
% imshow(whitebinaryclean)
figure;
imshow(blackbinaryclean)

% display original imagewith boxes and stars on blobs
% red binary blobs
figure;
hold on
imshow(img);
redblobs = iblobs(redbinaryclean, 'area', [100,3000], 'touch', 0);
if numel(redblobs) > 0
    redblobs.plot_box('r')
    redblobs.plot('r*')
end
% green binary blobs
greenblobs = iblobs(greenbinaryclean, 'area', [100,3000], 'touch', 0);
if numel(greenblobs) > 0
    greenblobs.plot_box('g')
    greenblobs.plot('g*')
end
% blue binary blobs
blueblobs = iblobs(bluebinaryclean, 'area', [100,3000], 'touch', 0);
if numel(blueblobs) > 0
    blueblobs.plot_box('b')
    blueblobs.plot('b*')
end
% white binary blobs
whiteblobs = iblobs(whitebinaryclean, 'area', [100,inf], 'touch', 1, 'class', 1);
if numel(whiteblobs) > 0
    whiteblobs.plot_box('w')
    whiteblobs.plot('w*')
end
% black binary blobs
blackblobs = iblobs(blackbinaryclean, 'area', [10000,inf]);
if numel(blackblobs) > 0
    blackblobs.plot_box('m')
    blackblobs.plot('m*')
end

% set-up labels
[Lrb,rbc] = ilabel(redbinaryclean);
[Lgb,gbc] = ilabel(greenbinaryclean);
[Lbb,bbc] = ilabel(bluebinaryclean);
[Lwb,wbc] = ilabel(whitebinaryclean);
[Lbbb,bbbc] = ilabel(blackbinaryclean);

rbc;
gbc;
bbc;
wbc;
bbbc;

% set-up labels
if numel(redblobs) > 0
    redlabelx = redblobs.uc;
    redlabely = redblobs.vc;
end
if numel(greenblobs) > 0
    greenlabelx = greenblobs.uc;
    greenlabely = greenblobs.vc;
end
if numel(blueblobs) > 0
    bluelabelx = blueblobs.uc;
    bluelabely = blueblobs.vc;
end
if numel(whiteblobs) > 0
    whitearea = whiteblobs(1).area_;
    whitelabelx = whiteblobs(1).uc;
    whitelabely = whiteblobs(1).vc;
    bottomwhite = whiteblobs(1).vmin;
    for ww = 1:numel(whiteblobs)
        if whitearea < whiteblobs(ww).area_
            whitearea = whiteblobs(ww).area_;
            whitelabelx = whiteblobs(ww).uc;
            whitelabely = whiteblobs(ww).vc;
            bottomwhite = whiteblobs(ww).vmin;
        end
    end
end
if numel(blackblobs) > 0
    blacklabelx = blackblobs.uc;
    blacklabely = blackblobs.vc;
end


aa = 40;
pp = 40;
ratio = 2.28*10;

% all bands different
% all red labels
for rr = 1:numel(redblobs),
    % all green labels
    for gg = 1:numel(greenblobs),
        % all blue labels
        for bb = 1:numel(blueblobs),
            %different bands of image (split every 32 pixels)
            for aa = [40:40:240]
                % all colours in 1 band
                if (aa-pp<redlabelx(rr) && redlabelx(rr)<aa && aa-pp<greenlabelx(gg) && greenlabelx(gg)<aa && aa-pp<bluelabelx(bb) && bluelabelx(bb)<aa)
                    % red/green/blue
                    if (redlabely(rr) < greenlabely(gg) && greenlabely(gg) < bluelabely(bb) && redlabely(rr) > 50)
                        beacon_image_height = bluelabely(bb) - redlabely(rr); % hright from top blob middle to bottom blob middle
                        distance_of_landmark = ratio/beacon_image_height;
                        disp('RGB = Marker 4')
                        disp(distance_of_landmark)
                        mark = 4;
                        if greenlabelx(gg) > 120
                            angle = (greenlabelx(gg)-120)*41/240;
                            angle = -(angle*pi/180);
                            disp('angle')
                            disp(angle)
                        end
                        if greenlabelx(gg) < 120
                            angle = (120-greenlabelx(gg))*41/240;
                            angle = angle*pi/180;
                            disp('angle')
                            disp(angle)
                        end
                        updateerobot
                    end
                    % blue/green/red
                    if (bluelabely(bb) < greenlabely(gg) && greenlabely(gg) < redlabely(rr) && bluelabely(bb) > 50)
                        beacon_image_height = redlabely(rr) - bluelabely(bb); % height from top blob to bottom blob
                        distance_of_landmark = ratio/beacon_image_height;
                        disp('BGR = Marker 8')
                        disp(distance_of_landmark)
                        mark = 8;
                        if greenlabelx(gg) > 120
                            angle = (greenlabelx(gg)-120)*41/240;
                            angle = -(angle*pi/180);
                            disp('angle')
                            disp(angle)
                        end
                        if greenlabelx(gg) < 120
                            angle = (120-greenlabelx(gg))*41/240;
                            angle = angle*pi/180;
                            disp('angle')
                            disp(angle)
                        end
                        updateerobot
                    end
                    
                    % blue/red/green
                    if (bluelabely(bb) < redlabely(rr) && redlabely(rr) < greenlabely(gg) && bluelabely(bb) > 50)
                        beacon_image_height = greenlabely(gg) - bluelabely(bb); % height from top blob to bottom blob
                        distance_of_landmark = ratio/beacon_image_height;
                        disp('BRG = Marker 7')
                        disp(distance_of_landmark)
                        mark = 7;
                        if redlabelx(rr) > 120
                            angle = (redlabelx(rr)-120)*41/240;
                            angle = -(angle*pi/180);
                            disp('angle')
                            disp(angle)
                        end
                        if redlabelx(rr) < 120
                            angle = (120-redlabelx(rr))*41/240;
                            angle = angle*pi/180;
                            disp('angle')
                            disp(angle)
                        end
                        updateerobot
                    end
                    % green/blue/red
                    if (greenlabely(gg) < bluelabely(bb) && bluelabely(bb) < redlabely(rr) && greenlabely(gg) > 50)
                        beacon_image_height = redlabely(rr) - greenlabely(gg); % height from top blob to bottom blob
                        distance_of_landmark = ratio/beacon_image_height;
                        disp('GBR = Marker 1')
                        disp(distance_of_landmark)
                        mark = 1;
                        if bluelabelx(bb) > 120
                            angle = (bluelabelx(bb)-120)*41/240;
                            angle = -(angle*pi/180);
                            disp('angle')
                            disp(angle)
                        end
                        if bluelabelx(bb) < 120
                            angle = (120-bluelabelx(bb))*41/240;
                            angle = angle*pi/180;
                            disp('angle')
                            disp(angle)
                        end
                        updateerobot
                    end
                end 
            end
        end
    end
end


% all red labels
for rr = 1:numel(redblobs),
    % all blue labels
    for bb = 1:numel(blueblobs),
        % different bands of image (split every 32 pixels)
        for aa = [40:40:240]
            % take a second red band
            for rrr = 1:numel(redblobs),
                if (rr~=rrr)
                    %red/blue/red
                    if (aa-pp<redlabelx(rr) && redlabelx(rr)<aa && aa-pp<redlabelx(rrr) && redlabelx(rrr)<aa && aa-pp<bluelabelx(bb) && bluelabelx(bb)<aa)
                        if (redlabely(rr) < redlabely(rrr) && redlabely(rr) > 50)
                            beacon_image_height = redlabely(rrr) - redlabely(rr); % hright from top blob to bottom blob
                            distance_of_landmark = ratio/beacon_image_height;
                            disp('RBR = Marker 6')
                            disp(distance_of_landmark)
                            mark = 6;
                            if bluelabelx(bb) > 120
                                angle = (bluelabelx(bb)-120)*41/240;
                                angle = -(angle*pi/180);
                                disp('angle')
                                disp(angle)
                            end
                            if bluelabelx(bb) < 120
                                angle = (120-bluelabelx(bb))*41/240;
                                angle = angle*pi/180;
                                disp('angle')
                                disp(angle)
                            end
                            updateerobot
                        end
                    end
                end
            end 
            % take a second blue band
            for bbb = 1:numel(blueblobs),
                if (bb~=bbb)
                    %blue/red/blue
                    if (aa-pp<redlabelx(rr) && redlabelx(rr)<aa && aa-pp<bluelabelx(bb) && bluelabelx(bb)<aa && aa-pp<bluelabelx(bbb) && bluelabelx(bbb)<aa)
                        if (bluelabely(bb) < bluelabely(bbb) && bluelabely(bb) > 50)
                            beacon_image_height = bluelabely(bbb) - bluelabely(bb); % height from top blob to bottom blob
                            distance_of_landmark = ratio/beacon_image_height;
                            disp('BRB = Marker 3')
                            disp(distance_of_landmark)
                            mark = 3;
                            if redlabelx(rr) > 120
                                angle = (redlabelx(rr)-120)*41/240;
                                angle = -(angle*pi/180);
                                disp('angle')
                                disp(angle)
                            end
                            if redlabelx(rr) < 120
                                angle = (120-redlabelx(rr))*41/240;
                                angle = angle*pi/180;
                                disp('angle')
                                disp(angle)
                            end
                            updateerobot
                        end
                        
                    end
                end
            end     
        end
    end
    % all green labels
    for gg = 1:numel(greenblobs),
        %different bands of image (split every 32 pixels)
        for aa = [40:40:240]
            % take a second red band
            for rrr = 1:numel(redblobs),
                if (rr~=rrr)
                    %red/green/red
                    if (aa-pp<redlabelx(rr) && redlabelx(rr)<aa && aa-pp<redlabelx(rrr) && redlabelx(rrr)<aa && aa-pp<greenlabelx(gg) && greenlabelx(gg)<aa)
                        if (redlabely(rr) < redlabely(rrr) && redlabely(rr) > 50)
                            beacon_image_height = redlabely(rrr) - redlabely(rr); % height from top blob to bottom blob
                            distance_of_landmark = ratio/beacon_image_height;
                            disp('RGR = Marker 2')
                            disp(distance_of_landmark)
                            mark = 2;
                            if greenlabelx(gg) > 120
                                angle = (greenlabelx(gg)-120)*41/240;
                                angle = -(angle*pi/180);
                                disp('angle')
                                disp(angle)
                            end
                            if greenlabelx(gg) < 120
                                angle = (120-greenlabelx(gg))*41/240;
                                angle = angle*pi/180;
                                disp('angle')
                                disp(angle)
                            end
                            updateerobot
                        end
                    end
                end
            end 
        end
    end
end
% all green labels
for gg = 1:numel(greenblobs),
    % all blue labels
    for bb = 1:numel(blueblobs),
        %different bands of image (split every 32 pixels)
        for aa = [40:40:240]
            % take a second green band
            for ggg = 1:numel(greenblobs),
                if (gg~=ggg)
                    % green/blue/green
                    if (aa-pp<greenlabelx(gg) && greenlabelx(gg)<aa && aa-pp<greenlabelx(ggg) && greenlabelx(ggg)<aa && aa-pp<bluelabelx(bb) && bluelabelx(bb)<aa)
                        if (greenlabely(gg) < greenlabely(ggg) && greenlabely(gg) > 50)
                            beacon_image_height = greenlabely(ggg) - greenlabely(gg); % height from top blob to bottom blob
                            distance_of_landmark = ratio/beacon_image_height;
                            disp('GBG = Marker 9')
                            disp(distance_of_landmark)
                            mark = 9;
                            if bluelabelx(bb) > 120
                                angle = (bluelabelx(bb)-120)*41/240;
                                angle = -(angle*pi/180);
                                disp('angle')
                                disp(angle)
                            end
                            if bluelabelx(bb) < 120
                                angle = (120-bluelabelx(bb))*41/240;
                                angle = angle*pi/180;
                                disp('angle')
                                disp(angle)
                            end
                            updateerobot
                        end
                    end
                end
            end 
            % take a second blue band
            for bbb = 1:numel(blueblobs),
                if (bb~=bbb)
                    % blue/green/blue
                    if (aa-pp<greenlabelx(gg) && greenlabelx(gg)<aa && aa-pp<bluelabelx(bb) && bluelabelx(bb)<aa && aa-pp<bluelabelx(bbb) && bluelabelx(bbb)<aa)
                        if (bluelabely(bb) < bluelabely(bbb) && bluelabely(bb) > 50)
                            beacon_image_height = bluelabely(bbb) - bluelabely(bb); % height from top blob to bottom blob
                            distance_of_landmark = ratio/beacon_image_height;
                            disp('BGB = Marker 5')
                            disp(distance_of_landmark)
                            mark = 5;
                            if greenlabelx(gg) > 120
                                angle = (greenlabelx(gg)-120)*41/240;
                                angle = -(angle*pi/180);
                                disp('angle')
                                disp(angle)
                            end
                            if greenlabelx(gg) < 120
                                angle = (120-greenlabelx(gg))*41/240;
                                angle = angle*pi/180;
                                disp('angle')
                                disp(angle)
                            end
                            updateerobot
                        end
                    end
                end
            end
        end
    end
end

