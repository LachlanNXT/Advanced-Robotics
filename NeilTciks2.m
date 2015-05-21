IP = '172.19.226.39';
pb = PiBot(IP);

ticks1 = pb.getMotorTicks()


%while actualticks < 900
%    ticks2 = pb.getMotorTicks();
%    actualticks = ticks2-ticks1
    
%end

pb.setMotorSpeeds('A',255)
pb.setMotorSpeeds('B',255)
pause (1)
pb.setMotorSpeeds('A',0)
pb.setMotorSpeeds('B',0)

ticks2 = pb.getMotorTicks()
actualticks = ticks2-ticks1
    