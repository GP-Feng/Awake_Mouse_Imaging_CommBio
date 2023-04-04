function [Output]=YSearch(Boundry)
brgval=0.1;
[WX,WY]=size(Boundry);
Output=zeros(WX,WY);
minval=min(min(Boundry));
H=max(max(Boundry))-minval+20;
for ii1=1:WX
    section=squeeze(Boundry(ii1,:))-minval+10;
    Map=zeros(H,WY);
    for ii2=1:WY
        if ~isnan(section(ii2))
            Map(section(ii2),ii2)=1;
        end
    end
    nanrow=isnan(section);
    Map=Detour(Map,nanrow,brgval,'upper');   
%     figure(3);imshow(Map,[])
    [pathx,pathy] = ShortestPathSearch(Map,Map,1e-5,0,0.5);
    Map2=zeros(H,WY);
    for ii2=1:length(pathx)
        Map2(pathy(ii2),pathx(ii2))=1;
    end
%     figure(2);imshow(Map2,[])
    for ii2=1:WY
        ind=find(Map2(:,ii2))+minval-10;
        Output(ii1,ii2)=ind(1);
    end
    Output(ii1,nanrow)=nan;
end