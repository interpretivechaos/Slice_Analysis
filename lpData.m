%% lpData.m


%IDEALLY, this part would rely on imported FMP database, which means that
%FMP needs to have all the file names, as well as an item for each cell.
%Currently MATLAB marks everything as experiment, which is equivalent to
%experimentFile number in Experiment Files table



%% S3
matfiles1=getMatFiles('/Users/ryan/Dropbox/Data_Slice/Jul 1, 2016/');
mouseDes1(1:length(matfiles1))=string('');
mouseDes1(:)=string('S3');
%%
cellNum1(1:length(matfiles1))=1;

cellNum1(1:13)=1;
cellNum1(14)=2;
cellNum1(15:23)=3;

cellLoc1(1:length(matfiles1))=string('');

cellLoc1(1:13)=string('dLGN');
cellLoc1(14)=string('dLGN');
cellLoc1(15:23)=string('dLGN');
disp('cellLoc1')
cellLoc1(1)
%skiplist=[1, 15];
% skiplist=[1, 3, 15]; %Maybe 8
% skiplist=[1, 3, 15]; %Maybe 8
skiplist=[1, 3, 4, 7:8, 9:13, 14, 15:17, 22:25, 28, 29, 30, 31, 32, 33, 34:35, 36:37, 40:49, 52:55]; %Only 100% power %56 hsd s gunky ytsvr
% VC40=[34:35, 51, 57];
fileID = fopen('ARVO_SuperFileDepression.csv','w');
fprintf(fileID, 'Experiment, Frame, Channel, Event Number,location, cellNum, mouse_dob, litter, toe, mouse, IVmode, Holding, stim_shape, stim_duration, stim_endtime, stim_freq_max, stim_freq_min, stim_amp_max, stim_amp_min, baseIV, units, start, polarity, stop, amplitude, numstim, depression, \n '); 
for i=1:length(matfiles1)
% for i=1:3
    if isempty(find(skiplist==i, 1))
        disp(matfiles1(i));
        disp('Processing');
        disp(i)
        
        %%Here is lpAnalysis
        events_struct=lpAnalysis(char(matfiles1(i)));
        
        events_struct.location=cellLoc1(i);
        events_struct.cellNum=cellNum1(i);
        events_struct.mouse=mouseDes1(i);
        file_name=[char('ARVOData_'), char(mouseDes1(i)), char('_Exp'), char(num2str(i)), char('.csv')];
        char(file_name)
%         lpExportStructToCSV(events_struct, char(file_name), num2str(i));
        lpExportStructToCSV(events_struct, fileID, num2str(i));
    end
end
%%
clear matfiles mouseDes cellNum cellLoc 

matfiles=getMatFiles('/Users/ryan/Dropbox/Data_Slice/Jul 2, 2016/');
mouseDes(1:length(matfiles))=string('');
mouseDes(:)=string('S4');

    % disp(matfiles)
%%
cellNum(1:length(matfiles))=1;

cellNum(1:6)=1; %000-OO5
cellNum(7:12)=2; %000-005 (next Day
cellNum(13:24)=3; %006-
cellNum(25:30)=4;
cellNum(31:end)=5; %034

%
cellLoc(1:length(matfiles))=string('');

cellLoc(1:6)=string('dLGN');
cellLoc(7:12)=string('dLGN');
cellLoc(13:24)=string('vLGN');
cellLoc(25:30)=string('dLGN');
cellLoc(31:end)=string('dLGN');

disp('cellLoc')
cellLoc(1)
% skiplist=[1, 3, 4, 9:11, 14, 15:17, 22:25, 28, 29, 30, 31, 32, 33, 35, 36:37, 40:49, 52:55]; %Only 100% power %56 hsd s gunky ytsvr
skiplist=skiplist-23;
%Should debug 6, 8, 30
for i=1:length(matfiles)
% for i=1:3
    if isempty(find(skiplist==i, 1))
        disp(matfiles(i));
        disp('Processing');
        disp(i)
        events_struct=lpAnalysis(char(matfiles(i)));
        events_struct.location=cellLoc(i);
        events_struct.cellNum=cellNum(i);
        events_struct.mouse=mouseDes(i);
        file_name=[char('ARVOData_'), char(mouseDes(i)), char('_Exp'), char(num2str(i)), char('.csv')];
        char(file_name)
%         lpExportStructToCSV(events_struct, char(file_name), num2str(i));
        lpExportStructToCSV(events_struct, fileID, num2str(i));
    end
end


%%
fclose(fileID)
% rawPath='/Users/ryan/Dropbox/Data_Slice/Jul 1, 2016/2016-07-02_000.mat';
% events_struct=lpAnalysis(rawPath);
% events_struct.location='dLGN';

% 