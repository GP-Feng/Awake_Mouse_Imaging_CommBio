function [Im,W,fnum,mask,mask2]=ReadOCT(filename,disc,radii,flag2)

mov=VideoReader(filename);
mov.CurrentTime=0;
ii2=1;
while hasFrame(mov)
    Img =mean(readFrame(mov),3);
    Im(:,:,ii2) = Img(25:393,538:1476);
    profile=mean(Im(:,:,ii2),2);
    Winidx=find(profile>=(0.8*max(profile)));
    Winidxx=Winidx(1)+(-10:60);
    H=size(Im(:,:,ii2),1);
    threshold=max(max(Im(:,:,ii2)))./exp(2);
    enface(:,ii2)=sum((Im(:,:,ii2)>threshold))./mean(mean(Im(:,:,ii2)));
    zeromap(:,ii2)=sum(double(~logical(Im(Winidxx,:,ii2))));
    ii2=ii2+1;
end
[W,fnum]=size(enface);



if isempty(disc)
    mask=ones(W,fnum);
else
    y0=disc(1);
    x0=disc(2);
    xmk=linspace(-1,1,W);
    x0=xmk(x0);
    ymk=linspace(-1,1,fnum);
    y0=ymk(y0);
    [ymk,xmk]=meshgrid(ymk,xmk);
    mask=double(sqrt((xmk-x0).^2+(ymk-y0).^2)>radii);
    
end

mask2=zeros(W,fnum);
mask2(zeromap>(80*0.5))=nan;
mask(mask==0)=nan;

figure;imagesc(zeromap);

% 
if flag2
    figure(111);imagesc(enface)
    figure(222);imagesc(~isnan(mask).*enface)
end
