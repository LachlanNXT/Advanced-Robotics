close all; clear all; clc;
% Connect to the Rasp Pi
% Get you Pi's IP (type hostname -I into Pi terminal)
IP = '172.19.226.39';
pb = PiBot(IP);


% set up travel
s=0.05;          % set desiered travel
t=2;            % time to do it in
v=s/t;         % calculated velocity
L = 0.12;       % length of base
R = 0.028;      % wheel radius

% known values of the field/robot
FIELD_SIZE_X = 4;
FIELD_SIZE_Y = 4;
SPos = [0; 2];          %starting position of the robot
ROBOT_RADIUS = 0.12 / 2.0;

phi = -3*pi/4;
robotbearing = phi;
i=0;
timestep = 0.2;
phidot = robotbearing*t;
phi = phi + phidot;
load covar_mat
std_dev = 0.4;
V = diag([(v*timestep*std_dev)^2, (robotbearing*timestep*std_dev)^2]);

NeilVision
predictionrobot
%updateerobot

z=260;

while (i<7)
    close all; 

    
    %pause(1)

    if bottomwhite < z    % not close to wall
        w=0;
        robotbearing = robotbearing+w*t;
        v=s/t;
        for blbl = 1:numel(blackblobs)
            if blacklabelx(blbl) > 120
                obstacleangle = (blacklabelx(bb)-120)*60/240;
                if (obstacleangle < -5 && obstacleangle > 5)
                    w=0;        % turning velocity
                    v=s/t;
                else
                    w=-pi/4;
                    robotbearing = robotbearing+w*t;
                    v = 0;      % robot not moving, just turning
                end
            else
                obstacleangle = (120-blacklabelx(blbl))*60/240;
                if (obstacleangle < -5 && obstacleangle > 5)
                    w=0;
                    v=s/t;
                else
                    w=pi/4;
                    robotbearing = robotbearing+w*t;
                    v = 0;      % robot not moving, just turning
                end
            end
        end
    else    % close to wall
        w = -pi/4;       % turning velocity
        %w =0;
        robotbearing = robotbearing+w*t;
        v = 0;      % robot not moving, just turning
        
    end
    
    robotbearing = mod(robotbearing,2*pi);
    if (robotbearing>pi) robotbearing = robotbearing - 2*pi; end;
    
    phidot = w*t;
    phi = phi+phidot;
    phi = mod(phi,2*pi);
    if (phi > pi) phi = phi - 2*pi; end
   
    
    % derivatives
    xdot = v * cos(phi)*t;
    ydot = v * sin(phi)*t;
    
    % position updates - real position
    SPos(1) = SPos(1)+xdot;
    SPos(2) = SPos(2)+ydot;
    
    predictionrobot
    
    %NeilVision
    
    
    v=s/t;      % assign v again for turning case
    velA =(2*v - w*L)/(2*R);          % velocity of motor B rad/s
    velB =(2*v + w*L)/(2*R);            
    rotationpersecondA = velA / (2*pi);         %radians to degrees
    rotationpersecondB = velB / (2*pi);
    tickspersecondA = rotationpersecondA * 720 * 1.2;     % convert to ticks/s (720 ticks per rotation, 1.2 gear ratio)
    tickspersecondB = rotationpersecondB * 720 * 1.2;
    motorpowerA = (255/2000)*tickspersecondA;     % convert ticks/s to a motor power
    motorpowerB = (255/2079)*tickspersecondB;

%     pb.setMotorSpeeds('A',motorpowerA)  % right motor
%     pb.setMotorSpeeds('B',motorpowerB)  % left motor

    %pause(t)

%     pb.setMotorSpeeds('A',0)
%     pb.setMotorSpeeds('B',0)

    
    
    i=i+1;

    disp (i)
    
    
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
    
    %pause(2)
end

