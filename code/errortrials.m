% The basic idea was to base the code off of the categorizetrials.m file, but make a few
% adjustments to pull at error trials. The types of errors was split into 2 types: the monkey
% pulling the lever for no reason, and the monkey failing to respond to the odd stimulus of the
% specified type. Using the same structure as categorizetrials.m, the data was stored the stimcount
% form of:                   
%                   audio/visual | IT/V4 |  no stimulus/no response | channel 



datadir = 'C:/Users/Felicity/macaqueERP/data/raw/R7475/';
addpath(datadir) % So X_loadcnt() is available
outfile='C:/Users/Felicity/macaqueERP/data/errordata.mat'; % Output filename
dosave = 1; % Whether or not to save
oldrate=2000; % Sampling rate in Hz
epochstart=-0.2; % Start of epoch in s
epochend=0.4; % End of epoch in s
newrate=200; % New sampling rate in Hz
channels=[30:43; 1:14]; % V4 and IT LFP channels
data=cell(2,2); % Store output data
v4vsit={'V4','IT'}; % The names of the two sites

stimcount=zeros(2,2,2,length(channels)); % Number of stimuli; dimensions are: audio/visual | IT/V4 |  no stimulus/no response | channel 


%% 1. Loading data

allfiles=dir([datadir '*.cnt']); % Get all file names
nfiles=length(allfiles);
% nfiles = 1;


