%normal 2d
pos = input('pos vector vertical ');
C = input('std dev matrix ');

minx = pos(1) - 4*C(1,1);
maxx = pos(1) + 4*C(1,1);
miny = pos(2) - 4*C(2,2);
maxy = pos(2) + 4*C(2,2);
diffx = (maxx-minx)/100;
diffy = (maxy-miny)/100;
x = minx:diffx:maxx;
y = miny:diffy:maxy;
vec = [x;y];
xV = x./x;
posvec = [pos(1)*xV; pos(2)*xV];
g = 1./(sqrt(det(C))* 2 * pi) .* exp(-.5 .* (vec - posvec)' * inv(C) *(vec - posvec));
[X Y] = meshgrid(-50:1:51);
surf(x,y,g);
