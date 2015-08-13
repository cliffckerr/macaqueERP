%% CENTRALIZEDATA
% This program performs the following operations:
% 1. Opens each CNT file and converts it to Matlab using X_loadcnt
% 2. Shows the user the lever responses versus time for each stimulus type
% to determine attention.
% 3. Epochs data for each electrode for vis-std and vis-odd stimuli (ignoring auditory)
% 4. Saves to disk.
%
% Data are saved in the following format:
% data      = 2x2 cell array (attend vs. non-attend; IT vs. V4)
% data{i,j} = structure with the following fields:
%     filename = full name of original file
%     epoch    = peristimulus window in s
%     channels = channels from the original file
%     Hz       = sampling rate in Hz
%     attend   = whether or not the visual stimuli were being attended to
%     xaxis    = simply epoch*Hz; the time points corresponding to the data
%     std     = visual standard epoched data, dimensions are channel | trial | time] -- optional
%     odd      = visual oddball epoched data, dimensions are channel | trial | time
%  
% Note that the trials in the data span multiple recording sessions. Part 2
% of this code is based on csdatachecks.m, while part 3 is based on
% csdataepoch.m.
% 
% Version: 2012jan02

%% 0. Housekeeping

datadir='/home/cliffk/bill/data/juemo/raw/'; % Which directory to look for data in
outfile='../data/epocheddata-aud.mat'; % Output filename
oldrate=2000; % Sampling rate in Hz
epochstart=-0.2; % Start of epoch in s
epochend=0.4; % End of epoch in s
newrate=200; % New sampling rate in Hz
channels=[30:43; 1:14]; % V4 and IT LFP channels
data=cell(2,2); % Store output data
v4vsit={'V4','IT'}; % The names of the two sites

stimcount=zeros(2,2,2,length(channels)); % Number of stimuli; dimensions are: attend/ignore | IT/V4 | standard/oddball | channel




%% 1. Loading data

allfiles=dir([datadir '*.cnt']); % Get all file names
nfiles=length(allfiles);



for Z=1:nfiles % Loop over files
    tic
    fprintf('\nLoading file %i of %i (%s)...\n',Z,nfiles,allfiles(Z).name)
    tmpdata=X_loadcnt([datadir allfiles(Z).name]);
    origdata=tmpdata.data'; % Pull out the interesting array and transpose it
    
    
    %% 2. Decide on whether trial block is attend-auditory or attend-visual
    xaxis=(0:length(origdata)-1)/oldrate; % Set up an x-axis to plot everything
    
    labels={'Auditory target (green: lever)','Visual target (green: lever)'};
    levertimes=diff(origdata(:,61)); levertimes=find(levertimes>200)/oldrate; % Pull out lever times
    npulls=length(levertimes); % How many times the monkey pulled the lever
    audodd=diff(origdata(:,58)); audodd=find(audodd<-200)/oldrate; % Pull out auditory oddball stimuli
    visodd=diff(origdata(:,60)); visodd=find(visodd<-200)/oldrate; % Pull out visual oddball stimuli
    audpositive=0;
    vispositive=0;
    
    h=figure('position',[-200 500 2200 50]); hold on
    scatter(levertimes,2*ones(npulls,1),'k','filled')
    scatter(audodd,1*ones(size(audodd)),'g','filled')
    scatter(visodd,3*ones(size(visodd)),'b','filled')
    drawnow
    
    for i=1:length(levertimes)
        tmpaud=levertimes(i)-audodd; % Find the time difference between the lever press and the stimuli
        tmpvis=levertimes(i)-visodd; % Find the time difference between the lever press and the stimuli
        tmpaud=tmpaud(tmpaud>0.05 & tmpaud<1.2); % Give it between 100 ms and 1 s to respond
        tmpvis=tmpvis(tmpvis>0.05 & tmpvis<1.2); % Give it between 100 ms and 1 s to respond
        if isempty(tmpaud), tmpaud=Inf; end % Handle cases where no stimuli are available
        if isempty(tmpvis), tmpvis=Inf; end 
        if min(tmpaud)<min(tmpvis)
            audpositive=audpositive+1;
%             fprintf('     * %ith auditory response after %i ms\n',audpositive,round(min(tmpaud)*1000))
        elseif min(tmpvis)<min(tmpaud)
            vispositive=vispositive+1;
%             fprintf('     ** %ith visual response after %i ms\n',vispositive,round(min(tmpvis)*1000))
        else
%             disp('        *** No clear antecedent!')
        end
    end
    
