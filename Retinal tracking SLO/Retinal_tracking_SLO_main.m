clc
clear; close all

Path_input = '';

%% =========Read Data from .avi===============
directory = Path_input;
list = dir([directory,'*.avi']);
imagefile=[directory,list(1).name];
info = mmfileinfo(imagefile);
tt=info.Duration;
fps=10;
mov=VideoReader(imagefile);

%% ==========Reference Frame============= 
mov.CurrentTime = 10./tt./fps;
ImRef = mean(readFrame(mov),3);
figure;imshow(ImRef,[])

%% Input registration template coordinates
template{1} = ImRef(454:619,315:483);
template{2} = ImRef(220:362,445:573);
template{3} = ImRef(459:540,194:281);

%% Load existing template file
% load 'D\Awake Mouse Project\Retinal Tracking\2328_10-3-19_Retina_template.mat'

%% Initialize reference coord
for ii4=1:3
    C1 = normxcorr2(template{ii4},ImRef);
    [Yo(ii4),Xo(ii4)]=find(C1==max(max(C1)));
end
save([list(1).name(1:end-8),'_template.mat'],'template')

%% ==========Get offsets=================
for ii0 = 1:length(list)
    ii1=1;
    imagefile=[directory,list(ii0).name];
    info = mmfileinfo(imagefile);
    tt=info.Duration;
    fps=10;
    mov=VideoReader(imagefile);
    mov.CurrentTime = 0;
    BadCorr=zeros(size(ImRef));

    aviname=[list(ii0).name(1:end-4),'_Track.avi'];
    aviobj=VideoWriter(aviname);
    aviobj.FrameRate = 8.8*3;
    open(aviobj)
    
    
    ii2=1;
    while hasFrame(mov)
        ii1
        tic
        Im = mean(readFrame(mov),3);
        h0=figure(99);imshow(Im,[]);hold on;
        for ii3=1:3
            [Xoff(ii1,ii3),Yoff(ii1,ii3),peak(ii1,ii3)]=EvaOffset(Im,template{ii3},Xo(ii3),Yo(ii3),1);
            xBott(ii3)=gather(Yoff(ii1,ii3)+Yo(ii3))-size(template{ii3},2);xLeft(ii3)=gather(Xoff(ii1,ii3)+Xo(ii3))-size(template{ii3},1);
           
        end
        for ii3=1:3
            if peak(ii1,ii3)==max(peak(ii1,:))
                rectangle('position',[xLeft(ii3),xBott(ii3),size(template{ii3},2),size(template{ii3},1)],'linewidth',1.5,'edgecolor','red');
            else
                rectangle('position',[xLeft(ii3),xBott(ii3),size(template{ii3},2),size(template{ii3},1)],'linewidth',1.5);
            end
        end 
        hold off
        
        frame=getframe(h0);
        writeVideo(aviobj,frame);
        
        if std(Xoff(ii1,:))>=40||std(Yoff(ii1,:))>=40
            BadCorr(:,:,ii2)=Im;
            ii2=ii2+1;
        end
        
        ii1=ii1+1;
    end
    close(aviobj);
    
    Retina_off.Yoff=Yoff;
    Retina_off.Xoff=Xoff;
    Retina_off.peak=peak;
    save([list(ii0).name(1:end-4),'_Output.mat'],'Retina_off')
end

fnum=ii1-1;

figure;hold on
scatter(Yoff(:,1),Xoff(:,1),'o')
scatter(Yoff(:,2),Xoff(:,2),'*')
scatter(Yoff(:,3),Xoff(:,3),'^')
xlabel('X offset (Pixels)')
ylabel('Y offset (Pixels)')
legend('A','B','C')

figure; hold on
plot(peak(:,1),'-o')
plot(peak(:,2),'*-')
plot(peak(:,3),'^-')
xlabel('Frame#')
ylabel('Normalized Correlation')
legend('A','B','C')

figure;
hold on;plot(Xoff(:,1),'-o')
plot(Yoff(:,1),'-*')
xlabel('Frame #')
ylabel('Offset pixels')
legend('A-X','A-Y')

Retina.Xoff=Xoff;
Retina.Yoff=Yoff;
save Retina Retina

%% ============Distance of movement=========================
for ii8=1:3
    Distance(:,ii8)=sqrt(Xoff(:,ii8).^2+Yoff(:,ii8).^2);
end
figure;
hold on;plot(Distance(:,1),'-o')
plot(Distance(:,2),'*-')
plot(Distance(:,3),'^-')

xlabel('Frame#')
ylabel('Distance (Pixels)')
legend('A','B','C')


