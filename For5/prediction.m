%prediction


Fx = [1, 0, (-dd * sin(phi + phidot));
     0, 1, (dd * cos(phi + phidot));
     0, 0, 1];
Fv = [cos(phi + phidot), (-dd * sin(phi + phidot));
     sin(phi+phidot), (dd * cos(phi + phidot));
     0, 1]; 
        
P_cov = Fx * P_cov * Fx' + Fv * V * Fv';
        