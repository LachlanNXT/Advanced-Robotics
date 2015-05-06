% roboControl
% Lachlan Robinson

%% setup
close all; clear all; clc;

% Connect to the Rasp Pi
% Get you Pi's IP (type hostname -I into Pi terminal)
IP = '172.19.226.39'; %'172.19.226.67';IP = '172.19.226.67';
pb = PiBot(IP);

%% Get Image from Camera
img = pb.getImageFromCamera();
imshow(img)

