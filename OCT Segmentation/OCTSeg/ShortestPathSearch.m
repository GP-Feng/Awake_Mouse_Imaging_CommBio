function [pathx,pathy] = ShortestPathSearch(Edg,Img,wmin,lambda,wv)
Edg=(Edg-min(min(Edg)))./(max(max(Edg))-min(min(Edg)));
Img=(Img-min(min(Img)))./(max(max(Img))-min(min(Img)));
[H,W]=size(Edg);
AA=zeros(H,W+2);AA2=AA;
AA(:,2:end-1)=Edg;
AA2(:,2:end-1)=Img;
AA(:,1)=1;AA(:,end)=1;
AA2(:,1)=1;AA2(:,end)=1;
AA2(:,1)=mean(mean(Img));AA2(:,end)=mean(mean(Img));
%% adjacency matrix
[H,W]=size(AA);
indx=mod(0:(H*W)-1,W)+1;
indy=floor((0:(H*W))./W)+1;
spind1=zeros(1,H*W*9);
spind2=zeros(1,H*W*9);
spweight=zeros(1,H*W*9);
ii2=1;
for ii1=1:(H*W)
    ind1=indx(ii1);
    ind2=indy(ii1);
    wa=AA(ind2,ind1);
    ia=AA2(ind2,ind1);
    for iix=-1:1
        if (iix+ind1)>0&&(iix+ind1)<=W
            ind3=iix+ind1;
            for iiy=-1:1
                if (iiy+ind2)>0&&(iiy+ind2)<=H
                    ind4=iiy+ind2;
                    indA=ind3+(ind4-1)*W;
                    spind1(ii2)=indA;
                    spind2(ii2)=ii1;
                    wb=AA(ind4,ind3);
                    ib=AA2(ind4,ind3);
                    spweight(ii2)=(2-(wa+wb))+wmin+abs(ia-ib)*lambda+wv.*abs(iiy);

%                     spweight(ii2)=spweight(ii2)+wv.*abs(iiy);
                    ii2=ii2+1;
                end  
            end
        end
    end 
end
spind2(spind1==0)=[];
spweight(spind1==0)=[];
spind1(spind1==0)=[];
spweight(spind1==spind2)=0;
AdjM=sparse(spind1,spind2,spweight,H*W,H*W);
%% Build node label matrix
node=cell(H*W,1);
for ii2=1:H*W
    node{ii2}=int2str(ii2);
end
%% Shortest path search
G=graph(AdjM,node,'upper');
p = shortestpath(G,1,H*W,'Method','positive');
%% Covert node indices into image coordinate
pathx=zeros(1,length(p));pathy=pathx;
for ii3=1:length(p)
    ind=p(ii3);
    pathx(ii3)=indx(ind);
    pathy(ii3)=indy(ind);
end
% clean the additional route
pathx=pathx-1;
pathx(pathx==(W-1))=0;
pathy(pathx==0)=[];
pathx(pathx==0)=[];