%     h=figure('position',[700 100 1000 500]);
%     for i=1:2
%         subplot(2,1,i); hold on
%         plot(xaxis,-origdata(:,56+i*2)) % Plot stimuli
%         plot(xaxis,origdata(:,61),'g') % Plot lever response
%         title(labels{i})
%         if i==2, xlabel('Time (s)'), end
%         box on
%         xlim([0,300])
%     end
%     drawnow; pause(5); close(h); drawnow
    
    if audpositive>2*vispositive % If monkey responds twice as frequently to auditory, assume that's what it is
        fprintf('  Monkey was responding to auditory (%i vs %i)\n',audpositive,vispositive)
        A=1;
    elseif vispositive>2*audpositive % If monkey responds twice as frequently to visual, assume that's what it is
        fprintf('  Monkey was responding to visual (%i vs %i)\n',audpositive,vispositive)
        A=2;
    else
        disp('Monkey was confused :(')
        A=input('Auditory (1) or visual (2)? '); % Whether auditory or visual stimuli are being attended to
%         close(h); drawnow % Close window when done
    end
    
    pause(2)
    close(h); drawnow
    
    
    
    for Q=1:2 % Loop over V4 vs. IT
        
        %% 3. Store additional information
        data{A,Q}.filename=[datadir allfiles(Z).name]; % Which file did the data come from originally?
        data{A,Q}.epoch=[epochstart epochend]; % How big is the window?
        data{A,Q}.channels=channels(Q,:); % Which channels to pull from the file?
        data{A,Q}.Hz=newrate; % What's the sampling rate in Hz?
        data{A,Q}.attend=A-1; % Which stimulus type is being attended to in this data
        data{A,Q}.area=v4vsit{Q}; % What area the data is from: V4 or IT
        
        %% 3. Split the data up into trials
        trialtypes={'std','odd'}; % Trial types -- auditory standard, auditory oddball, visual standard, visual oddball
        stimindices=[57 58]; % Which channels in the file correspond to stim data; [57 58] are auditory stimuli, [59 60] are visual
        ntypes=length(trialtypes);
        nchannels=length(channels);
        npts=ceil((epochend-epochstart)*newrate); % Number of points in each trial window
        newptsbefore=-epochstart*newrate; % How many points before the stimulus to use
        newptsafter=epochend*newrate; % How many points after the stimulus to use
        oldptsbefore=-epochstart*oldrate;
        oldptsafter=epochend*oldrate;
        data{A,Q}.xaxis=linspace(epochstart,epochend,npts); % For plotting -- store time information
        
        fprintf('  Splitting %i of %i into epochs...\n',Q,2)
        for i=1:ntypes % Loop over standards and oddballs
            fprintf('    Working on type %i of %i...\n',i,ntypes);
            % Get the stimulus times
            thisstim=origdata(:,stimindices(i)); % Pull out the stimuli
            totalpts=length(thisstim); % Total number of data points
            stimdiff=diff(thisstim); % Detect changes in the stimuli
            stimtimes=find(stimdiff<-200); % Changes are huge decreases (~-500) in the stim time series
            stimtimes=stimtimes(stimtimes>oldptsbefore & stimtimes<(totalpts-oldptsafter)); % Remove stimuli that are too close to the beginning or end of the recording
            nstims=length(stimtimes); % Number of stimuli
            
            % Set up the array to store results in
            if Z==1, data{A,Q}.(trialtypes{i})=zeros(nchannels,3000,npts); end % Set up array if not set up before, 3000 is arbitrary to make it big enough
            
            % Pull out the corresponding data
            for j=1:nchannels
                for k=1:nstims
                    stimcount(A,Q,i,j)=stimcount(A,Q,i,j)+1; % Total number of stimuli -- sum over files (Z) and k but nothing else
                    thisdata=origdata(stimtimes(k)-oldptsbefore:stimtimes(k)+oldptsafter+oldrate/newrate,channels(Q,j)); % Pull out the data; oldrate/newrate is to give one extra data point
                    tmp=downsample(thisdata,oldrate,newrate); % Downsample to the desired rate
                    data{A,Q}.(trialtypes{i})(j,stimcount(A,Q,i,j),:)=tmp; % Append to entire array
                end
            end
        end
    end
    toc
end

for A=1:2
    for Q=1:2
        for i=1:ntypes
            data{A,Q}.(trialtypes{i})=data{A,Q}.(trialtypes{i})(:,1:stimcount(A,Q,i,1),:); % Trim extra "rows"
        end
    end
end

fprintf('\nSaving data...\n')
save(outfile,'data') % Save data
disp('...done.')


disp('Done.')
