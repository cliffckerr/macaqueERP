filename = '/u/cliffk/bill/data/juemo/raw/epocheddata.mat';
d = load(filename);

electrode = 1;
trial = 4;


exampledata = d.data{1,1};

xdata = exampledata.xaxis;
ydata = squeeze(exampledata.odd(electrode,trial,:));

meanydata = squeeze(mean(exampledata.odd(electrode,:,:),2));

plot(xdata,meanydata)


disp('Done.')