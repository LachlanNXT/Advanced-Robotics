function headingVec = headingSim(pos, desiredHeading, desiredSpeed)
    headingVec = zeros(2,100);
    headingVec(:,1) = pos;
    for i = 2:100
        newHupper = desiredHeading + pi/8;
        newHlower = desiredHeading - pi/8;
        newHeading = newHlower*(i<50) + (((newHupper-newHlower)/2)+newHlower)*(i>49) + (newHupper-newHlower)/2.*rand();
        headingVec(:,i) = headingVec(:,i-1) + [desiredSpeed*cos(newHeading); desiredSpeed*sin(newHeading)];
    end
    plot(headingVec(1,:),headingVec(2,:));
end

%here is a new line