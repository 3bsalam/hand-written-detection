    function [ out ] = preprocessing( I )
%% Show image
Original = I;
% figure(1),imshow(I) ,title('INPUT IMAGE WITH NOISE')
r = I(:,:,1);
g = I(:,:,2);
b = I(:,:,3);

%% red color
[H W L] = size(I);
t = 105;
for i = 1:H
    for j = 1:W
       if ((r(i,j) >t)  && (g(i,j)> t) && (b(i,j) >t)  )
           r(i,j) =255;
           g(i,j) = 255;
       b(i,j) = 255;
       else 
            r(i,j) =0;
           g(i,j) = 0;
           b(i,j) = 0;
       end
    end
end
I(:,:,1) = r;
I(:,:,2) = g;
I(:,:,3) = b;

 
% figure(2),imshow(I) ,title('black and white photo')
%% Convert to gray scale
I= imsharpen(I,'Radius',11,'Amount',5);
if size(I,3) == 3 % RGB image
  I=rgb2gray(I);
end
[H W] = size(I);
if H< 400 || W< 800
 I = imresize(I,[400 1000]);
end
%% apply Gaussien
   I = imgaussfilt(I,1);
 I = imadjust(I);
[H W] = size(I);
%% Convert to binary image
threshold = graythresh(I);
I = imbinarize(I,threshold);

%% Check whether the background is white or black
numWhitePixels = sum(sum(I));
numBlackPixels = (H * W) - numWhitePixels;

if numWhitePixels > numBlackPixels
    I = ~I;
end

%% Remove all object containing fewer than 30 pixels
I = bwareaopen(I, 30);
I = imclearborder(I);
TextImage = Original;
%% Dilate Image
se = strel('disk',floor(W*.05));
I = imdilate(I,se);

%% Closing 
se = strel('disk',floor(W*.03));
I = imclose(I,se);
%% erode image
% se = ones(5,10);
%  se = strel('square',1)
%  I = imopen(I,se);
 
%  I = bwareaopen(I, 10);
%% Show binary image
%  figure(3),imshow(I), title('dilation to detect biggest object')
%% Find the text and crop
% figure(4),imshow(I), title('Cropped Object')
[L, number_of_cc] = bwlabel(I); 
Tstat = regionprops(L,'Centroid','Area','PixelIdxList');
TextObjects = regionprops(L, 'BoundingBox');
[maxValue,index] = max([Tstat.Area]);
%% crop
TextImage = TextObjects(index);
TextImage = imcrop(Original,TextImage.BoundingBox);
out= TextImage;
end

