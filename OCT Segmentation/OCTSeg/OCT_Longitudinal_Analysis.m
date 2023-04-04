
function Error = OCT_Longitudinal_Analysis(Dir_data)
list=dir([Dir_data,'*.avi']);
list2=dir([Dir_data,'Seg*.avi']);
num=length(list)-length(list2);
label=zeros(1,num);
Error=0;
for ii0=1:num
    ii0
    % identify filename
    filename=list(ii0).name;
    sind=strfind(filename,'.avi')-1;
    label(ii0)=sscanf(filename(8:sind),'%d');
    try
        [Layer.ILM(:,:,ii0), Layer.RPE(:,:,ii0),Layer.IPL(:,:,ii0)]=OCTSegmentation(Dir_data,filename,[],0.4,1,0,1);
        close all
        figure(999);mesh(-Layer.ILM(:,:,ii0)')
        hold on;mesh(-Layer.RPE(:,:,ii0)')
        mesh(-Layer.IPL(:,:,ii0)')
        hold off
    catch
        Layer.ILM(:,:,ii0)=0;
        Layer.RPE(:,:,ii0)=0;
        Layer.IPL(:,:,ii0)=0;
        Error = 1;
    end
    
end

save([Dir_data,'Layer.mat'],'Layer')