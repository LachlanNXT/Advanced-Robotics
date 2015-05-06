%update

%measurement noise
sigr = (.02*randn); sigb = (.02*randn);
%measurement estimation, range and bearing angle
z = [dist+sigr; theta+sigb];
h = [nDist; nTheta];
%innovation
vErr = z - h;
%estimated covariance of sensor noise
W = [.02^2, 0; 0, .02^2];

%jacobians
r = dist;
Hx = [-(xD - nPos(1))/r, -(yD - nPos(2))/r, 0;
    (yD - nPos(2))/r^2, -(xD - nPos(1))/r^2, -1];
Hw = eye(2);

%used to calulate K
S = Hx * P_cov * Hx' + Hw * W * Hw';

%Kalman gain
K = P_cov * Hx' * inv(S);

%predicted state from odometry
xHato = [nPos; nPhi];

%update predicted state using new info
xHat = xHato + K * vErr;

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
nPos = xHat(1:2);

nPhi = xHat(3);

%covariance matrix
P_cov = P_cov - K * Hx * P_cov;


