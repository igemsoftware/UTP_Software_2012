function out = longestword(alignment)
%   Outputs the large of words in the sequence
%   Most things were commented to work with only one sequence at a time and
%   gain speed. 
% size = length(alignment);
% definingscore = zeros(size, 1);
% for i = 1:size
%     if ~iscell(alignment)
    	test = find(alignment == '|');
%     else
%         test = find(alignment{i} == '|');
%     end
    test2 = (test + 1) ./3;
    %Creating a binary sequence in a string with no spaces
    s = diff(test2) == 1;
    s = sprintf('%d',s);
    %Reading the consequences of 1's from the string by using 0's as delimiters
    t1 = textscan(s,'%s','delimiter','0','multipleDelimsAsOne',1);
    % Converting cell array of cell into a single cell array
    d = t1{:};
    % Computing the length of each run by going through the array and assigning
    % it into
    for k = 1:length(d)
        data(k) = length(d{k});
    end
    % Using histogram function to compute the number of times for each length
%     [~, run_length] = hist(data, 1:max(data));
%     definingscore(i) = max(run_length);
    definingscore = max(data);

%     clear run_length;
% end

% Outputs 
if ~iscell(alignment)
    out = definingscore;
else
    hist(definingscore)
end