for Z=1:nfiles % Loop over files (stay as 1 just for error checking)
    fprintf('\nLoading file %i of %i (%s)...\n',Z,nfiles,allfiles(Z).name)
    tmpdata=X_loadcnt(allfiles(Z).name);
    origdata=tmpdata.data'; % Pull out the interesting array and transpose it
    
    
    
    %% 2. Decide on whether trial block is attend-auditory or attend-visual, and save times of errors
    xaxis=(0:length(origdata)-1)/oldrate; % Set up an x-axis to plot everything
    
    labels={'Auditory target (green: lever)','Visual target (green: lever)'};
    levertimes=diff(origdata(:,61)); levertimes=find(levertimes>200); % Pull out lever times
    npulls=length(levertimes); % How many times the monkey pulled the lever
    audodd=diff(origdata(:,58)); audodd=find(audodd<-200); % Pull out auditory oddball stimuli
    visodd=diff(origdata(:,60)); visodd=find(visodd<-200); % Pull out visual oddball stimuli
    audpositive=0;
    vispositive=0;


    % Time to find the errors

    % First, find the errors for using the lever for no reason.
    errorlevertimes = zeros(1, 30); % store the times in row vector 
    levercounting = 0; % to get the position in vector (also count errors)
    
    for i=1:length(levertimes) 
        tmpaud=levertimes(i)-audodd; % Find the time difference between the lever press and the stimuli
        tmpvis=levertimes(i)-visodd; % Find the time difference between the lever press and the stimuli
        tmpaud=tmpaud(tmpaud>0.05*oldrate & tmpaud<1.2*oldrate); % Give it between 100 ms and 1 s to respond
        tmpvis=tmpvis(tmpvis>0.05*oldrate & tmpvis<1.2*oldrate); % Give it between 100 ms and 1 s to respond
        
        if isempty(tmpvis)&&isempty(tmpaud)
            levercounting = levercounting + 1; 
            errorlevertimes(1, levercounting) = levertimes(i);
        end
    end
    fprintf('%d errors for pulling lever for no reason\n', levercounting)


    % Next, find the errors (assuming audio-attend) for not responding to odd auditory stimulus
    audcounting = 0;
    erroraudtimes = zeros(1, 30);
    for i = 1:length(audodd)
        diffaud = levertimes-audodd(i);
        diffaud = diffaud(diffaud>0.05*oldrate & diffaud<1.2*oldrate);
        if isempty(diffaud)
            audcounting = audcounting + 1;
            erroraudtimes(1, audcounting) = audodd(i);
        end
    end

    
    % Then, find the errors (assuming visual-attend) for not responding to odd visual stimulus
    viscounting = 0;
    errorvistimes = zeros(1, 30);
    for i = 1:length(visodd)
        diffvis = levertimes-visodd(i);
        diffvis = diffvis(diffvis>0.05*oldrate & diffvis<1.2*oldrate);
        if isempty(diffvis)
            viscounting = viscounting + 1;
            errorvistimes(1, viscounting) = visodd(i);
        end
    end


    % So if we see alot of errors for one type, say audio, this implies that type
    % is not being attended (hopefully), so we can conclude visual-attend
    if viscounting > audcounting
        fprintf('%d errors for failing to respond to odd auditory stimulus\n', audcounting);

        A = 1; % A= 1 means we are attending audio
        errortimes = [errorlevertimes; erroraudtimes];
    elseif audcounting > viscounting
        fprintf('%d errors for failing to respond to odd visual stimulus\n', viscounting);
        A = 2; % A= 2 means we are attending visual
        errortimes = [errorlevertimes; errorvistimes];

    else
        disp('Monkey confused about which stimulus to attend to\n');
        A=input('Auditory (1) or visual (2)? ');
        if A == 1
           errortimes = [errorlevertimes; erroraudtimes];
           fprintf('%d errors for failing to respond to odd auditory stimulus\n', audcounting);
        else
           errortimes = [errorlevertimes; errorvistimes];
           fprintf('%d errors for failing to respond to odd visual stimulus\n', viscounting);
        end
    end
    
    % Now begin to collate the data into a nice structure thing

    for Q=1:2 % Loop over V4 vs. IT
        
        %% 3. Store additional information
        data{A,Q}.filename=[datadir allfiles(Z).name]; % Which file did the data come from originally?
        data{A,Q}.epoch=[epochstart epochend]; % How big is the window?
        data{A,Q}.channels=channels(Q,:); % Which channels to pull from the file?
        data{A,Q}.Hz=newrate; % What's the sampling rate in Hz?

         % What area the data is from: V4 or IT
        if Q == 1
            data{A,Q}.area='IT';
        else
            data{A,Q}.area='V4';
        end

        if A ==1
            data{A,Q}.attend='audio'; % Which stimulus type is being attended to in this data
        else
            data{A,Q}.attend='visual'; % Which stimulus type is being attended to in this data
        end
        
        %% 3. Split the data up into trials
        trialtypes={'nostimulus','noleverresponse'}; % Trial types -- audio no stim, audio no response, visno stim , vis no response
        ntypes=length(trialtypes);
        nchannels=length(channels);
        npts=ceil((epochend-epochstart)*newrate); % Number of points in each trial window
        newptsbefore=-epochstart*newrate; % How many points before the stimulus to use
        newptsafter=epochend*newrate; % How many points after the stimulus to use
        oldptsbefore=-epochstart*oldrate;
        oldptsafter=epochend*oldrate;
        data{A,Q}.xaxis=linspace(epochstart,epochend,npts); % For plotting -- store time information
        
        fprintf('  Splitting %i of %i into epochs...\n',Q,2);
        for i=1:ntypes % Loop over no stimulus and no lever response
            fprintf('    Working on type %i of %i...\n',i,ntypes);
            % Get the stimulus times
            % thisstim=origdata(:,stimindices(i)); % Pull out the stimuli
            % totalpts=length(thisstim); % Total number of data points
            % stimdiff=diff(thisstim); % Detect changes in the stimuli
            % stimtimes=find(stimdiff<-200); % Changes are huge decreases (~-500) in the stim time series
            totalpts = length(origdata(:, 57));
            stimtimes = errortimes(i, :);
           
            stimtimes=stimtimes(stimtimes>oldptsbefore & stimtimes<(totalpts-oldptsafter)); % Remove stimuli that are too close to the beginning or end of the recording
            stimtimes = stimtimes(stimtimes ~=0);
            nstims=length(stimtimes); % Number of stimuli
            % Set up the array to store results in
            if Z==1, data{A,Q}.(trialtypes{i})=zeros(nchannels,3000,npts); end % Set up array if not set up before, 3000 is arbitrary to make it big enough
            
            % Pull out the corresponding data
            for j=1:nchannels
                for k=1:nstims
                    stimcount(A,Q,i,j)=stimcount(A,Q,i,j)+1; % Total number of stimuli -- sum over files (Z) and k but nothing else
                    thisdata=origdata(stimtimes(k)-oldptsbefore:stimtimes(k)+oldptsafter,channels(Q,j)); 
                    % Pull out the data; oldrate/newrate is to give one extra data point. Also need to *stimtimes by old rate to get correct numbers
                    
                    tmp=downsample(thisdata,oldrate/newrate); % Downsample to the desired rate
                    data{A,Q}.(trialtypes{i})(j,stimcount(A,Q,i,j),:)=tmp; % Append to entire array
                end
            end
        end
    end
end

for A=1:2
    for Q=1:2
        for i=1:ntypes
            data{A,Q}.(trialtypes{i})=data{A,Q}.(trialtypes{i})(:,1:stimcount(A,Q,i,1),:); % Trim extra "rows"
        end
    end
end

if dosave
    fprintf('\nSaving data...\n')
    save(outfile,'data') % Save data
    disp('...done.')
end

% checkplot = data{2,1};
% xdata = checkplot.xaxis;
% meanydata = squeeze(mean(checkplot.noleverresponse(2,1,:),2));
% plot(xdata,meanydata)
% xlabel('Time (s)')
% ylabel('Voltage (\muV)')
% 
% disp('Done');
