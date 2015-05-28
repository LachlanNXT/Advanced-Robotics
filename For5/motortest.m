close all; clear all; clc;
%% Run when 

%% Connect to the Rasp Pi
% Get you Pi's IP (type hostname -I into Pi terminal)
IP = '172.19.226.39'; %'172.19.226.67';IP = '131.181.33.107';
pb = PiBot(IP);

%% Set Motor Speeds
disp('Setting Motor Speeds...')

% disp('Motor A on B still inactive')
% motors = 'A'; % to activate all motors motors = 'A,B,C,D'
% speeds = 50; % to set speeds for all vector must be eneterd [50,50,50,50]
% pb.setMotorSpeeds(motors,speeds);
% pause(1)

disp('Motor A and B at -50,-50 speeds')
motors= ['A' 'B'];
speeds = [-50,-50]; % negative for reverse
pb.setMotorSpeeds(motors,speeds);
pause(1);

disp('Motor B at 50 and Motor A off')
motors = 'B';
speeds = 50;
pb.setMotorSpeeds(motors,speeds);

motors = 'A';
speeds = 0;
pb.setMotorSpeeds(motors,speeds);
pause(1);

%% Get Encoder Ticks
disp('Getting Encoder Ticks...')
ticks = pb.getMotorTicks(); disp(ticks)
disp('1st Number for Motor A, then B and so on...')

motors = ['A','B'];
speeds = [0,0];
pb.setMotorSpeeds(motors,speeds);