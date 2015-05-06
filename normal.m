% Normal distribution
u = input('mean is ');
std = input('std is ');
min = u-4*std;
max = u+4*std;
diff = (max-min)/100;
x = min:diff:max;
g = 1./sqrt(std^2 * 2 * pi) .* exp(-.5 .* (x - u).^2 .* std^(-2));
plot(x,g);
