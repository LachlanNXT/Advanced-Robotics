function [ img ] = vect2img( data )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

        
        IMAGE_WIDTH = 640/2;
        IMAGE_HEIGHT = 480/2;
            img = zeros(IMAGE_WIDTH, IMAGE_HEIGHT, 3);
            it = 1;
            tic;
            
            for jj = 1:size(img,2) % loop through columns
                for ii = 1:size(img,1) % loop through rows
                    for kk = 1:size(img,3)
                        if (length(data) ~= 320*240*3)
                            img = [];
                            return;
                        end 
                        img(ii,jj,kk) = data(it); 
                        it = it + 1;
                    end
                end
            end
end

