function [sequence, phredscores] = phdreader(direction);
%       Reads a phd file, and returns the embedded sequence and 
%       the phredscores for each base. 

fid = fopen(direction);
sequence = '';
tline = fgetl(fid);
i = 0;
flag = 0;
while ischar(tline)
    if strcmp(tline, 'BEGIN_DNA') && ~flag
        flag = 1;
        i = 0;
    elseif flag
        sequence = strcat(sequence, tline(1:1));
        idx = strfind(tline, ' '); 
        phredscores(i) = str2num(tline(3:idx(2)));
    end
    i = i + 1;
    tline = fgetl(fid);
    if strcmp(tline, 'END_DNA')
        break;
    end
end

fclose(fid);