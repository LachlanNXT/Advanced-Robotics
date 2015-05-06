%Differential Simulation
%Lachlan Robinson
%function roboSim()

    clear
    close all
    landMarks = setupPlot(3);
    
    %load landMarks;
    nLandMarks = size(landMarks); nLandMarks = nLandMarks(2);
    fig1 = figure(1);
    fig2 = figure(2);
    %fig3 = figure(3);
    diff = [0;0;0];
    figure(fig1);
    pause(10)
    figure(fig1);
    plot(landMarks(1,:),landMarks(2,:),'r*') 
    axis equal
    axis([0,10,0,10]);
    hold on
    pos = [1;5];
    nPos = pos;
    posVec = pos;
    nPosVec = pos;
    phiDiffVec = 0;
    phi = pi/2;
    nPhi = phi;
    timestep = 0.1;
    %W = [0.01 0; 0 0.01];
    %V = W*timestep;
    P_cov = [0.01, 0, 0; 0, 0.01, 0; 0, 0, pi/180];
%     omegaVec = -1 + (1-(-1)).*rand(1,5);
%     vVec = rand(1,5);
%     steps = randi([0 150],1,5);
%    save('runParameters1', 'omegaVec', 'vVec', 'steps');
    vVec = .5;
    omegaVec = -.125;
    steps = 9999;
    %load runParameters
    wheelBase = 0.1;
    botLength = 0.2;
    %wheelRadius = 0.056/2; %56mm/2
    %vL = (2*v + phi * wheelBase)/(2 * wheelRadius);
    %vR = (2*v + phi * wheelBase)/(2 * wheelRadius);
    
    %Dynamics
%     xdot = v * cos(phi);
%     ydot = v * sin(phi);
%     phidot = omega;
   
    seen = zeros(1,10);
    %botSim
    for curve = 1:length(vVec)
        display(curve);
        omega = omegaVec(curve); v = vVec(curve);
        V = diag([(v*timestep*0.2)^2, (omega*timestep*0.2)^2]);
    for interval = 0:steps(curve)
        %derivatives
        xdot = v * cos(phi)*timestep;
        ydot = v * sin(phi)*timestep;
        phidot = omega*timestep;
        dd = v*timestep;
        %position updates - real position
        pos(1) = pos(1)+xdot;
        pos(2) = pos(2)+ydot;
        phi = phi+phidot;
        %prediction with noise - encoder position
        Vxdot = ((xdot*.2).*randn); Vydot = ((ydot*.2).*randn); Vphidot = ((phidot*.2).*randn);
        nPos(1) = nPos(1)+xdot+Vxdot;
        nPos(2) = nPos(2)+ydot+Vydot;
        nPhi = nPhi+phidot+Vphidot;
        
        phiDiff = nPhi - phi;
        
        phiDiffVec = [phiDiffVec; phiDiff];
        
        figure(fig2)
        plot(phiDiffVec)
        figure(fig1)
        
        %V = diag([mean([Vxdot, Vydot])^2, Vphidot^2]);
        
        %tracking path
        posVec = [posVec pos];
        %nPosVec = [nPosVec nPos];
        
        prediction

    for mark = 1 : nLandMarks
        xD = landMarks(1,mark) - pos(1);
        yD = landMarks(2,mark) - pos(2);
        nxD = landMarks(1,mark) - nPos(1);
        nyD = landMarks(2,mark) - nPos(2);
        
        dist = sqrt(xD^2 + yD^2);
        mark;
        theta2 = atan2(yD,xD);
        theta = theta2;%atan2(yD,xD) - mod(phi,2*pi)
        
        nDist = sqrt(nxD^2 + nyD^2);
        nTheta = atan2(nyD,nxD) - mod(nPhi,2*pi);
        
        max = mod(phi,2*pi)+pi/6;
        min = mod(phi,2*pi)-pi/6;
        if max>pi
            max = max-2*pi;
        end
        if min>pi
            min = min-2*pi;
        end

        if ((theta2 < max && theta2 > max-pi/3) || (theta2 > min && theta2 < min+pi/3))
        %if (abs(theta<pi/6));
        seen(mark) = dist;
        
        update
        
        else
        seen(mark) = 0;
        end
        
    end
    
    nPosVec = [nPosVec nPos];
        
    botX = [pos(1)-cos(pi/2-phi)*wheelBase, pos(1)+cos(pi/2-phi)*wheelBase];
    botY = [pos(2)+sin(pi/2-phi)*wheelBase, pos(2)-sin(pi/2-phi)*wheelBase];
    triangleX = [pos(1), pos(1)+cos(phi)*botLength];
    triangleY = [pos(2), pos(2)+sin(phi)*botLength];
    sightLX = [pos(1), pos(1)+cos(phi+pi/6)*2];
    sightLY = [pos(2), pos(2)+sin(phi+pi/6)*2];
    sightRX = [pos(1), pos(1)+cos(phi-pi/6)*2];
    sightRY = [pos(2), pos(2)+sin(phi-pi/6)*2];
    
    %botPlot
    botPlot
    
    pause(0.000001)
    
    end
    end
    %Simulation
%     
%     isGood = 0;
%     while isGood == 0
%         headingVec = headingSim(pos, desiredHeading, desiredSpeed);
%         isGood = input('is this good? ');
%     end





   
        
        

%end