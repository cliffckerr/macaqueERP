% note that in the data files, the IT and V4 labels are swapped.
% so label accordingly 

% load the files 
filename = 'C:/Users/Felicity/macaqueERP/data/epochedtemp.mat';
errorfilename = 'C:/Users/Felicity/macaqueERP/data/errordata.mat';
norm = load(filename);
error = load(errorfilename);

%now we have to take the csd over all trials and compute the mean csd
normdata = norm.data{2,1}.odd(:, :, :);
stddata = norm.data{2,1}.std(:, :, :);
errordata = error.data{2,1}.noleverresponse(:, :, :);
xdata = norm.data{2,2}.xaxis;

% create the csd arrays 
normthingall = zeros(size(normdata,1)-2,size(normdata,2),size(normdata,3));
errorthingall = zeros(size(errordata,1)-2,size(errordata,2),size(errordata,3));
stdthingall = zeros(size(stddata,1)-2,size(stddata,2),size(stddata,3));

for i=1:size(errordata,2)
    tmp = squeeze(errordata(:, i, :));
    ecsd = diff(diff(tmp));
    errorthingall(:, i, :) = ecsd;
end

for i=1:size(normdata,2)
    tmp = squeeze(normdata(:, i, :));
    ncsd = diff(diff(tmp));
    normthingall(:, i, :) = ncsd;
end

for i=1:size(stddata,2)
    tmp = squeeze(stddata(:, i, :));
    scsd = diff(diff(tmp));
    stdthingall(:, i, :) = scsd;
end

normthing = squeeze(normthingall(1, :, :)); % take the 10th group
errorthing = squeeze(errorthingall(1, :, :));
stdthing = squeeze(stdthingall(1, :, :));

upperlim = quantile(normthing,0.75,1);
middle = quantile(normthing,0.5,1); % same as median
lowerlim = quantile(normthing,0.25,1);

eupperlim = quantile(errorthing,0.75,1);
emiddle = quantile(errorthing,0.5,1); % same as median
elowerlim = quantile(errorthing,0.25,1);

supperlim = quantile(stdthing,0.75,1);
smiddle = quantile(stdthing,0.5,1); % same as median
slowerlim = quantile(stdthing,0.25,1);

X  = [xdata, fliplr(xdata)];
Ye = [eupperlim,fliplr(elowerlim)]; 
Yo = [upperlim,fliplr(lowerlim)]; 
Ys = [supperlim,fliplr(slowerlim)]; 

subplot(2,2,1)
hold on
nf = fill(X,Yo,'b', 'FaceAlpha', 0.2,'EdgeAlpha',.3 );
nl = plot(xdata,middle,'b','LineStyle',':');

ef = fill(X,Ye,'r', 'FaceAlpha', 0.2,'EdgeAlpha',.3 );
el = plot(xdata,emiddle,'r','LineStyle',':');
legend([nf,nl,ef,el],'norm IQ', 'norm median','error IQ','error median');
title('error vs odd');
xlabel('Time (s)')
ylabel('CSD D^2[\muV]')
xlim([-0.2 0.4])
hold off
%error againt std
subplot(2,2,2)
hold on

ef = fill(X,Ye,'r', 'FaceAlpha', 0.2,'EdgeAlpha',.3 );
el = plot(xdata,emiddle,'r','LineStyle',':');

sf = fill(X,Ys,'g', 'FaceAlpha', 0.2,'EdgeAlpha',.3 );
sl = plot(xdata,smiddle,'g','LineStyle',':');


legend([sf,sl,ef,el],'std IQ', 'std median','error IQ','error median')
title('error vs std');
xlabel('Time (s)')
ylabel('CSD D^2[\muV]')
xlim([-0.2 0.4])
hold off

subplot(2,2,[3,4]) 
hold on
sf = fill(X,Ys,'g', 'FaceAlpha', 0.2,'EdgeAlpha',.3 );
sl = plot(xdata,smiddle,'g','LineStyle',':');

nf = fill(X,Yo,'b', 'FaceAlpha', 0.2,'EdgeAlpha',.3 );
nl = plot(xdata,middle,'b','LineStyle',':');

legend([sf,sl,nf,nl],'std IQ','std median','norm IQ', 'norm median')
xlabel('Time (s)')
ylabel('CSD D^2[\muV]')
xlim([-0.2 0.4])
ylim([-3 3])
hold off


