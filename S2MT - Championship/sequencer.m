function [finaloutput, elapsedTime, errormsg] = sequencer(directory, reverse)
%   This function admits only phred score files. 
%   Directory must be in the form: 'C:\...\*.phd.1', where *.phd.1 indicates 
%   that all phd.1 files should be selected
    tic;
    finaloutput = '';
    errormsg = '';

if ~isdir(directory)
    errormsg = 'Invalid directory, please change it.';
    elapsedTime = toc;
    return
end
% Reading phd.1 sequences
addpath(directory);
directory = strcat(directory, '*.phd.1');
fnames = dir(directory);
numfids = length(fnames);
if numfids > 10
    errormsg = 'More than 10 files, program may crash, separate them in groups please.';
    elapsedTime = toc;
    return;
end
seq = cell(numfids, 1);
score = cell(numfids, 1);
for K = 1:numfids
    [seq{K}, score{K}] = phdreader(fnames(K).name);
    if strfind(fnames(K).name, reverse)
        seq{K} = seqrcomplement(seq{K});
        score{K} = fliplr(score{K});
    end
end
% steps = 1;
% Remove phredscores below threshold
phredscore = 10;
lessthan = zeros(numfids, 1);
cleanSeq = cell(numfids, 1);
for K = 1:numfids
    if mean(score{K}) < 20
        lessthan(K) = 1;
    else
        threshold = score{K} > phredscore;
        cleanSeq{K} = seq{K}(threshold);
    end
end
cleanseqnames = fnames(~lessthan);
cleanSeq(logical(lessthan)) = [];
% steps = steps + 1; % 2
% Compare all sequence and find best matches
K = combnk(1:length(cleanSeq), 2);
until = size(K, 1);
f = cell(until, 1);
fscore = zeros(until, 1);
for i = 1:until
      [fscore(i), f{i}] = nwalign(cleanSeq{K(i, 1)},...
        cleanSeq{K(i, 2)},'ScoringMatrix','BLOSUM100', 'glocal', true, 'GapOpen', 40, 'ExtendGap', 10000);
end
% steps = steps + 1; % 3
%
until = size(f, 1);
datamax = zeros(until, 1);
for i = 1:until
    datamax(i) = (longestword(f{i}));
end
x = find(datamax > 20);
[~, IX] = sort(datamax, 'descend');
% steps = steps + 1; % 4
% Always put the first sequence before the second (not viceversa)
seqvalues = zeros(length(x), 2);
for i = 1:length(x)
    if find(f{IX(i)}(1:3) == '-') == 3
        seqvalues(i, :) = K(IX(i), :);
    else
        seqvalues(i, :) = fliplr(K(IX(i), :));
    end
end
% steps = steps + 1; % 5
% Greedy algorithm
if isempty(seqvalues)
    errormsg = 'The program couldnt create any contigs, check the bases quality';
    elapsedTime = toc;
    return
end
finalchain = seqvalues;  % replicate the highest score combination values
uniques = unique(seqvalues); % Look for the amount of different values
while (length(finalchain)) ~= (length(uniques) - 1) 
    finalchain(end, :) = []; % Delete extra combinations than can be redudant 
end
% As the combinations should form a chain of overlappings, test until
% getting the correct order
testdiags = spdiags(finalchain(:, [2, 1]));
order = 1:length(finalchain);
cycle = 1;
maxtest = 0;
while sum(testdiags(1,2:end-1) == testdiags(2, 2:end-1)) ~= length(finalchain) - 1
    % As we are working with small quantities of sequences doing it by
    % random permutations won't take too long. If you are working with more
    % than 10 sequences to align, look for a better way. 
    order = randperm(length(finalchain));
    testdiags = spdiags(finalchain(order, [2, 1]));
    if cycle > 200
        errormsg = 'A single consensed sequence can not be found, in order to work, all contigs must form a big chain';
        elapsedTime = toc;
        return;
    end    
end
% steps = steps + 1; % 6
% Multialign
i = IX(order);
for j = 1:length(order) % All the indexes will now serve to align
    k = 2 * j - 1;
    if sum(K(i(j), :) == finalchain(order(j), :)) == 2
        groupfinalseq{k, :} = f{i(j)}(1, :);
        groupfinalseq{k + 1, :} = f{i(j)}(3, :);
    else
        groupfinalseq{k, :} = f{i(j)}(3, :);
        groupfinalseq{k + 1, :} = f{i(j)}(1, :);
    end
end
% steps = steps + 1; % 7
% Present the result
allseqtogether = multialign(groupfinalseq, 'DelayCutoff', 0.01);

namesidx = reshape(finalchain(order, :)', [], 1);
seqalignviewer(allseqtogether([1, 2:2:end], :), 'SeqHeaders', {cleanseqnames(namesidx([1, 2:2:end])).name})

% Output the consensus sequence
finaloutput = seqconsensus(allseqtogether([1, 2:2:end], :));
elapsedTime = toc;
