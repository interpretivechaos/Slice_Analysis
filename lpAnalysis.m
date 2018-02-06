function [events, waveData]=lpAnalysis(sliceInfo, virus, frames, showPlots)
%lpAnalysis analyzes data from a .mat file exported by Signal
%Expects input about file as matrix [sliceNumber, fileNumber, CellNumber]


sliceNumber=sliceInfo(1);
fileNumber=sliceInfo(2);
if length(sliceInfo)>2
    cellNumber=sliceInfo(3);
else
    cellNumber=-1;
end

exportedMATFile=lsd(sliceNumber, fileNumber);
%Made by Ryan Maloney, Berson Lab
% disp(exportedMATFile)

% showPlots=false;
fig=1;

exportedMATFile=ls(exportedMATFile);
disp(exportedMATFile)
sliceData=load(exportedMATFile(1:end-1));
disp(sliceData)
%
% sliceNames=fieldnames(sliceData);
% disp(sliceNames)

sliceCells=struct2cell(sliceData);
% disp(sliceCells)
% ChData=sliceCells{1};
waveData=sliceCells{end};

% values=waveData.values;
% waveDataChanInf=waveData.chaninfo.title;
% waveDataChanIn=waveData.chaninfo;
waveData.frameinfo;


%%% ALL EXTRACTED VARIABLES HERE
wdi=waveData.interval;
numChannels=double(waveData.chans);
numFrames=double(waveData.frames);
unit=waveData.chaninfo(1).units;
%waveData.values

% Check for Current Clamp vs Voltage Clamp
IVmode='Error';
if unit=='pA'
    IVmode='Voltage Clamp';
    channels=[1, 2, 5];
    holdgain=16;
    holdmin=35;
    
elseif unit=='mV'
    IVmode='Current Clamp';
    channels=[1, 2, 5];
    holdgain=9;
    holdmin=3;
end

if ~exist('channels', 'var')
    channels=1:numChannels;
end

if ~exist('frames', 'var')
    frames=1:numFrames;
else if frames=='All'
    frames=1:numFrames;
end

if ~exist('showPlots', 'var')
    showPlots=false;
end

time=0:length(waveData.values(:, 1,1))-1;
time=time.*double(wdi);

stim_timepoint=[];

holdIndex=int8(floor(.4/wdi));

holdUnit=waveData.chaninfo(2).units;
holdingIV=median(waveData.values(1:holdIndex, 2, 1));

if showPlots
    disp(IVmode);
    disp(['There are ', num2str(numFrames), ' Frames' ]);
    disp(['Held at ', num2str(holdingIV), holdUnit]);
end
%S.Volt
% events=struct('Frames', cell(length(frames), 1));

% frame_struct2=struct('channels', [], 'stim_duration', [], 'stim_freq_max',...
%[], 'stim_amp_max', [], 'stim_amp_min', [], 'stim_shape', [], 'IVmode', IVmode, 'Holding', holdingIV);
% Events is a structure
events=struct('frames',[],'location',['lgn'],'cellNum',[cellNumber],'mouse',[strcat('S',num2str(sliceNumber))]);

% frame_struct3=struct('channels', [], 'stim_duration', [], 'stim_freq_max', [],...
%'stim_amp_max', [], 'stim_amp_min', [], 'stim_shape', [], 'IVmode', IVmode, 'Holding', holdingIV);
% events.frames(3)=frame_struct3;

% events_struct=struct('start', [], 'stop', [], 'polarity', [], 'amplitude', []);


% Measure holding potential/current
for frms=frames
    
    %for chans=channels %Go through each channels,
    %Calculate Last Channel
    stimuliChannel=(max(channels));
%     stimuliChannel=5;

    chans=stimuliChannel; %Just calculate events for waveforms
    %       wavedataexport=waveData.values(:, chans, frms);
%     disp(chans)
    unit=waveData.chaninfo(chans).units;
    
    %disp(type(.8/waveData.interval))
    holding=waveData.values(1:holdIndex, chans, frms);
    
    % Calculate
    holdrange=std(holding);
    %         %holdrange=holdrange*16*4;
    %         holdgain=9;
             holdmin=.05;
    holdrange=max(holdrange*holdgain, holdmin)

    HoldBase=median(holding)
    
    if showPlots
        fprintf('\n');
        
        disp(['Frame ', num2str(frms), '; Channel ', num2str(chans)])
        
        disp(['Median: ', num2str(HoldBase), unit, ' Min: ',...
            num2str(HoldBase-holdrange), unit,...
            ' Max: ', num2str(HoldBase+holdrange),  unit]);
    end
    
    
    
    stimOn=false;
    numstim=0;
    
    isPrimed=zeros(1, length(waveData.values(:, chans, frms)));
    
    %This code calculates events by deviations from holding, replacing
    %with code that just calculates min/max locked to stimuli
    %%% Just using for stimulus channel
    for i=1:length(waveData.values(:, chans, frms))
        isPrimed(i)=stimOn;
