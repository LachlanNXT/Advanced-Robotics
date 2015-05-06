function [triangles, squares, circles] = shapeTest(theBlobs, triangles, squares, circles)
ci = 1;
si = 1;
ti = 1;
for i = 1:max(size(theBlobs))
    if (theBlobs(i).circularity >= 0.85)
        %theBlobs(i).plot_box('blue')
        circles(ci) = i;
        ci=ci+1;
    end
    if ((theBlobs(i).circularity < 0.85) .* (theBlobs(i).circularity >= 0.7))
        %theBlobs(i).plot_box('red')
        squares(si) = i;
        si = si+1;
    end
    if (theBlobs(i).circularity < 0.7)
        %theBlobs(i).plot_box('green')
        triangles(ti) = i;
        ti = ti+1;
    end
end