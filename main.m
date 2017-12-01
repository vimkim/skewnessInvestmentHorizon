fprintf("program starts...")
disp(datestr(now, 'HH:MM:SS')); % displays time
minN = 10; % minimum value of minN must be 3. If 2, sample size is 2 and there is zero skewness
IHlimit = 10;
firmN = 10000;

%fullData = readtable("testData.csv"); % 678 lines
%fullData = readtable("crsp20042008.csv"); % 200000 lines

% process things into log Price and log Returns
%if exist('fullData1WithLogRet.mat', 'file')
%    load('fullData1WithLogRet.mat', 'fullData');

%if exist('~/fullDataWithLogRet.mat', 'file')
%    disp("mat file found!");
%    load('~/fullDataWithLogRet.mat', 'fullData');
%else
%    fprintf("mat file doet not exist.\n")
%    fprintf("creating a new one...\n")
%    disp("read csv...");
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
%
%uniqPermno = unique(fullData.PERMNO);
%uniqTicker = unique(fullData.ticker);
if ~exist('firmsById', 'var')
    if exist('~/firmsById.mat', 'file')
        disp("mat file found!");
        load('~/firmsById.mat');

        load chirp; sound(y,Fs); clear y FS % sounds when finished
    else
        fprintf("what should i do?\n");
    end

end
 % beeping sound when matlab reaches this line.

load('uniqTicker.mat', 'uniqTicker')

% firmN is the upper limit of the numbers of firms being tested. If the number of firms existing in the imported dataset is lower than the setted firmN, make firmN equals to l.
l = length(uniqTicker);
if firmN > l
    firmN = l
end

uniqId = [1:l]';

stat = table(uniqId);

stat{:,'skew'} = {NaN};

stat.yes = zeros(l,1);
stat.zeroskew = zeros(l,1);
stat.skipped = zeros(l,1);


n = 0;
for i = 1 : firmN
    % shows progress of forloop
    % code obtained from https://stackoverflow.com/questions/8825796/how-to-clear-the-last-line-in-the-command-window
    msg = sprintf('Processed: %d/%d', i, firmN);
    fprintf(repmat('\b', 1, n));
    fprintf(msg);
    n=numel(msg);

    oneFirm = firmsById.firm{i};

    logRet = oneFirm.logRet(2:end); % first logRet must be NaN by definition. Getting rid of it.

    if length(logRet) < minN % if the number of logRet is already smaller than 'minN', no need for this
        stat.skipped(i) = 1; % log the firms skipped.
        continue;
    end

    IHday = 1; % investment horizon in days
    skewnesses = NaN(1,IHlimit-1); % maximum 2^(20-1) days of skewness

    k = 1;
    while length(logRet) >= minN & k <= length(skewnesses) % ensures at least minN sample number
        skewnesses(k) = skewness(logRet);
        IHday = IHday * 2;
        logRet = logRet(1:2:end-1) + logRet(2:2:end);
        k = k+1;
    end
    
    skewnesses(isnan(skewnesses)) = [];
    stat.skew(i) = {skewnesses'};

    %delete NaNs
    

    %plot(skewnesses)
    %hold on

    %if skewnesses(end) == 0
    %    stat.zeroskew(i) = 1;
    %end
end

disp("sum of yes : " + sum(stat.yes));
disp("sum of zeroskew : " + sum(stat.zeroskew));
disp("number of skipped firms: " + sum(stat.skipped));

% plot 
for i = 1:firmN
    plot(2:length(stat.skew{i})+1, stat.skew{i});
    hold on
end
xlabel('Investment Horizon in log_2 days');
ylabel('Skewness of US stock log returns');
%set(gca, 'TickLabelInterpreter, 'latex');
saveas(gcf, 'fullDataPlot.png');

fprintf("program finishs!\n")

minv = 99999999;
index = 0;

for i = 1:firmN
    a = min(firmsById.firm{i}.datenums);
    if a < minv
        minv = a;
        index = i;
    end
end

% calculates if the first skewness is larger than the last skewness
stat{:,'is1'}=NaN;
for i = 1:firmN
    if length(stat.skew{i}) >= 2 && abs(stat.skew{i}(1)) >= abs(stat.skew{i}(end))
        stat.is1(i)=1;
    elseif length(stat.skew{i}) >= 2
        stat.is1(i)=0;
    end
end
nom = nansum(stat.is1);
denom = sum(~isnan(stat.is1));
fprintf("how many large? : %d / %d = %d\n", nom, denom, 100*nom/denom);

stat{:, 'is2'}=NaN;
for i = 1:firmN
    if length(stat.skew{i})>=4 && nanmean(abs(stat.skew{i}(1:2))) >= nanmean(abs(stat.skew{i}(end-1:end)))
        stat.is2(i) = 1;
    elseif length(stat.skew{i})>=4
        stat.is2(i) = 0;
    end
end
nom = nansum(stat.is2);
denom = sum(~isnan(stat.is2));
fprintf("how many large? : %d / %d = %d\n", nom, denom, 100*nom/denom);

stat{:, 'is3'}=NaN;
for i = 1:firmN
    if length(stat.skew{i})>=6 && nanmean(abs(stat.skew{i}(1:3))) >= nanmean(abs(stat.skew{i}(end-2:end)))
        stat.is3(i) = 1;
    elseif length(stat.skew{i})>=6
        stat.is3(i) = 0;
    end
end
nom = nansum(stat.is3);
denom = sum(~isnan(stat.is3));
fprintf("how many large? : %d / %d = %d\n", nom, denom, 100*nom/denom);

stat{:, 'is4'}=NaN;
for i = 1:firmN
    if length(stat.skew{i})>=8 && nanmean(abs(stat.skew{i}(1:4))) >= nanmean(abs(stat.skew{i}(end-3:end)))
        stat.is4(i) = 1;
    elseif length(stat.skew{i})>=8
        stat.is4(i) = 0;
    end
end
nom = nansum(stat.is4);
denom = sum(~isnan(stat.is4));
fprintf("how many large? : %d / %d = %d\n", nom, denom, 100*nom/denom);


