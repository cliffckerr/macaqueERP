% Load the file and 

filename = 'C:/Users/Felicity/macaqueERP/data/epocheddata.mat';
d = load(filename);

electrode = 1;
trial = 4;


exampledata = d.data{1,1};

xdata = exampledata.xaxis;
ydata = squeeze(exampledata.odd(electrode,trial,:));

meanydata = squeeze(mean(exampledata.odd(electrode,:,:),2));

plot(xdata,meanydata)


disp('Done.')