function [ILM, RPE,IPL]=OCTSegmentation(dir,filename,disc,radii,flag,flag2,flag3)
%% Read data from .avi
[Im,~,fnum,maskv,maskfo]=ReadOCT([dir,filename],disc,radii,flag2);
if flag3
    filename2=[dir,'Seg_',filename];
    aviobj=VideoWriter(filename2);
    aviobj.FrameRate = 10;
    open(aviobj)
end

%% Edge detection
for ii0=1:fnum
    Img=Im(:,:,ii0).^2;
    thresholds=[.1,.4,.7];
    [Edg1(:,:,ii0),Edg2(:,:,ii0)]=EdgeDetection(Img,thresholds);
end

%% Find boundries on B-scan section
% close all
brgval=1;
for ii1=1:fnum
    ii1
    Img=Im(:,:,ii1);
    [H,W]=size(Img);
    [flatC1,flatC2,flatImg,RPE,RPEloc]=Flattening_Corr(Edg1(:,:,ii1),Edg2(:,:,ii1),Img,[-75,20],maskfo(:,ii1));
    
    nanrow=isnan(maskv(:,ii1));
    framein=~isnan(maskfo(:,ii1));
    frameinind=find(framein);
    Layer=zeros(H,W);
    % Vitreous-NFL
    C1=flatC1(:,framein);C1(50:end,:)=0;
    nanrow2=nanrow(framein);
    Img2=flatImg(:,framein);
    C1=Detour(C1,nanrow2,brgval,'upper');
    [pathx,pathy] = ShortestPathSearch(C1,Img2,1e-5,0.2,0.1);
    if frameinind(1)~= 1
        pathx=pathx+frameinind(1)-1;
    end
    pathy0=pathy+RPEloc-75;
    for ii2=1:length(pathx)
        Layer(pathy0(ii2),pathx(ii2),1)=1;
        flatC1(1:(pathy(ii2)+20),pathx(ii2))=0;
        flatC2(1:(pathy(ii2)+20),pathx(ii2))=0;
    end
    % RPE-Choriod
    C1=flatC1(:,framein);
    Img2=flatImg(:,framein);
    C1=Detour(C1,nanrow2,brgval,'lower');
    [pathx,pathy] = ShortestPathSearch(C1,Img2,1e-5,0.1,0.1);
    pathy0=pathy+RPEloc-75;
    if frameinind(1)~= 1
        pathx=pathx+frameinind(1)-1;
    end
    for ii2=1:length(pathx)
        Layer(pathy0(ii2),pathx(ii2),2)=1;
        flatC1((pathy(ii2)-15):end,pathx(ii2))=0;
        flatC2((pathy(ii2)-15):end,pathx(ii2))=0;
    end
    
    %IPL-INL
    C2=flatC2(30:50,framein);
    flatImg2=flatImg(30:50,framein);
    [pathx,pathy] = ShortestPathSearch(C2,flatImg2,1e-5,0.1,0.1);
    pathy0=pathy+RPEloc-80+29;
    if frameinind(1)~= 1
        pathx=pathx+frameinind(1)-1;
    end
    for ii2=1:length(pathx)
        Layer(pathy0(ii2),pathx(ii2),3)=1;
    end
    RPE2=zeros(1,W);
    RPE2(framein)=RPE;

    Layer=sum(Layer,3);
    Layer(:,nanrow,:)=0;
    Layer=Blending(Layer,-RPE2);
    AllLayer(:,:,ii1)=Layer;
    if flag
        % Draw
        RGB=cat(3,Layer,zeros(size(Img)),zeros(size(Img)));
        figure1 = figure(12);
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.3, 0.26, 0.7, 0.5]);
        ax1 = axes('Parent',figure1);
        ax2 = axes('Parent',figure1);
        set(ax1,'Visible','on');
        set(ax2,'Visible','off');
        II = imshow(RGB,'Parent',ax2);
        set(II,'AlphaData',0.4);
        imshow(Img,[],'Parent',ax1);
        pause(0.1)
        if flag3
            frame=getframe(figure1);
            writeVideo(aviobj,frame);
        end
    end
end
if flag3
    close(aviobj);
end
%% Extract layers
[ILM,RPE,IPL]=ExtractLay(AllLayer);
%% Remove False positive
RPE=YSearch(RPE);
ILM=YSearch(ILM);
IPL=YSearch(IPL);