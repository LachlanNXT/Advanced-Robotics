%predictionrobot

Fx = [1, 0, (-v * sin(robotbearing + w));
     0, 1, (v * cos(robotbearing + w));
     0, 0, 1];
Fv = [cos(robotbearing + w), (-v * sin(robotbearing + w));
     sin(robotbearing+w), (v * cos(robotbearing + w));
     0, 1]; 
        
P_cov = Fx * P_cov * Fx' + Fv * V * Fv';
        