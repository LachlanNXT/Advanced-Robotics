%Differential Simulation
%Lachlan Robinson
%function roboSim()

    %clear
    close all
    %landMarks = setupPlot(1);
    landMarks = [9;9];
    save landMarks;
    load landMarks;
    landMarks = landMarks(:,1);
    nLandMarks = size(landMarks); nLandMarks = nLandMarks(2);
    FigHandle = figure('Position', [50, 50, 1300, 500]);
    fig1 = subplot(1,4,1);
    title('Simulation');
    fig2 = subplot(1,4,2);
    title('phi (blue) nPhi (red)');
    fig3 = subplot(1,4,3);
    title('theta (blue) nTheta (red)');
    fig4 = subplot(1,4,4);
    %diff = [0;0;0];
    subplot(fig1);
    pause(3)

    plot(landMarks(1,:),landMarks(2,:),'r*') 
    axis equal
    axis([0,10,0,10]);
    hold on
    pos = [1;5];
    nPos = pos;
    posVec = pos;
    nPosVec = pos;
    %phiDiffVec = 0;
    phiVec = 0;
    thetaVec = 0;
    nphiVec = 0;
    nthetaVec = 0;
    phiaVec = 0;
    nphiaVec = 0;
    phi = -pi/2;
    nPhi = phi;
    timestep = 0.2;
    %W = [0.01 0; 0 0.01];
    %V = W*timestep;
    load covar_mat
    %P_cov = [0.01, 0, 0; 0, 0.01, 0; 0, 0, pi/180];
%     omegaVec = -1 + (1-(-1)).*rand(1,5);
%     vVec = rand(1,5);
%     steps = randi([0 150],1,5);
%    save('runParameters1', 'omegaVec', 'vVec', 'steps');
    vVec = .5;
    omegaVec = .125;
    steps = 9999;
    std_dev = 0.2;
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
        V = diag([(v*timestep*std_dev)^2, (omega*timestep*std_dev)^2]);
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
        Vxdot = (xdot*(std_dev.*randn)); Vydot = (ydot*(std_dev.*randn)); Vphidot = (phidot*(std_dev.*randn));
        nPos(1) = nPos(1)+xdot+Vxdot;
        nPos(2) = nPos(2)+ydot+Vydot;
        nPhi = nPhi+phidot+Vphidot;
        
        %phiDiff = nPhi - phi;
        
        %phiDiffVec = [phiDiffVec; phiDiff];
        
        %figure(fig2)
        %plot(phiDiffVec)
        %figure(fig1)
        
        %V = diag([mean([Vxdot, Vydot])^2, Vphidot^2]);
        
        %tracking path
        posVec = [posVec pos];
        phiVec = [phiVec phi];
        nphiVec = [nphiVec nPhi];
        subplot(fig2);
        plot(phiVec, 'b');
        hold on
        plot(nphiVec,'r');
        title('phi (blue) nPhi (red)');
        subplot(fig1);
        %nPosVec = [nPosVec nPos];
        
        prediction

    for mark = 1 : nLandMarks
        xD = landMarks(1,mark) - pos(1);
        yD = landMarks(2,mark) - pos(2);
        nxD = landMarks(1,mark) - nPos(1);
        nyD = landMarks(2,mark) - nPos(2);
        
        dist = sqrt(xD^2 + yD^2);
        
        nDist = sqrt(nxD^2 + nyD^2);
        
        phiAngle = mod(phi,2*pi);
        if (phiAngle > pi)
            phiAngle = phiAngle - 2*pi;
        end
        
        nphiAngle = mod(nPhi,2*pi);
        if (nphiAngle > pi)
            nphiAngle = nphiAngle - 2*pi;
        end
        
        theta = atan2(yD,xD) - phiAngle;
        phiaVec = [phiaVec phiAngle];
        theta = mod(theta, 2*pi);
        if (theta>pi) theta = theta - 2*pi; end;
                    
        nTheta = atan2(nyD,nxD) - phiAngle;
        nphiaVec = [nphiaVec nphiAngle];
        nTheta = mod(nTheta, 2*pi);
        if (nTheta>pi) nTheta = nTheta - 2*pi; end;
        
        thetaVec = [thetaVec theta];
        nthetaVec = [nthetaVec nTheta];
        subplot(fig3)
        plot(thetaVec, 'b')
        hold on
        plot(nthetaVec,'r');
        title('theta (blue) nTheta (red)');
        subplot(fig4)
        plot(phiaVec, 'b')
        hold on
        plot(nphiaVec, 'r')
        title('pniAngle (blue) nphiAngle (red)')
        subplot(fig1)
        
        max = pi/6;
        min = -pi/6;

        if ((theta < max && theta > max-pi/3) || (theta > min && theta < min+pi/3))
        
        seen(mark) = dist
        if (mark == 1)
        %test = [atan2(yD,xD)*180/pi, theta*180/pi, phiAngle*180/pi]
        %pause(0.1)
        end
        
        %updatee
        
        else
        seen(mark) = 0
        if (mark == 1)
        %test = [atan2(yD,xD)*180/pi, theta*180/pi, phiAngle*180/pi]
        %pause(0.1)
        end
        end
        
    end
    
    nPosVec = [nPosVec nPos];
        
    botX = [pos(1)-cos(pi/2-phi)*wheelBase, pos(1)+cos(pi/2-phi)*wheelBase];
    botY = [pos(2)+sin(pi/2-phi)*wheelBase, pos(2)-sin(pi/2-phi)*wheelBase];
    triangleX = [pos(1), pos(1)+cos(phi)*botLength];
    triangleY = [pos(2), pos(2)+sin(phi)*botLength];
    sightLX = [pos(1), pos(1)+cos(phi+pi/6)*15];
    sightLY = [pos(2), pos(2)+sin(phi+pi/6)*15];
    sightRX = [pos(1), pos(1)+cos(phi-pi/6)*15];
    sightRY = [pos(2), pos(2)+sin(phi-pi/6)*15];
    
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