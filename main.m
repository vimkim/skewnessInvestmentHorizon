minN = 6;
firmN = 10000;

%fullData = readtable("testData.csv"); % 678 lines
%fullData = readtable("crsp20042008.csv"); % 200000 lines

% process things into log Price and log Returns
%if exist('fullData1WithLogRet.mat', 'file')
%    load('fullData1WithLogRet.mat', 'fullData');
if exist('~/fullDataWithLogRet.mat', 'file')
    load('~/fullDataWithLogRet.mat', 'fullData');
    disp("mat file found!");
else
    disp("read..");
    disp(datestr(now, 'HH:MM:SS')); % displays time
    %fullData = readtable("fulldata1.csv"); % 1000000 lines
    fullData = readtable("fulldata.csv"); % 15153834 lines

    disp("date..");
    disp(datestr(now, 'HH:MM:SS')); % displays time
    fullData.datenums = datenum(fullData.date);

    disp("logP..");
    disp(datestr(now, 'HH:MM:SS')); % displays time
    fullData.logP = log(fullData.adj_close);

    disp("logRet");
    disp(datestr(now, 'HH:MM:SS')); % displays time
    fullData.logRet = [NaN; diff(fullData.logP)];
    % save things

    disp("save...");
    disp(datestr(now, 'HH:MM:SS')); % displays time
    %save('fullData1WithLogRet.mat', 'fullData');
    save('~/fullDataWithLogRet.mat', 'fullData');
    disp(datestr(now, 'HH:MM:SS')); % displays time
end

%uniqPermno = unique(fullData.PERMNO);
uniqPermno = unique(fullData.ticker);

l = length(uniqPermno);
if firmN > l
    firmN = l
end


stat = table(uniqPermno);

stat.mean = NaN(l,1);
stat.stdev = NaN(l,1);
stat.skewness = NaN(l,1);
stat.kurtosis = NaN(l,1);

stat.yes = zeros(l,1);
stat.zeroskew = zeros(l,1);
stat.continued = zeros(l,1);


n = 0;
for i = 1 : firmN
    % shows progress of forloop
    % code obtained from https://stackoverflow.com/questions/8825796/how-to-clear-the-last-line-in-the-command-window
    msg = sprintf('Processed: %d/%d', i, firmN);
    fprintf(repmat('\b', 1, n));
    fprintf(msg);
    n=numel(msg);

    thisPermno = uniqPermno(i);
    %data = fullData(fullData.PERMNO == thisPermno, :);
    data = fullData(strcmp(fullData.ticker, thisPermno), :);
    %data.logP = log(data.adjustedPrice);
    %data.logP = log(data.adj_close);
    %data.logRet = [NaN; diff(data.logP)];
    logRet = data.logRet(2:end); % first logRet must be NaN. Getting rid of it.
    if length(logRet) <= 2
        stat.continued(i) = 1;
        continue;
    end

    stat.mean(i) = mean(logRet);
    stat.stdev(i) = std(logRet);
    stat.skewness(i) = skewness(logRet);

    IHday = 1; % investment horizon
    skewnesses = NaN(1,10);
    skewnesses(1) = stat.skewness(i);
    k = 1;

    while length(logRet) > minN % ensures at least minN sample number
        k = k+1;
        IHday = IHday * 2;
        logRet = doubleInvestmentHorizon(logRet);

        % new column
        skew = skewness(logRet);
        skewnesses(k) = skew;
    end

    % delete NaNs
    skewnesses(isnan(skewnesses)) = [];

    plot(skewnesses)
    hold on

    if ~isempty(skewnesses)
        if abs(skewnesses(1)) >= abs(skewnesses(end))
            stat.yes(i) = 1;
        end
    end

    if skewnesses(end) == 0
        stat.zeroskew(i) = 1;
    end
end

disp("sum of yes : " + sum(stat.yes));
disp("sum of zeroskew : " + sum(stat.zeroskew));
disp("sum of continued : " + sum(stat.continued));

function sumsOfTwoLogRets = doubleInvestmentHorizon(ret)
    l = length(ret);
    sumsOfTwoLogRets = NaN(floor(l/2),1);
    for i = 1 : length(sumsOfTwoLogRets);
        sumsOfTwoLogRets(i) = ret(2*i-1) + ret(2*i);
    end
end
