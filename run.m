close all
I = imread('Case.2.2.jpg');
%%  pre proccess the image
CleanedImage = preprocessing(I);
% figure(1),imshow(CleanedImage), title('Detected Text')
%% Analyse Text
[ numberOfLines numberOfWords numberOfChars ] = TextAnalysis(CleanedImage);