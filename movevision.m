close all; clear all; clc;
% Connect to the Rasp Pi
% Get you Pi's IP (type hostname -I into Pi terminal)
IP = '172.19.226.39';
pb = PiBot(IP);

i=0;

while (i<1)
    close all; 

    NeilVision
    pause(2)
    % set up travel
    s=0.2;          % set desiered travel
    t=2;            % time to do it in
    v=s/t;          % calculated velocity
    L = 0.12;       % length of base
    R = 0.028;      % wheel radius

    if bottomwhite < 250    % not close to wall
        for blbl = 1:numel(blackblobs)
            if blacklabelx(blbl) > 120
                obstacleangle = (blacklabelx(bb)-120)*60/240;
                if (obstacleangle < -5 && obstacleangle > 5)
                    w=0;        % turning velocity
                else
                    w=pi/4;
                end
            else
                obstacleangle = (120-blacklabelx(blbl))*60/240;
                if (obstacleangle < -5 && obstacleangle > 5)
                    w=0;
                else
                    w=pi/4;
                end
            end
        end
    else    % close to wall
        w = pi/4;       % turning velocity
    end

    velA =(2*v - w*L)/(2*R);          % velocity of motor B rad/s
    velB =(2*v + w*L)/(2*R);            
    rotationpersecondA = velA / (2*pi);         %radians to degrees
    rotationpersecondB = velB / (2*pi);
    tickspersecondA = rotationpersecondA * 720 * 1.2;     % convert to ticks/s (720 ticks per rotation, 1.2 gear ratio)
    tickspersecondB = rotationpersecondB * 720 * 1.2;
    motorpowerA = (255/2000)*tickspersecondA     % convert ticks/s to a motor power
    motorpowerB = (255/2079)*tickspersecondB

    pb.setMotorSpeeds('A',motorpowerA)  % right motor
    pb.setMotorSpeeds('B',motorpowerB)  % left motor

    pause(t)

    pb.setMotorSpeeds('A',0)
    pb.setMotorSpeeds('B',0)

    pause(1)
    
    i=2;

end
