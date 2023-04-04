function [C1, C2]=EdgeDetection(Img,thresholds)
[H,W]=size(Img);
%% Edge detection
w1=0.7;w2=0.3;
ent=entropyfilt(Img);
Img=imgaussfilt(Img,[3,25]);
maskInt=Img>50;% Intensity mask
[~,W]=size(Img);
% Canny
for ii1=1:3
    Edg(:,:,ii1)=edge(Img,'canny',thresholds(ii1)).*thresholds(ii1);
end
Edg=sum(Edg,3);
% Gradient
[~,grad]=gradient(Img,10);
grad1=grad.*(grad>0);
grad2=-grad.*(grad<0);
for ii2=1:W    
    grad1(:,ii2)=grad1(:,ii2)./mean(grad1(:,ii2));
    grad2(:,ii2)=grad2(:,ii2)./mean(grad2(:,ii2));
end
grad1=grad1./max(max(grad1));
grad2=grad2./max(max(grad2));
C1=(w1.*Edg.*(grad>0)+w2.*grad1).*maskInt;
C2=(w1.*Edg.*(grad<0)+w2.*grad2).*maskInt;


ent=imgaussfilt(ent,[5,25]);
entmask=ent<0.2;
entmask(1:(end-5),:)=entmask(6:end,:);
C1=C1.*entmask;
C2=C2.*entmask;