%         disp(chans)

%         disp(['h', num2str(abs(waveData.values(i, chans, frms)-HoldBase))]);
%         plot(abs(waveData.values(:, chans, frms)-HoldBase));
        
        if ~stimOn && (abs(waveData.values(i, chans, frms)-HoldBase) > holdrange)
            
            % Calc number of pulses
            numstim=numstim+1; %Increment number of stims
            disp(numstim)
            %Record onset of stimuli
            stim_timepoint(numstim, chans, frms, 1)=(i-1)*wdi;
%             disp('stim_timepoint size line 161')
%             size(stim_timepoint)
            events.frames(frms).channels(chans).events(numstim).start=(i-1)*wdi;
            stimOn=true; %Toggle detection
            
            %Record in stim_timepoint(numstim, frms, 3) if it's a
            %positive or negative deflection
%             if waveData.values(i, chans, frms)-HoldBase > 0
%                 stim_timepoint(numstim, chans, frms, 3)=1;
%                 events.frames(frms).channels(chans).events(numstim).polarity=1;
%                 
%             else
%                 stim_timepoint(numstim, chans, frms, 3)=-1;
%                 events.frames(frms).channels(chans).events(numstim).polarity=-1;
%             end
%             
        elseif stimOn && (abs(waveData.values(i, chans, frms)-HoldBase) < holdrange/2)
            stimOn=false;
            stim_timepoint(numstim, chans, frms, 2)=(i-1)*wdi;
            events.frames(frms).channels(chans).events(numstim).stop=(i-1)*wdi;
        end
    end
    
    %Catch if still on at end and terminate at end of run
    if stimOn
        stim_timepoint(numstim, chans, frms, 2)=(length(waveData.values(:, chans, frms))-1)*wdi;
    end
    firstPos=0;
    firstNeg=0;
    numPos=0;
    numNeg=0;
    for i=1:numstim
        %Note, this is now only for stimulus, chans=max
        startIndex=round(stim_timepoint(i, chans, frms, 1)/wdi);
        endIndex=min(1+round(stim_timepoint(i, chans, frms, 2)/wdi), length(time));
        
        stimrange=waveData.values(startIndex:endIndex, chans, frms);
        
        % Calculate value of channel 1 right before stimulus
        preStimulusInterval=.01;
%         preStimulusMean=mean(waveData.values((startIndex-round(preStimulusInterval/wdi)):startIndex, 1, frms));
        preStimulusMean=mean(waveData.values((startIndex-round(preStimulusInterval/wdi)):startIndex));

        postStimulusInterval=.02;
%         figure(1)
        interval=waveData.values(startIndex-round(preStimulusInterval/wdi):(startIndex+round(postStimulusInterval/wdi)));
%         size(interval)
%         plot(interval)
%         disp(preStimulusMean);

        maxDeflection=max(interval)-preStimulusMean;
        minDeflection=min(interval)-preStimulusMean;
        
%         figure(1)
%         plot(interval)
%         hold on;
%         plot(ones(size(interval))*max(interval));
%         plot(ones(size(interval))*min(interval));
%         plot(ones(size(interval))*preStimulusMean);
%         plot(waveData.values((startIndex-round(preStimulusInterval/wdi)):startIndex))
%         hold off;
        
        disp(['Mean: ', num2str(preStimulusMean), 'Max: ', num2str(maxDeflection), 'Min: ', num2str(minDeflection)])
        %           figure(1)
        %           hold on
        %           plot(stimrange)
        %         if stim_timepoint(i, chans, frms, 3)>0 %Detects polarity, not necessary now
        %Calculate stim amplitude
        stim_timepoint(i, 1, frms, 3)=maxDeflection;
        stim_timepoint(i, 1, frms, 4)=minDeflection;
        %How am I storing this
        events.frames(frms).channels(chans).events(i).posDeflection=maxDeflection;
        events.frames(frms).channels(chans).events(i).negDeflection=minDeflection;

        events.frames(frms).channels(chans).events(i).amplitude=max(stimrange)-HoldBase;
%         numPos=numPos+1;
%         events.frames(frms).channels(chans).events(i).numstim=numPos;
        %               disp(['numstim:', num2str(i)])        
        %         elseif stim_timepoint(i, chans, frms, 3)<0 %Detects polarity, not necessary now
