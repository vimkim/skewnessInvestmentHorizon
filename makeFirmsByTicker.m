%if exist('~/fullDataWithLogRet.mat', 'file')
%    fprintf("mat file found!\n");
%    load('~/fullDataWithLogRet.mat', 'fullData');
%else
%    fprintf("mat file doet not exist.\n")
%    fprintf("creating a new one...\n")
%    fprintf("read csv...\n");
%    disp(datestr(now, 'HH:MM:SS')); % displays time
%    %fullData = readtable("fulldata1.csv"); % 1000000 lines
%    fullData = readtable("fulldata.csv"); % 15153834 lines
%
%    disp("date..");
%    disp(datestr(now, 'HH:MM:SS')); % displays time
%    fullData.datenums = datenum(fullData.date);
%
%    disp("logP..");
%    disp(datestr(now, 'HH:MM:SS')); % displays time
%    fullData.logP = log(fullData.adj_close);
%
%    disp("logRet");
%    disp(datestr(now, 'HH:MM:SS')); % displays time
%    fullData.logRet = [NaN; diff(fullData.logP)];
%    % save things
%
%    disp("save...");
%    disp(datestr(now, 'HH:MM:SS')); % displays time
%    %save('fullData1WithLogRet.mat', 'fullData');
%    save('~/fullDataWithLogRet.mat', 'fullData');
%    disp(datestr(now, 'HH:MM:SS')); % displays time
%end

if exist('~/firmsById.mat', 'file')
    fprintf("mat file found!\n");
    load('~/firmsById.mat', 'fullData');
end


load chirp; sound(y,Fs); clear y Fs % beeping sound when matlab reaches this line.


uniqTicker = unique(fullData.ticker);

% add Uniq id
fullData{:,'id'} = NaN;
for i = 1:length(uniqTicker)
    fprintf("%d\n", i);z
    fullData.id(ismember(fullData.ticker, uniqTicker(i))) = i;
end
save('~/fullDataWithLogRetAndID.mat', 'fullData', '-v7.3', '-nocompression');



uniqId = [1:length(uniqTicker)]';
firmsById = table(uniqId);

firmsById{:,'firm'} = {NaN};

firmN = length(uniqId);
n = 0;
i_thisId = 0;
i_nextId = 1;
for i = 1 : firmN-1
    % shows progress of forloop
    % code obtained from https://stackoverflow.com/questions/8825796/how-to-clear-the-last-line-in-the-command-window
    msg = sprintf('Processed: %d/%d', i, firmN);
    fprintf(repmat('\b', 1, n));
    fprintf(msg);
    n=numel(msg);

    %thisTicker = uniqTicker(i);
    %oneFirm = fullData(fullData.PERMNO == thisPermno, :);
    %oneFirm = fullData(strcmp(fullData.ticker, thisTicker), :);
    %firmsByTicker.firm(i) = {fullData(ismember(fullData.ticker, uniqTicker(i)), :)};
    thisId = uniqId(i);
    i_thisId = i_nextId;
    nextId = uniqId(i+1);
    i_nextId = find(fullData.id == i+1, 1);

    oneFirm = fullData(i_thisId: i_nextId-1, :);
    firmsById.firm(i) = {oneFirm};
end
firmsById.firm(firmN) = {fullData(i_nextId:end,:)};

load chirp; sound(y,Fs); clear y FS % beeping sound when matlab reaches this line.

save('~/firmsById.mat', 'firmsById', '-v7.3', '-nocompression');
