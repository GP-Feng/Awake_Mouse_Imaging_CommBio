function [Offset]=correlation_line(frame,template)

    xline22=conj(fft(template-mean(template)));
    xline11=fft(frame-mean(frame));
    XC=ifftshift(ifft(xline11.*xline22));
[~,Offset]=max(XC);
width=length(XC);
Offset=Offset-floor(width./2)-1;
