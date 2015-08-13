filename = '/u/cliffk/bill/data/juemo/raw/epocheddata.mat';
d = load(filename);

for i = 1:size(d.data,1)
    for j = 1:size(d.data,2)
        fields = fieldnames(d.data{i,j});
        for f = 1:length(fields)
            filename = sprintf('../data/%i_%i_%s.mat', i, j, fields{f});
            disp(filename)
            tmp = d.data{i,j}.(fields{f});
            save(filename, 'tmp')
        end
    end
end