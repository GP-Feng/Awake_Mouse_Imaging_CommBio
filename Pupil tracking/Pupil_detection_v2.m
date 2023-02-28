function [centers, asp_ratio, boundary] = Pupil_detection_v2(Img)


% figure(1)
% imshow(Img,[])
%% Texture detection std filter
I2=imgaussfilt(Img,[1,1]);

I2=imgaussfilt(rescale(stdfilt(Img)),[2,2]);
% figure(2)
% imshow(I2,[0 0.3])
BW1 = ~imbinarize(I2, .25);
BW1 = (BW1-(Img<85))>0;
% figure(3)
% imshow(BW1,[])
se = strel('line',3,4);
%% Watershed segmentation (pupil region)
D = -bwdist(BW1);
D(~BW1)=-inf;
DL=watershed(-D);
DL(~BW1)=0;
[count,binloc]=imhist(DL);
BW1(ismember(DL,binloc(count<400)))=0;
BW1(ismember(DL,binloc(count>10000)))=0;
if sum(BW1(:))~=0
%% Find intensity
Img_filt = imgaussfilt(Img);
pupil_I = Img_filt.*BW1;
BW2 = ((Img_filt-mean(pupil_I(pupil_I~=0))).^2)<(0.7*std(pupil_I(pupil_I~=0)).^2);
BW3 = BW1|BW2;
D = -bwdist(BW3);
D(~BW3)=-inf;
DL=watershed(-D);
DL(~BW3)=0;
Overlap = DL(BW1);
DL(~mode(Overlap))=0;

[count,binloc]=imhist(uint8(DL),256);
[~,max_indx]=max(count(2:end));
BW3=DL==binloc(max_indx+1);

% Remove strike reflection

BW3 = imdilate(BW3,se);
D = -bwdist(BW3);
D(BW3)=-inf;
DL=watershed(-D);
DL(BW3)=0;
[count,binloc]=imhist(DL);
BW3(ismember(DL,binloc(count<400)))=1;
% BW3 = imdilate(BW3,se);


%% Extract geometric params
B = bwboundaries(BW3);
boundary = B{1};
mask=poly2mask(boundary(:,2),boundary(:,1),size(I2,1),size(I2,2));
% figure(90);imshow(mask,[]);
[r, c] = find(BW3 == 1);
centers = [mean(c), mean(r)];
asp_ratio = (max(r)-min(r))/(max(c)-min(c));
if sum(double(mask(:)))>12000
    centers = [nan, nan];
    asp_ratio =nan;
    boundary = nan;
end

else
    centers = [nan, nan];
    asp_ratio =nan;
    boundary = nan;
end

% figure(4)
% imshow(BW3,[])
% hold on
% DrawEllip(centers(1),centers(2),(max(boundary(:,2))-min(boundary(:,2)))/2,(max(boundary(:,1))-min(boundary(:,1)))/2)
