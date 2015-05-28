%update


nxD = lmPos(mark,1) - SPos(1);
nyD = lmPos(mark,2) - SPos(2);
nDist = sqrt(nxD^2 + nyD^2);
nTheta = atan2(nyD,nxD) - robotbearing;
nTheta = mod(nTheta, 2*pi);
if (nTheta>pi) nTheta = nTheta - 2*pi; end;

%measurement noise
% sigr = (std_dev*randn); sigb = (std_dev*randn);
%measurement estimation, range and bearing angle
z = [distance_of_landmark; angle];
h = [nDist; nTheta];
%innovation
vErr = (z - h);
%estimated covariance of sensor noise
W = [(std_dev)^2, 0; 0, (std_dev)^2];

%jacobians
radius = nDist;
Hx = [-(lmPos(mark,1) - SPos(1))/radius, -(lmPos(mark,2) - SPos(2))/radius, 0;
    (lmPos(mark,2) - SPos(2))/radius^2, -(lmPos(mark,1) - SPos(1))/radius^2, -1];
Hw = eye(2);

%used to calulate K
S = Hx * P_cov * Hx' + Hw * W * Hw';

%Kalman gain
K = P_cov * Hx' * inv(S);

%predicted state from odometry
xHato = [SPos; robotbearing];
% disp('xHato')
% disp([xHato(1:2); xHato(3)*180/pi])

%update predicted state using new info
xHat = xHato + K * vErr;
% disp('xHat')
% disp([xHat(1:2); xHat(3)*180/pi])

%diff = [diff, (xHat - xHato)];
%diff = sign(diff);
% 
% figure(fig2)
% plot(diff(1,:))
% figure(fig3)
% plot(diff(2,:));
% figure(fig1)
% 

%split vector back up
SPos = xHat(1:2);

robotbearing = xHat(3);

%covariance matrix
P_cov = P_cov - K * Hx * P_cov;

%%
if (distance_of_landmark < old_distance)
    old_distance = distance_of_landmark;
end
if (old_distance < 0.3 && angle < 0 && angle > -10*pi/180)
   do_i_turn = 1; % turn left
    
end
if (old_distance < 0.3 && angle >=0 && angle < 10*pi/180)
    do_i_turn = -1; % turn right
end
%%
