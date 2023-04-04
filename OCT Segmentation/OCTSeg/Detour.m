function Output=Detour(Edge,mask,brgval,side)
Output=Edge;
bounds=zeros(size(mask));
bounds(2:end)=diff(mask)>0;
bounds(1:end-1)=bounds(1:end-1)+(diff(mask)<0);
bounds=logical(bounds);
if sum(mask)
    if strcmp(side,'lower')
        Output(:,mask)=0;Output(end,mask)=brgval;
        Output(:,bounds)=brgval;
    elseif strcmp(side,'upper')
        Output(:,mask)=0;Output(1,mask)=brgval;
        Output(:,bounds)=brgval;
    else
        Output(:,mask)=0;Output(side,mask)=brgval;
        Output(:,bounds)=brgval;
    end
end
