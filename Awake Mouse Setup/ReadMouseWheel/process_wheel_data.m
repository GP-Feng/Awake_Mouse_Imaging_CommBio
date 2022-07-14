clear;
clc;
[times, chana, chanb]=load_wheel_data('filename.dat');

totalsamples = size(chana,1);
samplesize=1000;
samples=totalsamples/samplesize;

%Total ticks
edgesA=diff(chana);
edgesB=diff(chanb);

riseA=sum(edgesA==1); %Count rising edges
indexArise=(find(edgesA==1)+1); %Index of rising edge
% riseB=sum(edgesB==1); %Count rising edges
indexBrise=(find(edgesB==1)+1); %Index of rising edge

% fallA=sum(edgesA==-1); %Count falling edges
% indexAfall=(find(edgesA==-1)+1); %Index of falling edge
% fallB=sum(edgesB==-1); %Count falling edges
% indexBfall=(find(edgesB==1)+1); %Index of falling edge

totaldistance=riseA*((8*pi)/256); %Unit is cm

position1=zeros(size(chana));
%Distance
for i=1:totalsamples
    if i==1&&i==indexArise(i)
        position1(i)=1;
    elseif i==1
        position1(i)=0;
    elseif any(indexArise==i)
        position1(i)=position1(i-1)+1;
    else
        position1(i)=position1(i-1);
    end
end 

position2=zeros(size(chana));
%Displacement
for i=1:totalsamples
    if i==1&&i==indexArise(i)
        position2(i)=1;
    elseif i==1
        position2(i)=0;
    elseif any(indexArise==i) % perform actions if i matches any value in indexArise
        k=find((indexArise==i)); %find index of match
        d=indexArise(k); % return value at the match which is the index of chana rise
        if double(chanb(d))==1 %Direction if a rises and b=1 CCW if b=0 CW
            position2(i)=position2(i-1)+1;
        elseif double(chanb(d))==0
            position2(i)=position2(i-1)-1;
        end
    else
        position2(i)=position2(i-1);
    end
end

newposition1=position1.*((8*pi)/256); % unit cm
newposition2=position2.*((8*pi)/256);
newtimes=(times-(times(1)))/1000; % subtract starting time from all time values to set start to 0, convert to secs

totaltime=newtimes(end)-newtimes(1); %unit sec

%Velocity in Second Bins
index=zeros(1,samples);
for i=1:samples
    if i==1
        index(i)=sum(newtimes<i);
    else
        index(i)=sum(newtimes<i);
    end
end
edgesA(end+1)=0;
for i=1:numel(edgesA)-1
    if i==1
        edgesA(end)=edgesA(end-1);
    else
        edgesA((numel(edgesA)-i)+1)=edgesA(numel(edgesA)-i);
    end
end
edgesA(1)=0;
edgeCount=zeros(1,samples);
for i=1:samples
    if i==1
        edgeCount(i)=sum(edgesA(1:index(i))==1);
    else
        edgeCount(i)=sum(edgesA(index(i-1)+1:index(i))==1);
    end
end
distanceCount=edgeCount.*((8*pi)/256);
dx1=distanceCount(1:ceil(totaltime));

holdedges=[];
holdtimes=[];
holdindexes=[];
%Velocity in Sampling Bins
for s=1:samples
sz = s * samplesize;
beginning = sz - samplesize + 1;
ending = sz;
allEdges=[holdedges (chana(beginning+1:ending) - chana(beginning:ending -1))];
holdedges = allEdges;
alltimes=[holdtimes newtimes(ending)-newtimes(beginning)];
holdtimes=alltimes;
timeindexes=[holdindexes sz];
holdindexes=timeindexes;
end

dx2=sum(allEdges==1);
velocityPerBinticks=dx2./alltimes;
velocityPerBin=velocityPerBinticks.*((8*pi)/256);
binEnd=newtimes(timeindexes);

% figure
% plot(newtimes,newposition1,"b*")
% title('Distance vs Time')
% xlabel('Time (s)') 
% ylabel('Distance (cm)')
% set(gca,'FontSize',20)
% 
% figure
% plot(newtimes,newposition2,"b*")
% title('Position vs Time')
% xlabel('Time (s)') 
% ylabel('Position (cm)')
% set(gca,'FontSize',20)

figure
plot(newtimes,newposition1,"b*")
title('Velocity and Distance')
xlabel('Time (s)') 
ylabel ({'Distance(cm)';'Velocity (cm/s)'})
hold on
plot(newtimes,newposition2,"b*")
% plot(dx1,"r^-")
plot(binEnd,velocityPerBin,"r*-")
set(gca,'FontSize',20)

figure
plot(binEnd,velocityPerBin,"r*-")
title('Velocity')
xlabel('Time (s)') 
ylabel ('Velocity (cm/s)')
set(gca,'FontSize',20)
