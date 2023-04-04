function Curv=FindCurv(Img,ref)

[H,W]=size(Img);
CORR=zeros(H,W);
ga=conj(fft(Img(:,ref)));
for iij=1:W
    gb=fft(Img(:,iij));
    CORR(:,iij)=fftshift(ifft(ga.*gb./abs(ga.*gb+1e-9)));
end
CORR=medfilt2(CORR,[7,7]);
% Curv(ref)=0;
for iij=1:W
    [~,Curv(iij)]=max(CORR(:,iij));
    Curv(iij)=Curv(iij)-round(H/2);
end
Curv(ref)=0;
% Curv(abs(Curv)>100)=0;
% figure;plot(Curv)
