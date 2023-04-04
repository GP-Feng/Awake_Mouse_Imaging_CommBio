function [Xoff,Yoff,peak,Corr]=EvaOffset(frame,template,Xo,Yo,flag)
frame=gpuArray(frame);
template=gpuArray(template);
if flag==1
    
    Sobel = gpuArray([1 2 1;0 0 0;-1 -2 -1]+[1 0 -1;2 0 -2;1 0 -1]);

    % Edge information
    frame = (conv2(frame,Sobel,'same'));
    frame = medfilt2(frame,[5,5]);
    template = (conv2(template,Sobel,'same'));
    template = medfilt2(template,[5,5]);
    
end
C = (normxcorr2(template,frame));
% C=C(147:1454,336:1506);
peak=max(max(C));
[ypeak,xpeak]=find(C==peak);
Yoff = ypeak-Yo;
Xoff = xpeak-Xo;
Corr=C;