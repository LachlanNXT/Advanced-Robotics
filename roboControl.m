% roboControl
% Lachlan Robinson

%% setup
close all; clear all; clc;
lmNumber = 0;
% Connect to the Rasp Pi
% Get you Pi's IP (type hostname -I into Pi terminal)
IP = '172.19.226.39'; %'172.19.226.67';IP = '172.19.226.67';
pb = PiBot(IP);

%% Get Image from Camera
img = pb.getImageFromCamera();
imshow(img)

% motors= ['A' 'B'];
% speeds = [30,30]; % negative for reverse
% pb.setMotorSpeeds(motors,speeds);
% pause(1);

while(1)

img = pb.getImageFromCamera();

roboVision

pause(3)

%lmNumber

end