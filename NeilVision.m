close all; clear all; clc;
% 
%% Connect to the Rasp Pi
% Get you Pi's IP (type hostname -I into Pi terminal)
IP = '172.19.226.39';
pb = PiBot(IP);

%% Get Image from Camera
img = pb.getImageFromCamera();
%img = imrotate(img, -90);
img2 = imread('test.png');
img = idouble(img);

figure;
imshow(img);

% known values of camera
focal_length = 3.6;
beacon_height = 100;
sensor_height = 2.74;
image_height = 320;

% known values of the field/robot
FIELD_SIZE_X = 2.0;
FIELD_SIZE_Y = 2.0;
SPos = [0.3; 0.3];          %starting position of the robot
ROBOT_RADIUS = 0.118 / 2.0;


% set-up markers
landmark_RADIUS = 0.025;
GBR = [1.24; 1.76];         %marker 2
RGR = [1.62; 0.64];         %marker 3
BRB = [0.31; 1.52];         %marker 4
RGB = [1.24; 0.45];         %marker 5
BGB = [1.48; 1.42];         %marker 6
RBR = [0.94; 1.42];         %marker 7
BRG = [0.63; 0.36];         %marker 8
BGR = [1.24; 0.83];         %marker 9
GBG = [0.71; 0.83];         %marker 10

% setup colours
red = img(:,:,1);
green = img(:,:,2);
blue = img(:,:,3);
y = red + green + blue;
r = red./y;
g = green./y;
b = blue./y;

% set-up binarys
redbinary = (r>0.65);
greenbinary = (g>.5);
bluebinary = (b>.3);
whitebinary = (g>.5) & (r<.35) & (b<.1);
blackbinary = (g>.4) & (r<.5) & (b<0.01);

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
blackbinaryclean = iopen(blackbinary, ones(7,7));

% displays colours
% figure;
% imshow(redbinaryclean)
% figure;
% imshow(greenbinaryclean)
% figure;
% imshow(bluebinaryclean)
figure;
imshow(whitebinaryclean)
figure;
imshow(blackbinaryclean)

% display original imagewith boxes and stars on blobs
% red binary blobs
figure;
imshow(img)
redblobs = iblobs(redbinaryclean, 'area', [50,3000], 'touch', 0);
if numel(redblobs) > 0
    redblobs.plot_box('r')
    redblobs.plot('r*')
end
% green binary blobs
greenblobs = iblobs(greenbinaryclean, 'area', [50,3000], 'touch', 0);
if numel(greenblobs) > 0
    greenblobs.plot_box('g')
    greenblobs.plot('g*')
end
% blue binary blobs
blueblobs = iblobs(bluebinaryclean, 'area', [50,3000], 'touch', 0);
if numel(blueblobs) > 0
    blueblobs.plot_box('b')
    blueblobs.plot('b*')
end
% white binary blobs
whiteblobs = iblobs(whitebinaryclean, 'area', [50,50000], 'touch', 1, 'class', 1);
if numel(whiteblobs) > 0
    whiteblobs.plot_box('w')
    whiteblobs.plot('w*')
