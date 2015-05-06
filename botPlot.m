%plot
    plot(landMarks(1,:),landMarks(2,:),'k*')
    axis equal
    axis([0,10,0,10]);
    
    hold on
    
    for u = 1:10;
        if seen(u) ~= 0
            plot(landMarks(1,u),landMarks(2,u),'g*')
        end
    end

    plot(botX,botY)
    plot(triangleX,triangleY)
    plot(sightLX, sightLY, 'g');
    plot(sightRX, sightRY, 'g');
    plot(posVec(1,:),posVec(2,:));
    plot(nPosVec(1,:),nPosVec(2,:), 'r');
    error_ellipse(P_cov(1:2,1:2), [nPos(1); nPos(2)])
    hold off