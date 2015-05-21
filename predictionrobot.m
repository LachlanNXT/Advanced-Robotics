%prediction

Fx = [1, 0, (-v * sin(phi + phidot));
     0, 1, (v * cos(phi + phidot));
     0, 0, 1];
Fv = [cos(phi + phidot), (-v * sin(phi + phidot));
     sin(phi+phidot), (v * cos(phi + phidot));
     0, 1]; 
        
P_cov = Fx * P_cov * Fx' + Fv * V * Fv';
        