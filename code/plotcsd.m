% errorfilename = '/u/cliffk/drive/usyd/macaqueERP/data/errordata.mat';
errorfilename = 'C:/Users/Felicity/macaqueERP/data/errordata.mat';
error = load(errorfilename);
errordata = error.data{2,1}.noleverresponse(:, :, :);
errorthingall = zeros(size(errordata,1)-2,size(errordata,2),size(errordata,3));
for i=1:size(errordata,2)
    tmp = squeeze(errordata(:, i, :));
    ecsd = diff(diff(tmp));
    errorthingall(:, i, :) = ecsd;
end
meanerror = squeeze(mean(errorthingall,2));
pcolor(meanerror)