end
% black binary blobs
blackblobs = iblobs(blackbinaryclean, 'area', [500,5000]);
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
    whitelabelx = whiteblobs.uc;
    whitelabely = whiteblobs.vc;
    bottomwhite = whiteblobs.vmin;
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
                        disp('RGB = Marker 5')
                        disp(distance_of_landmark)
                        if greenlabelx(gg) > 120
                            angle = (greenlabelx(gg)-120)*60/240;
                            disp('angle')
                            disp(angle)
                        end
                        if greenlabelx(gg) < 120
                            angle = (120-greenlabelx(gg))*60/240;
                            disp('angle')
                            disp(-angle)
                        end
                    end
                    % blue/green/red
                    if (bluelabely(bb) < greenlabely(gg) && greenlabely(gg) < redlabely(rr) && bluelabely(bb) > 50)
                        beacon_image_height = redlabely(rr) - bluelabely(bb); % height from top blob to bottom blob
                        distance_of_landmark = ratio/beacon_image_height;
                        disp('BGR = Marker 9')
                        disp(distance_of_landmark)
                        if greenlabelx(gg) > 120
                            angle = (greenlabelx(gg)-120)*60/240;
                            disp('angle')
                            disp(angle)
                        end
                        if greenlabelx(gg) < 120
                            angle = (120-greenlabelx(gg))*60/240;
                            disp('angle')
                            disp(-angle)
                        end
                    end
                    % blue/red/green
                    if (bluelabely(bb) < redlabely(rr) && redlabely(rr) < greenlabely(gg) && bluelabely(bb) > 50)
                        beacon_image_height = greenlabely(gg) - bluelabely(bb); % height from top blob to bottom blob
                        distance_of_landmark = ratio/beacon_image_height;
                        disp('BRG = Marker 8')
                        disp(distance_of_landmark)
                        if redlabelx(rr) > 120
                            angle = (redlabelx(rr)-120)*60/240;
                            disp('angle')
                            disp(angle)
                        end
                        if redlabelx(rr) < 120
                            angle = (120-redlabelx(rr))*60/240;
                            disp('angle')
                            disp(-angle)
                        end
                    end
                    % green/blue/red
                    if (greenlabely(gg) < bluelabely(bb) && bluelabely(bb) < redlabely(rr) && greenlabely(gg) > 50)
                        beacon_image_height = redlabely(rr) - greenlabely(gg); % height from top blob to bottom blob
                        distance_of_landmark = ratio/beacon_image_height;
                        disp('GBR = Marker 2')
                        disp(distance_of_landmark)
                        if bluelabelx(bb) > 120
                            angle = (bluelabelx(bb)-120)*60/240;
                            disp('angle')
                            disp(angle)
                        end
                        if bluelabelx(bb) < 120
                            angle = (120-bluelabelx(bb))*60/240;
                            disp('angle')
                            disp(-angle)
                        end
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
                            disp('RBR = Marker 7')
                            disp(distance_of_landmark)
                            if bluelabelx(bb) > 120
                                angle = (bluelabelx(bb)-120)*60/240;
                                disp('angle')
                                disp(angle)
                            end
                            if bluelabelx(bb) < 120
                                angle = (120-bluelabelx(bb))*60/240;
                                disp('angle')
                                disp(-angle)
                            end
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
                            disp('BRB = Marker 4')
                            disp(distance_of_landmark)
                            if redlabelx(rr) > 120
                                angle = (redlabelx(rr)-120)*60/240;
                                disp('angle')
                                disp(angle)
                            end
                            if redlabelx(rr) < 120
                                angle = (120-redlabelx(rr))*60/240;
                                disp('angle')
                                disp(-angle)
                            end
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
                            disp('RGR = Marker 3')
                            disp(distance_of_landmark)
                            if greenlabelx(gg) > 120
                                angle = (greenlabelx(gg)-120)*60/240;
                                disp('angle')
                                disp(angle)
                            end
                            if greenlabelx(gg) < 120
                                angle = (120-greenlabelx(gg))*60/240;
                                disp('angle')
                                disp(-angle)
                            end
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
                            disp('GBG = Marker 10')
                            disp(distance_of_landmark)
                            if bluelabelx(bb) > 120
                                angle = (bluelabelx(bb)-120)*60/240;
                                disp('angle')
                                disp(angle)
                            end
                            if bluelabelx(bb) < 120
                                angle = (120-bluelabelx(bb))*60/240;
                                disp('angle')
                                disp(-angle)
                            end
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
                            disp('BGB = Marker 6')
                            disp(distance_of_landmark)
                            if greenlabelx(gg) > 120
                                angle = (greenlabelx(gg)-120)*60/240;
                                disp('angle')
                                disp(angle)
                            end
                            if greenlabelx(gg) < 120
                                angle = (120-greenlabelx(gg))*60/240;
                                disp('angle')
                                disp(-angle)
                            end
                        end
                    end
                end
            end
        end
    end
end



%% RENDER SCENE
figure;
subplot(1, 1, 1, 'replace');    
hold on;    
% draw field
rectangle('Position', [0, 0, FIELD_SIZE_X, FIELD_SIZE_Y], 'FaceColor', 'g');
% draw robot
rectangle('Position', [SPos(1) - ROBOT_RADIUS, SPos(2) - ROBOT_RADIUS, ROBOT_RADIUS * 2, ROBOT_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', 'k');
% draw estimate robot
% rectangle('Position', [robot_new(X) - ROBOT_RADIUS, robot_new(Y) - ROBOT_RADIUS, ROBOT_RADIUS * 2, ROBOT_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', 'y');
% draw landmarks
rectangle('Position', [GBR(1) - landmark_RADIUS, GBR(2) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
rectangle('Position', [RGR(1) - landmark_RADIUS, RGR(2) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
rectangle('Position', [BRB(1) - landmark_RADIUS, BRB(2) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
rectangle('Position', [RGB(1) - landmark_RADIUS, RGB(2) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
rectangle('Position', [BGB(1) - landmark_RADIUS, BGB(2) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
rectangle('Position', [RBR(1) - landmark_RADIUS, RBR(2) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
rectangle('Position', [BRG(1) - landmark_RADIUS, BRG(2) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
rectangle('Position', [BGR(1) - landmark_RADIUS, BGR(2) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
rectangle('Position', [GBG(1) - landmark_RADIUS, GBG(2) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);



axis([-0.2, FIELD_SIZE_X + 0.2, -0.2, FIELD_SIZE_Y + 0.2]);
hold off;
drawnow; 










