function landMarks = setupPlot(num)
    close all
    figure(1);
    axis([0,10,0,10]);
    axis equal
    landMarks = zeros(2,num);
    for i = 1:num
        landMarks(:,i) = 10*rand(2,1);
    end
    %plot(landMarks(1,:),landMarks(2,:),'ro')
    hold on
    save landMarks
    %pause(5)
end