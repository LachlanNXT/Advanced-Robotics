IP = '172.19.226.39';
pb = PiBot(IP);
img = pb.getImageFromCamera();

while(isempty(img))

img = pb.getImageFromCamera();
pause(.1);

end

imshow(img);
save