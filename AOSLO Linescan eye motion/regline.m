function RegImg=regline(frame,Offset)
[H,W]=size(frame);
RegImg=zeros(H,W);
for ii2=1:H
    Off=Offset(ii2);
    if Off<0
        indx=1:W+Off;
        indx2=-Off+1:W;
    elseif Off>0
        indx=Off+1:W;
        indx2=1:W-Off;
    else
        indx=1:W;
        indx2=1:W;
    end
    RegImg(ii2,round(indx2))=frame(ii2,round(indx));
end