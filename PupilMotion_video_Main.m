clc
clear; close all

%% =========Read Data from .avi===============
directory = '\\cvsnas3.cvs.rochester.edu\aria\Mouse\Awake Mouse Project\HRA\Pupil\3370_Pupil\';
list = dir([directory,'*.avi']);
pupil_win=60;
for ii0 = 1:length(list)
    imagefile = [directory,list(ii0).name];
    mov=VideoReader(imagefile);
    ii1=1;
    %% ==========Estimate motions=====================
    h0=figure(99);
    k=1;
    aviname=[list(ii0).name(1:end-4),'_Track.avi'];
    aviobj=VideoWriter(aviname);
    aviobj.FrameRate = 20;
    open(aviobj)
    
    mov.CurrentTime = 20;
    Img =mean(readFrame(mov),3);
    Img = Img(100:end-100,100:end-100);
    if ii1==1&&ii0==1
        [centers0, radii] = imfindcircles(imgaussfilt(Img,[3,3]),[30 70]);
        centx0=centers0(1,1);
        centy0=centers0(1,2);
    end
    
    mov.CurrentTime = 0;
    while hasFrame(mov)
        ii1
        Img =mean(readFrame(mov),3);
        Img = Img(100:end-100,100:end-100);
        
        % Pupil segmentation
        pupil=Img(round(centy0)+(-pupil_win:pupil_win),round(centx0)+(-pupil_win:pupil_win));
        [centers, asp_ratio(ii1), boundary] = Pupil_detection_v2(pupil);
        centers(1) = centers(1)+ round(centers0(1,1))-pupil_win;
        centers(2) = centers(2)+ round(centers0(1,2))-pupil_win;
        
        % Plot
        figure(99)
        imshow(Img,[]);hold on
        if ~isnan(boundary)
            DrawEllip(centers(1),centers(2),(max(boundary(:,2))-min(boundary(:,2)))/2,(max(boundary(:,1))-min(boundary(:,1)))/2)
        end
        
        hold off
        Yoff(ii1)=centers(1,2);
        Xoff(ii1)=centers(1,1);
        
        bound{ii1} = boundary;
        
        ii1=ii1+1;
        frame=getframe(h0);
        writeVideo(aviobj,frame);
    end
    close(aviobj);
    fnum=ii1-1;
    Distance=sqrt(Xoff.^2+Yoff.^2);
    Pupil_off.Yoff=Yoff;
    Pupil_off.Xoff=Xoff;
    Pupil_off.asp_ratio=asp_ratio;
    Pupil_off.bound=bound;
    save([list(ii0).name(1:end-4),'_Output.mat'],'Pupil_off')
    
end


figure;
plot(t,Distance-median(Distance),'-^','linewidth',1.4)
xlabel('Time (s)')
ylabel('Distance offset (\mum)')

figure;scatter(Xoff-median(Xoff),-Yoff+median(Yoff),'linewidth',1.4)
xlabel('X offset(\mum)')
ylabel('Y offset(\mum)')
