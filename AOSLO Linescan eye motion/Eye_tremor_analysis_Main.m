clc
clear;close all


% Path of dataset
Path_input = '';
% Path of output data
Path_output = '';

%% Main
list = dir([Path_input,'*.avi']);
file_num = length(list);

process={'.avi'};
for file_count = 1:file_num 
    if list(file_count).bytes>43000000&&contains(list(file_count).name, process)
        %% =========Open video==============
        filename=list(file_count).name
        imagefile= [[Path_input,filename];
        info = mmfileinfo(imagefile);
        tt=info.Duration;
        fps=31;
        pitch=4.98*34/608;
        mov=VideoReader(imagefile);
        %% ===========Frame to strip============
        frame_count = 1;
        strip_count = 1;
        Strip_4s = zeros(fps*480*4,608);
        while hasFrame(mov)
            Img = mean(readFrame(mov),3);
            
            Strip_1s((frame_count-1)*480+(1:480),:) = Img;
            
            if frame_count > fps*4
                Strip(:,:,strip_count) = Strip_1s;
                strip_count = strip_count+1;
                Strip_1s = zeros(fps*480*4,608);
                frame_count = 1;
                break
            else
                frame_count = frame_count+1;
            end
        end
        
        
        %%
        Img = (Strip(:,1:600,1));
        Img_0 = Img;
        Img = imgaussfilt(Img,[1.5,1.5]);
        %% parameters
        
        strip_width = 10;
        ref_num = 30;
        line_num = fps*480*4;
        Width = size(Img,2);
        
        %% Sobel
        SobelV = [-1,-1,2,1,1];
        SobelV=repmat(SobelV,20,1);
        Img_edge = conv2(medfilt2(Img,[4,4]),SobelV,'same');
        Img_edge =Img_edge(:,3:end-3);
        %% Randomly select reference
        Ref_loc = round(round(rand(1,ref_num).*strip_width.*2)./strip_width./2.*(line_num-strip_width));
        for ref_count = 1:ref_num
            Ref_tempaltes(:,:,ref_count) = Img(Ref_loc(ref_count)+(1:strip_width),:);
            template_std(:,ref_count) =mean(Ref_tempaltes(:,:,ref_count));
            template_edge(:,ref_count) = mean(Img_edge(Ref_loc(ref_count)+(1:strip_width),:));
        end
        
        %% Tremor Detection
        
        for line_count = 1:(line_num-strip_width)
            test_line = Img(line_count+(1:strip_width),:);
            test_edge = Img_edge(line_count+(1:strip_width),:);
            for ref_count = 1:ref_num
                Drift_edge(line_count,ref_count)=correlation_line(mean(test_line),template_std(:,ref_count)');
            end
        end
        
        Drift = (Drift_edge);
        
        %% Combine

        x0=zeros(ref_num,1);
        fun = @(x)Align_offset(Drift,x0);
        x = fminsearch(fun,x0);
        for ref_count = 1:ref_num            
            Drift(:,ref_count) = Drift(:,ref_count)+x(ref_count);
        end
        
        figure;plot(Drift)
        Offset(1)=median(Drift(1,:));
        for ii1 = 2:size(Drift,1)
            
            off_line = Drift(ii1,:);off_line(off_line>(std(off_line)+mean(off_line)))=nan;
            off_line(off_line<(mean(off_line)-std(off_line)))=nan;
            distance = abs(off_line-Offset(ii1-1));
            dist_mean = abs(off_line-median(off_line(~isnan(off_line))));
            weight = 0.5.*distance+0.5.*dist_mean;
            [~,ind] = min(weight);
            Offset(ii1) = median(Drift(ii1,:));
        end
        figure;plot(Offset)
        %% Registration
        RegImg=regline(Img_0(1:line_num-strip_width,:),Offset);
        RegImg(RegImg==0)=nan;

        
        RegImg_n = RegImg-min(min(RegImg));RegImg_n = RegImg_n./max(max(RegImg_n)).*255;
        Img_n = Img_0-min(min(Img_0));Img_n = Img_n./max(max(Img_n)).*255;
        
        imwrite(uint8(RegImg_n)',[Path_output,filename(1:end-4),'_reg.tiff'],'tiff')
        imwrite(uint8(Img_n)',[Path_output,filename(1:end-4),'_raw.tiff'],'tiff')
        save([Path_output,filename(1:end-4),'_Offset.mat'],'Offset')
    end
end