clc
clear
close all
addpath(['.\OCTSeg']);

Path_input = '';

%% Creat info file
directory=dir(Path_input);
directory=directory(3:end);
num=length(directory);
if isfile('Info.mat')
    load Info
else
    for ii0=1:num
        Info{ii0}.Mouse=directory(ii0).name(1:5);
        Info{ii0}.Date=directory(ii0).name(7:end);
        Info{ii0}.Processed=1;
        Info{ii0}.Error=0;
    end
end
save Info Info

%% Batch processing
num=length(Info);
for ii0=1:num
    if ~Info{ii0}.Processed
        folder_name=[Info{ii0}.Mouse,'_',Info{ii0}.Date] 
        Dir_data=[Path_input,folder_name,'\'];
        Error = OCT_Longitudinal_Analysis(Dir_data);
        close all
        Info{ii0}.Processed=1;
        Info{ii0}.Error=Error;
        save Info Info
    end
end