% Load the file and 

filename = 'C:/Users/Felicity/macaqueERP/data/epocheddata.mat';
errorfilename = 'C:/Users/Felicity/macaqueERP/data/errordata.mat';
norm = load(filename);
error = load(errorfilename);

electrode = round(input('Which electrode? (1-14)\n'));

normdata = norm.data{1,1}.odd;
errordata = error.data{1,1}.noleverresponse;
xdata = norm.data{1,1}.xaxis;

normmeanydata = squeeze(mean(normdata(electrode,:,:),2));
errormeanydata = squeeze(mean(errordata(electrode,:,:),2));
plot(xdata,normmeanydata)
hold on
plot(xdata, errormeanydata)
xlabel('Time (s)')
ylabel('Voltage (\muV)')

disp('Done.')