%         stim_timepoint(i, chans, frms, 4)=min(stimrange)-HoldBase;
%         events.frames(frms).channels(chans).events(i).amplitude=min(stimrange)-HoldBase;
%         
%         numNeg=numNeg+1;
%         events.frames(frms).channels(chans).events(i).numstim=numNeg;
        %         else %Detects polarity, not necessary now
        %             disp('Weirdness happened')
        %         end
        
        if firstPos==0 && (stim_timepoint(i, chans, frms, 3)==1)
            firstPos=stim_timepoint(i, chans, frms, 4);
            events.frames(frms).channels(chans).events(i).depression=1;
            %                 disp('here')
            %                 disp(firstPos)
        elseif firstNeg==0 && (stim_timepoint(i, chans, frms, 3)==-1)
            firstNeg=stim_timepoint(i, chans, frms, 4);
            events.frames(frms).channels(chans).events(i).depression=1;
            %                 disp('here2')
            %                 disp(firstNeg)
        elseif stim_timepoint(i, chans, frms, 3)==1
            events.frames(frms).channels(chans).events(i).depression=stim_timepoint(i, chans, frms, 4)/firstPos;
        elseif stim_timepoint(i, chans, frms, 3)==-1
            events.frames(frms).channels(chans).events(i).depression=stim_timepoint(i, chans, frms, 4)/firstNeg;
        else
%             disp('Error in calculating Depression :(')
        end
        
    end
    
    %         hold off
    
    % Plot channel overlaid with detection of events
    %     if showPlots
    %         %             disp('Drek')
    %         disp('FirstNeg/Pos')
    %         disp(firstNeg)
    %         disp(firstPos)
    %         figure(fig);
    %         fig=fig+1;
    %         clf
    %         t=1:length(waveData.values(:, chans, frms));
    %         t=t*wdi;
    %         plot(t, waveData.values( :, chans, frms));
    %         hold on
    %         plot(t, isPrimed*50);
    %         xlabel('Time (s)');
    %         ylabel(unit);
    %         hold off
    %         title(['Stimulus + Detected Events for Frame ', num2str(frms), ' Channel ', num2str(chans)]);
    %     end
    
    if chans==stimuliChannel
%         disp(chans)
%         disp(frms)
%         size(stim_timepoint)
        SparseStimStart=stim_timepoint(:, chans, frms, 1);
        SparseStimEnd=stim_timepoint(:, chans, frms, 2);
        SparseStimEnd=SparseStimEnd(SparseStimEnd~=0);
        SparseStimStart=SparseStimStart(SparseStimStart~=0);
        freq=diff(SparseStimStart);
        
        %Displace
        max_freq=max(1./freq(:,:));
        min_freq=min(1./freq(:,:));
        
        stimulusDuration=SparseStimEnd(end)-SparseStimStart(1);
        numberOfStimuli=length(SparseStimStart);
        stimAmp=stim_timepoint(:, chans, frms, 4);
        stimAmp=stimAmp(stimAmp~=0);
        maxAmplitude=max(stimAmp)-HoldBase;
        minAmplitude=min(stimAmp)-HoldBase;
        
        if showPlots
            fprintf('\n');
            disp(['Numstim: ', num2str(numstim)]);
            
            disp(['Max Freq (Hz): ', num2str(max_freq)]);
            disp(['Min Freq (Hz): ', num2str(min_freq)]);
            disp(['Stimulus Duration (S): ', num2str(stimulusDuration)]);
            disp(['Number Of Stimuli: ', num2str(numberOfStimuli)]);
            disp(['Max Stim Amplitude: ', num2str(maxAmplitude), unit]);
            disp(['Min Stim Amplitude: ', num2str(minAmplitude), unit]);
            
        end
        %end
        %         channel_struct=struct('events', events_struct,
        %         'holding_potential', HoldBase);
        %         events.frames(frms).channels(chans).events.amplitude
        %         events.frames(frms).channels(chans).events=events_struct;
        events.frames(frms).channels(chans).baseIV=HoldBase;
        events.frames(frms).channels(chans).units=unit;
        events.frames(frms).IVmode=IVmode;
        events.frames(frms).Holding=holdingIV;
        events.frames(frms).stim_shape='';
        
    end
    %     disp(frms)
    %     events.frames(frms)=struct('channels', channel_struct, 'stim_duration', stimulusDuration,...
    % 'stim_freq_max', max_freq, 'stim_freq_min', min_freq, 'stim_amp_max', maxAmplitude, 'stim_amp_min',...
    % minAmplitude, 'stim_shape', [], 'IVmode', IVmode, 'Holding', holdingIV);
    %     events.frames(frms).channels=channel_struct;
    
    events.frames(frms).stim_duration=stimulusDuration;
    events.frames(frms).stim_endtime=SparseStimEnd(end);
    events.frames(frms).stim_freq_max=max_freq;
    events.frames(frms).stim_freq_min=min_freq;
    events.frames(frms).stim_amp_max=maxAmplitude;
    events.frames(frms).stim_amp_min=minAmplitude;
        
end
events.filenumber=fileNumber;
events.virus=virus;
end
