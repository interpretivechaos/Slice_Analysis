function [ChData, waveData]=lpSignalData(exportedMATFile, showAverage, channels, frames, startTime, endTime)
%LPSIGNALDATA displays data from a .mat file exported by Signal
%LPSIGNALDATA(exportedMATFile) plots all channels and frames from a MAT
%file
%
%LPSIGNALDATA(exportedMATFile, channels) plots only the channels enumerated
%in a the vector channels.
%
%LPSIGNALDATA(exportedMATFile, channels, frames) plots only the channels
%and frames enumerated in a the vectors channels, and frames.
%
%Example
%lpSignalData('/Users/me/Data_Slice2016-07-01_001.mat', [1 5], 1:4) will
%display the first and fifth channel of data, and the first through fourth
%frames of the data

%Made by Ryan Maloney, Berson Lab
% disp(exportedMATFile)

exportedMATFile=ls(exportedMATFile);
disp(exportedMATFile)

sliceData=load(exportedMATFile(1:end-1));
sliceNames=fieldnames(sliceData);
sliceCells=struct2cell(sliceData);
ChData=sliceCells{1};
waveData=sliceCells{end};

values=waveData.values;
waveDataChanInf=waveData.chaninfo.title;
waveDataChanIn=waveData.chaninfo;
waveData.frameinfo;

figure()
clf
numChannels=double(waveData.chans);
numFrames=double(waveData.frames);
disp(['There are ', num2str(numFrames), ' Frames' ]);

% whos
switch nargin
    case 1
        showAverage=false;
    case 2       
end    

if ~exist('channels')
   channels=1:numChannels;
end

if ~exist('frames')
   frames=1:numFrames;
end

if length(frames)<=1 && showAverage
    showAverage=false;
    disp('Only 1 frame, no average shown');
end
c=1;

time=0:length(waveData.values(:, 1,1))-1;
time=time.*double(waveData.interval);
disp('Channels:')
disp(channels)
disp('Frames:')
disp(frames)

for chans=channels
   	subplot(length(channels), 1, c);
    hold on
%     disp('Channels');
%     disp(chans);

    for frms=frames
    	plot(time, waveData.values(:, chans, frms));     
%         	plot(time, waveData.values(:, chans, frms),'linewidth', 1);     

        xlabel(['Time (', waveData.xunits , ')']);
        ylabel(waveData.chaninfo(chans).units);
        title(waveData.chaninfo(chans).title);
    end
    
	if showAverage
%         hold off
        plot(time, mean(permute(waveData.values(:, channels(c), frames), [3 1 2])), 'k', 'linewidth', 1);
        if chans==1
            disp('Inhibition and excitation on first pulse')
            baselineIndex=.65*10000;
            stimIndex=.6562*10000;
            stimEndex=.75*10000;

            baselineIndex=mean(mean(permute(waveData.values(baselineIndex:stimIndex, channels(c), frames), [3 1 2])));
            MaxExcit=max(mean(permute(waveData.values(stimIndex:stimEndex, channels(c), frames), [3 1 2])))-baselineIndex;
            MinExcit=min(mean(permute(waveData.values(stimIndex:stimEndex, channels(c), frames), [3 1 2])))-baselineIndex;
            fprintf(strcat("Baseline before Stimulus: ", num2str(baselineIndex), "\n Positive Deflection: ", num2str(MaxExcit), "\n Negative Deflection: ", num2str(MinExcit), "\n"));
        end
    end
    

        
    if nargin > 4
    	xlim([startTime endTime]);
    end
    c=c+1;
    hold off
end
% disp(c);
% disp(length(channels));
% disp(waveData.points)
end