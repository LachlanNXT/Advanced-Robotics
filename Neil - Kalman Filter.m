% Prac 2 %
close all; clear all; clc;

X = 1;
Y = 2;
T = 3;
VX = 4;
VY = 5;
VT = 6;

FIELD_SIZE_X = 2.0;
FIELD_SIZE_Y = 2.0;
landmark_RADIUS = 0.043 / 2.0;
ROBOT_RADIUS = 0.118 / 2.0;
angular_Velocity = .3;
Robot_Base = 0.118;
wheel_Radius = 0.028;
robot_Velocity = 0.15;
angle = 0;
angle_new = 0;

% covariance matrix
estErrorS = 0.005;
estErrorA = degtorad(1);
cov = diag([estErrorS,estErrorA].^2);

estErrorSsensor = 0.005;
estErrorAsensor = degtorad(1);
covS = diag([estErrorSsensor,estErrorAsensor].^2);


fig_handle = figure('Position', [0 0 600 600]);
finished = 0;
TIME_STEP = 0.05;

% start positions and velocities
landmark1 = [1.5, 1.7];   
landmark2 = [0.2, 1.8];
landmark3 = [0.6, 0.5];
landmark4 = [1.5, 0.5];
landmark5 = [0.4, 1.3];
R_P = [landmark1; landmark2; landmark3; landmark4; landmark5];
robot = [1 .5 0, 0, -1, 0];
robot_new = [1 .5 0, 0, -1, 0];
robot_new_last = [1 .5 0, 0, -1, 0];
Pj = 0;


while (finished == 0)
    try test = get(fig_handle); catch ME, break; end%#ok<NASGU>
    
    Vd = ((normrnd(0,sqrt(cov(1))))*10);
    Vtheta = ((normrnd(0,sqrt(cov(4))))*10);
    
    Vds = ((normrnd(0,sqrt(covS(1))))*10);
    Vthetas = ((normrnd(0,sqrt(covS(4))))*10);
 
    %% predictedion
 
    % exact position of robot
    angle = angle + angular_Velocity * TIME_STEP;
    robot(X) = robot(X) + (robot_Velocity*TIME_STEP)*cos(angle);
    robot(Y) = robot(Y) + (robot_Velocity*TIME_STEP)*sin(angle);
    
    % estimate position of robot with error
    angle_new = angle_new + (angular_Velocity + Vtheta)*TIME_STEP;
    robot_new(X) = robot_new(X) + ((robot_Velocity + Vd)*TIME_STEP)*cos(angle_new);
    robot_new(Y) = robot_new(Y) + ((robot_Velocity + Vd)*TIME_STEP)*sin(angle_new);

    
    % Jacobians for estimated position
    Fx = [1 0 -robot_Velocity*TIME_STEP*sin(angle_new+angular_Velocity*TIME_STEP);
        0 1 robot_Velocity*TIME_STEP*cos(angle+angular_Velocity*TIME_STEP);
        0 0 1];
    Fv = [cos(angle+angular_Velocity*TIME_STEP) -robot_Velocity*TIME_STEP*sin(angle+angular_Velocity*TIME_STEP);
        sin(angle+angular_Velocity*TIME_STEP) robot_Velocity*TIME_STEP*cos(angle+angular_Velocity*TIME_STEP);
        0 1];
    
    % EKF Predicition
    Xx = [robot_new(X), robot_new(Y), angle_new];
    Pj = Fx * Pj * transpose(Fx) + Fv * cov * transpose(Fv);
    
    %% Update
    
    % loop for all 5 markers
    for ii = 1:5;
        % rAngle = robot angle to object
        rDistance = sqrt((R_P(ii, 2) - robot_new(Y))^2 + ((R_P(ii, 1) - robot_new(X))^2)) + Vds;
        rAngle = atan2((R_P(ii,2) - robot_new(Y)),((R_P(ii,1)-robot_new(X)))) - angle_new + Vthetas
      
        
        rDistancer = sqrt((R_P(ii, 2) - robot(Y))^2 + ((R_P(ii, 1) - robot(X))^2));
        rAngler = atan2((R_P(ii,2) - robot(Y)),((R_P(ii,1)-robot(X)))) - angle;

        
        if rAngle > pi
            rAngle = rAngle - pi;
        end
        if (rAngle > 0 && rAngle < pi/12) || (rAngle > 23*pi/12 && rAngle <2*pi)
            % innovation jacobians
            Hx = [-((R_P(ii,1) - robot_new(X))/rDistance), -((R_P(ii,2) - robot_new(Y))/rDistance), 0;
                ((R_P(ii,1) - robot_new(Y))/rDistance^2), -((R_P(ii,2) - robot_new(X))/rDistance^2), -1];
            Hw = [1, 0; 0, 1];
            % update predicted state. kalman gain
            S = Hx * Pj * transpose(Hx) + Hw * covS * transpose(Hw);
            K = Pj * transpose(Hx) * pinv(S);
            V = [-rDistance+rDistancer, rAngle-rAngler];
            % new information
            Xx = Xx + (K * V')';
            Pj = Pj - K * Hx * Pj;
            
            robot_new(X) = Xx(1);
    robot_new(Y) = Xx(2);
    angle_new = Xx(3);
            
        end 
        
                  
    end
    
    %%
  

   
    
    %% RENDER SCENE
    subplot(1, 1, 1, 'replace');    
    hold on;    
    % draw field
    rectangle('Position', [0, 0, FIELD_SIZE_X, FIELD_SIZE_Y], 'FaceColor', 'g');
    % draw robot
    rectangle('Position', [robot(X) - ROBOT_RADIUS, robot(Y) - ROBOT_RADIUS, ROBOT_RADIUS * 2, ROBOT_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', 'k');
    % draw estimate robot
    rectangle('Position', [robot_new(X) - ROBOT_RADIUS, robot_new(Y) - ROBOT_RADIUS, ROBOT_RADIUS * 2, ROBOT_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', 'y');
    % draw landmarks
    rectangle('Position', [landmark1(X) - landmark_RADIUS, landmark1(Y) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
    rectangle('Position', [landmark2(X) - landmark_RADIUS, landmark2(Y) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
    rectangle('Position', [landmark3(X) - landmark_RADIUS, landmark3(Y) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
    rectangle('Position', [landmark4(X) - landmark_RADIUS, landmark4(Y) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
    rectangle('Position', [landmark5(X) - landmark_RADIUS, landmark5(Y) - landmark_RADIUS, landmark_RADIUS * 2, landmark_RADIUS * 2], 'Curvature', [1 1], 'FaceColor', [1 0.6 0]);
    
    
    % draw error ellipse 
    Pnew = Pj([1 2; 4 5]);
    error_ellipse(Pnew, [robot_new(X) robot_new(Y)])
    
    axis([-0.2, FIELD_SIZE_X + 0.2, -0.2, FIELD_SIZE_Y + 0.2]);
    hold off;
    drawnow;   
    
    TIME = TIME_STEP+TIME_STEP;
    pause(.01);   % pause for () seconds. if want on spacebar leave empty
   
end