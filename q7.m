clear all;
close all;
clc;

% Using uigetfile to let user pick an Image
[jpgfile, jpgpath] = uigetfile({'*.jpg'}, 'Please pick a JPG Image.', '.\q7');
% Reading the image and Further assigning greyscale 
% and binary images to new variables
OG = imread(jpgfile);
grey = rgb2gray(OG);
bini = imbinarize(grey);

% Applying Roberts Cross Mask for Edge Detection
robertMask = edge(grey,"roberts");

% Morphological Operations to completely get number plate box
% Dilate mask with rectangle
dimensions = [2 28];
se = strel('rectangle', dimensions);
BWerode02 = imdilate(robertMask, se);

% Erode mask with rectangle
dimensions = [7 15];
se = strel('rectangle', dimensions);
BW2 = imerode(BWerode02, se);

% imclearborder to remove larger connected blobs
% that are touching the border
remConnObj = imclearborder(BW2);

% Using regionprops functions to get rid of 
% large irregular blobs
stats = struct2table(regionprops(remConnObj,{'Area','Solidity','PixelIdxList'}));
idx = stats.Solidity < 0.5 | stats.Area <10;
for kk = find(idx)'
  remConnObj(stats.PixelIdxList{kk}) = false;
end % end for

% Keeping the largest blob after eliminating 
% other large blob objects.
BW5 = bwareafilt(remConnObj, 1);

% Using imfill to fill any black pixels
filler = imfill(BW5, "holes");

% Using Erode and then Dilate to match size of the blob  
% to the approximate dimensions of all number plates. 
% Erode mask with line
length = 42.000000;
angle = 180.000000;
se = strel('line', length, angle);
BWerode02 = imerode(filler, se);

% Dilate mask with rectangle
dimensions = [25 30];
se = strel('rectangle', dimensions);
BWdilate02 = imdilate(BWerode02, se);

% Selecting the largest blob object in case additional objects.
final02 = bwareafilt(BWdilate02, 1);

% Increading width of the chosen number plate area.
length = 10.000000;
angle = 0.000000;
se = strel('line', length, angle);
final03 = imdilate(final02, se);

% Using regionprops boundingbox funtion to assign a 
% bounding box around our blob/object
objectSelect = regionprops(final03, "BoundingBox");
imshow(final03); hold on
for k = 1 : size(objectSelect)
    B = objectSelect(k).BoundingBox;
    rectangle("Position", B,"EdgeColor",'g','LineWidth',2);
end % end for

% Cropping the area of the bounding box into Original Image
croppedImg = imcrop(OG,objectSelect.BoundingBox);

% Converting Cropped Image into Greyscale Image
finalgrey = rgb2gray(croppedImg);
% Converting image to biniary
finalbinary = imbinarize(finalgrey);
% Inverting the binary image
invertedImage = ~finalbinary;
% Clearing border to remove connected elements.
FinalnoBorder = imclearborder(invertedImage);
% Applying majority filter with window 
% size 2 to clean the image
finalMajFil = majorityFilter(FinalnoBorder, 2);

% OCR. Filtering characters and training. 
textRead = ocr(finalMajFil,'CharacterSet','ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', ...
    'TextLayout','Word','Language','.\trainingOCR\tessdata\trainingOCR.traineddata');
recognizedText = textRead.Text;



% Displaying six images in a tiled layout.
figure;
tiledlayout(2,3);
nexttile;
imshow(robertMask);
title('Image After Edge Detection')

nexttile;
imshow(remConnObj);
title('After Initial Dialation and Erosion')

nexttile;
imshow(final03);
title('Removing Unwanted Objects')

nexttile;
imshow(croppedImg);
title('Cropped RGB Image')

nexttile;
imshow(finalMajFil);
title('Cropped Binary Image')

nexttile;
imshow(OG);
title('Original with OCR Results')
text(600, 150, recognizedText, 'BackgroundColor', [1 1 1]);

fprintf('The recognized in the number plate = %s\n',recognizedText);