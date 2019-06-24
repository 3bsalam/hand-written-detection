function [ numberOfLines numberOfWords numberOfChars ] = TextAnalysis(I)

%% Convert to gray scale
I= imsharpen(I,'Radius',10,'Amount',4);
r = I(:,:,1);
g = I(:,:,2);
b = I(:,:,3);

%% red color
[H W L] = size(I);
t = 60;
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

if size(I,3) == 3 % RGB image
  I=rgb2gray(I);
end
[Hi Wi] = size(I);
[H W] = size(I);
 if H< 1204 || W< 3264
 I = imresize(I,[1204 3264]);
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
[H W L]=size(I);
%% Remove all object containing fewer than 30 pixels
I = bwareaopen(I, 400);
I = imclearborder(I);

s = regionprops(I,'centroid');
centroids = cat(1, s.Centroid);


X = centroids(:,1);
Y = centroids(:,2);

[sortedY, sortIndex] = sort(Y,'descend');
sortedX = X(sortIndex);

figure(3),imshow(I), title('Detected Line')


sz = 11;
MinP = [999999 99999];
MaxP = [0 0]; 
for i=1:sz
    if sortedX(i) < MinP(1)
        MinP(1) = sortedX(i);
        MinP(2) = sortedY(i);
    end
end

for i=1:sz
    if sortedX(i) > MaxP(1)
        MaxP(1) = sortedX(i);
        MaxP(2) = sortedY(i);
    end
end

hold on
plot(MinP(1),MinP(2), 'b*')
plot(MaxP(1),MaxP(2), 'b*')
plot([MinP(1) MaxP(1)],[MinP(2) MaxP(2)],'LineWidth',2,'Color','green');
hold off

X = [MinP(1) MaxP(1)];
Y = [MinP(2) MaxP(2)];    

slope = diff(Y)./diff(X);
angle = atan(slope) * 180/pi;

% 
% se = strel('line', .03*W, 180);
% se = strel('line', 20,90);
%   I = imdilate(I,se);
%   I = imerode(I,se2);
%   I = bwareaopen(I, 100);

%% number of lines final!!
% se = strel('line', 500, 180);
% se2 = strel('line',20, 90);
% I = imopen(I,se2);
%   I = imdilate(I,se);
%   I = imclose(I,se);

%% Lines Detection
I = imrotate(I,angle,'bilinear','loose');
rotated = I;
figure(4), imshow(I), title('Rotated Image');

se = strel('line', 500, 180);
se2 = strel('line',20, 90);
I = imopen(I,se2);
I = imdilate(I,se);
I = imclose(I,se);



I = bwareaopen(I, 100);
[L, number_of_cc] = bwlabel(I);
 Lines = regionprops(L, 'BoundingBox');
figure(5),imshow(I), title('Detected Lines')
 hold on
 
for n = 1 : size(Lines, 1)
  rectangle('Position',Lines(n).BoundingBox,'EdgeColor','g','LineWidth',2);
end
hold off
numberOfLines = size(Lines,1);

%% Chars Detection

% charstest(rotated);

[L, number_of_cc] = bwlabel(rotated);
 Chars = regionprops(L, 'BoundingBox');
figure(6),imshow(rotated), title('Detected Chars')
 hold on
 
for n = 1 : size(Chars, 1)
  rectangle('Position',Chars(n).BoundingBox,'EdgeColor','g','LineWidth',2);
end
hold off
numberOfChars = size(Chars,1);

%% Words Detectionr
rotated = imresize(rotated,[Hi Wi]);
  se = strel('line',.022*W,180);
 words = imclose(rotated,se);
[L, number_of_cc] = bwlabel(words);
 Words = regionprops(L, 'BoundingBox');
figure(7),imshow(words), title('Detected Words')
 hold on
 
for n = 1 : size(Words, 1)
  rectangle('Position',Words(n).BoundingBox,'EdgeColor','g','LineWidth',2);
end
hold off
numberOfWords = size(Words,1);


%% 



end

