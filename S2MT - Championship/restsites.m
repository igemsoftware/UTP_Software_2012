function [place, result, standardnames, restSites, standards] = restsites(sequence)   
% Restriction Sites

        EcoRI = ('GAATTC');
        NotI = ('GCGGCCGC');
        XbaI = ('TCTAGA');
        SpeI = ('ACTAGT');
        PstI = ('CTGCAG');
        NgoMIV = ('GCCGGC');
        AgeI = ('ACCGGT');
        BglII = ('AGATCT');
        BamHI = ('GGATCC');
        XhoI = ('CTCGAG');
        NheI = ('GCTAGC');
        restSites = {EcoRI, NotI, XbaI, SpeI, PstI, NgoMIV, AgeI, BglII, BamHI, XhoI, NheI};

        % Standards 
        % If the standar contains a restriction site, 1, else 0. 
        std10 = [1 1 1 1 1 0 0 0 0 0 0];
        std25 = [1 1 1 1 1 1 1 0 0 0 0];
        std21 = [1 0 0 0 0 0 0 1 1 1 0];
        std23 = [1 1 1 1 1 0 0 0 0 0 0];
        std12 = [1 0 0 1 1 0 0 0 0 0 1];
        standards = {std10 std12 std21 std23 std25};
        standardnames = {'10' '12' '21' '23' '25'};

        % Comparing Sequence to standards

        for i = 1:numel(restSites)
            place{i} = findstr(sequence, restSites{i});
            if size(place{i}) ~= 0
                result(i) = 1;
            else
                result(i) = NaN;
            end
        end