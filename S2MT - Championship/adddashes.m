function test = adddashes(string, lengthseq)
%   Adds required dashes to a sequence where there are only white spaces. 
%   lengthseq = length(sequence);
%   Usefull when concatenating multiple short sequences in specific
%   positions.
c = [find(string == 'A')'; find(string == 'C')'; find(string == 'G')'; find(string == 'T')'; find(string == '-')';];
test = string;
test(setdiff(1:lengthseq, c)) = '-';