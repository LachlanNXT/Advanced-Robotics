classdef PiBot < handle
    
    properties(Access = public)
        TCP_MOTORS;
        TCP_CAMERA;
    end
    
    properties (Access = private, Constant)
        TIMEOUT = 2;
        
        PORT_MOTORS = 43900; % some random ports that should be unused as they are above 2000?
        PORT_CAMERAS = 43901;
        
        IMAGE_WIDTH = 640/2;
        IMAGE_HEIGHT = 480/2;
        IMAGE_SIZE = PiBot.IMAGE_WIDTH * PiBot.IMAGE_HEIGHT * 3;
        
        FN_ARG_SEPARATOR = ','
        FN_GET_IMAGE = 'getImageFromCamera'
        FN_MOTOR_SPEEDS = 'setMotorSpeeds'
        FN_MOTOR_TICKS = 'getMotorTicks'
    end
    
    methods
        function obj = PiBot(address)
            % TODO: Can this function handle DNS names as well as IP
            % addresses or are the addresses not resolved??? (Answer will
            % depend on what MATLAB's 'tcpip' object does internally).
            
            % TODO: Send system request to Pi to run terminal command
            % 'server-motors', 'server-camera'
            
            obj.TCP_MOTORS = tcpip(address, PiBot.PORT_MOTORS, 'NetworkRole', 'client', 'Timeout', 2);
            obj.TCP_CAMERA = tcpip(address, PiBot.PORT_CAMERAS, 'NetworkRole', 'client', 'Timeout', 2);
            
            % Configure the TCPIP objects
            %obj.TCP_CAMERA.Timeout = PiBot.TIMEOUT;
            %obj.TCP_MOTORS.Timeout = PiBot.TIMEOUT;
            obj.TCP_CAMERA.InputBufferSize = PiBot.IMAGE_SIZE;
            
        end
        
        function delete(obj)
            delete(obj.TCP_MOTORS);
            delete(obj.TCP_CAMERA);
        end
        
        function imgVect = getVectorFromCamera(obj)
            fopen(obj.TCP_CAMERA);
            fprintf(obj.TCP_CAMERA, [PiBot.FN_GET_IMAGE PiBot.FN_ARG_SEPARATOR '100']); % TODO FIX THE NO ARG HACK
            data = fread(obj.TCP_CAMERA, PiBot.IMAGE_SIZE, 'uint8')./255;
            fclose(obj.TCP_CAMERA); 
%             img = zeros(PiBot.IMAGE_WIDTH, PiBot.IMAGE_HEIGHT, 3);
            it = 1;
            
            imgVect = data;
        end 
        
        function img = getImageFromCamera(obj)
            vector = obj.getVectorFromCamera();
            
%             for jj = 1:size(img,2) % loop through columns
%                 for ii = 1:size(img,1) % loop through rows
%                     for kk = 1:size(img,3)
%                         if (length(data) ~= PiBot.IMAGE_SIZE)
%                             img = [];
%                             return;
%                         end 
%                         img(ii,jj,kk) = data(it); 
%                         it = it + 1;
%                     end
%                 end
%             end
            
            % image rotated so now changing back.
%             img = flip(img); % there is probably a better way but meh
            img = vect2img(vector);
        
        end
        
        function setMotorSpeeds(obj, motors, powers)
            % Most of what's going on here is on the Pi
            if  ~ischar(motors)
                error('PiBot:argCheck', 'Invalid arguments: motors(arg1) must be a characters for the targeted motors (e.g. [''A'' ''C''])\npowers(arg2): vector of integer powers in range -255 to 255 for targetted motors (e.g. [255 -255])');
            elseif min(powers) < -255 || max(powers) > 255
                error('PiBot:argCheck', 'Invalid arguments: powers(arg2): must be vector of values in range -255 to 255 for targeted motors (e.g. [255 -255])');
            elseif length(motors) ~= length(powers)
                error('PiBot:argCheck', 'Invalid arguments: (length(arg1) must equal length(arg2)');
            end
            
            data = [PiBot.FN_MOTOR_SPEEDS];
            for k = 1:length(powers)
                data = [data PiBot.FN_ARG_SEPARATOR motors(k) PiBot.FN_ARG_SEPARATOR num2str(int16(powers(k)))];
            end
            
            fopen(obj.TCP_MOTORS);
            fprintf(obj.TCP_MOTORS, data);
            fclose(obj.TCP_MOTORS);
        end
        
        function ticks = getMotorTicks(obj)
            data = [PiBot.FN_MOTOR_TICKS,PiBot.FN_ARG_SEPARATOR 'A']; % needed for the Pi code
            fopen(obj.TCP_MOTORS); 
            fprintf(obj.TCP_MOTORS, data); 
            
            % We don't know the size of the file so...
            c='';
            s='';
            while ~strcmp(char(c),':')
                c = ( fread(obj.TCP_MOTORS,1,'char') );
                s=[s c];
            end

            fclose(obj.TCP_MOTORS);
            % Convert ticks to numerical array
            ticks = sscanf(s,'%f',inf);
            

        end
    end
end