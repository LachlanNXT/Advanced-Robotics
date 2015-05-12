close all; clear all; clc;

%% Connect to the Rasp Pi
% Get you Pi's IP (type hostname -I into Pi terminal)
IP = '172.19.226.39'; %'172.19.226.67';IP = '172.19.226.67';
pb = PiBot(IP);

%% Get Image from Camera
% img = pb.getImageFromCamera();
% imshow(img)

testing = 1;
iter = 1;
while(testing)
    tic;
    img2 = pb.getImageFromCamera();
    toc
    time(iter) = toc;
    iter = iter+1;
    if iter>50
        testing = false;
        pb.setMotorSpeeds('b',100)
    end 
    imshow(img2);
    
    
end 
