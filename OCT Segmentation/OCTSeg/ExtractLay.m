function [ILM,RPE,IPL]=ExtractLay(AllLayer)
AllLayer=permute(AllLayer,[2,3,1]);

[WX,WY,H]=size(AllLayer);

ILM=zeros(WX,WY);
IPL=zeros(WX,WY);
RPE=zeros(WX,WY);
for ii5=1:WX
    for ii6=1:WY
        if ~(isnan(sum(AllLayer(ii5,ii6,:)))||sum(AllLayer(ii5,ii6,:))==0)
            layloc=find(AllLayer(ii5,ii6,:));
            ILM(ii5,ii6)=layloc(1);
            IPL(ii5,ii6)=layloc(2);
            RPE(ii5,ii6)=layloc(end);
        else
            ILM(ii5,ii6)=nan;
            IPL(ii5,ii6)=nan;
            RPE(ii5,ii6)=nan;
        end
    end
end

