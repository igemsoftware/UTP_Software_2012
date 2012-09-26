function [Log, PrimerSequence] = S2MT(UserInput, DesiredStd)
    clc;
    PrimerSequence = '';
    
    % Analyze the user input

    valid = 0;
    if findstr(lower(UserInput),'partsregistry.org') ~= 0
        %% Get the sequence from the URL

        sourcePart = urlread(UserInput);

        % Identifying the sequence within the source code

        searchStart = 'var sequence = new String(';
        searchEnd = ');';
        m = findstr(sourcePart, searchStart);

        % Can we get the DNA sequence with the given URL?
        if isempty(m)
            frpintf(2, 'ERROR: The URL is not valid or the part have no accesible DNA sequence \n');
            Log = 'ERROR: The URL is not valid or the part have no accesible DNA sequence';
            valid = 1;
        else
            n = findstr(sourcePart(m:length(sourcePart)), searchEnd);

            % Display the Sequence

            disp(upper(sourcePart(m + length(searchStart) + 1:n(1) + m - 3)));
            sequence = upper(sourcePart(m + length(searchStart) + 1:n(1) + m - 3));
        end
    else
        %% Validate the DNA sequence from the input

        sequence = upper(UserInput);
        for i = 1:length(sequence)
            if ((sequence(i) ~= ('A')) && (sequence(i) ~= ('C')) && (sequence(i) ~= ('G')) && (sequence(i) ~= ('T')))
                valid = 1;
                fprintf(2, 'ERROR: The input string is not valid \n');
                Log = 'ERROR: The input string is not valid';
                break;
            end
        end   
    end

    if valid == 0
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


        % Specify compatibility or incomp..
        for i = 1:numel(standardnames)
            if DesiredStd == standardnames{i}
                DesiredStdN = i;
            end
        end

        if sum(standards{DesiredStdN} == result) >= 1
            disp(sprintf('Incompatible with RFC[%s]', DesiredStd));
            
            % Codons to aminoacids for different frames
            for i = 1:3
                aminoSeqFrames{i} = nt2aa(sequence, 'Frame', i);
            end
            SeqOrfs = seqshoworfs(sequence);
            
            ProspectSum = [0 0 0];
            
            for i = 1:3
                for j = 1:numel(SeqOrfs(i))
                    if (SeqOrfs(i).Stop(j) - SeqOrfs(i).Start(j)) > ProspectSum(i)
                        ProspectSum(i) = (SeqOrfs(i).Stop(j) - SeqOrfs(i).Start(j));
                    end
                end
            end
            
            k = 1;
            if ProspectSum(2) > ProspectSum(1)
                k = 2;
            elseif ProspectSum(3) > ProspectSum(1)
                k = 3;
            end
                    
            % ======= Site directed Mutagenesis ========
                % Instructions for Primers Design (stratagene protocol)
            % 1. Both the mutagenic primers must contain the desired mutation and anneal to the same
            % sequence on opposite strands of the plasmid.
            % 2. Primers should be between 25 and 45 bases in length, and the melting temperature (Tm) of
            % the primers should be greater than or equal to 78°C. The following formula is commonly
            % used for estimating the Tm of primers:
            % Tm = 81.5 + 0.41(%GC) ? 675 / N ? % mismatch
            % where N is the primer length in base pairs.
            % 3. The desired mutation (deletion or insertion) should be in the middle of the primer with
            % ~10–15 bases of correct sequence on both sides.
            % 4. The primers optimally should have a minimum GC content of 40% and should terminate
            % in one or more C or G bases.

            mapAmino = revgeneticcode('standard');
            for i = 1:numel(place) % Loop over all restriction site positions (if founded)
                for j = 1:length(place{i}) % In the case a restriction site was found multiple times
                    l = 12;
                    Tm = 77;
                    while (Tm < 78) % Tm must be higher than 78°C
                        roundingStart = place{i}(j) - rem(place{i}(j), 3) + k - 1; % To determine the middle point of Primer
                        if (roundingStart + l + 2) < length(sequence) ...
                                && (roundingStart - l) > 0 % Not to exceed sequence size
                            prSeq{i, j} = sequence(roundingStart - l: ...
                                roundingStart + l + 2); % Select the sequence for primer +- 12 bp
                            primerAmino{i, j} = nt2aa(prSeq{i, j}, 'Frame', 1); % Translate selection to Aminoacids
                            middleAmino = ceil(length(primerAmino{i, j}) / 2);
                            if primerAmino{i, j}(middleAmino) == '*' % To avoid problems with stop codons
                                newCodon{i, j} = mapAmino.Stops;
                            else
                                newCodon{i, j} = mapAmino.(primerAmino{i, j}(middleAmino));
                            end
                            if sum(char(newCodon{i, j}(1)) == prSeq{i, j}(l + 1:l + 3)) == 3 % Select a different codon for that AminoAcid
                                Primer{i, j} = char(strcat(prSeq{i, j}(1:l), newCodon{i, j}(2), prSeq{i, j}(l + 4:2*l + 3)));
                            else
                                Primer{i, j} = char(strcat(prSeq{i, j}(1:l), newCodon{i, j}(1), prSeq{i, j}(l + 4:2*l + 3)));
                            end
                            % Obtaining Tm value
                            totalbase = basecount(Primer{i, j});
                            perctGC = (totalbase.C + totalbase.G)/(totalbase.C + totalbase.A + totalbase.G + totalbase.T);
                            Tm = 81.5 + 41 * perctGC - 675 / length(Primer{i, j});
                            l = l + 3;
                            if (prSeq{i, j}(1) ~= 'G' && prSeq{i, j}(1) ~= 'C') || ...
                                (prSeq{i, j}(end) ~= 'G' && prSeq{i, j}(end) ~= 'C') %% Primers must end in C or G 
                                Tm = 77; %% Suppose the Tm is lower to make it go again. 
                            end
                            if l > 24
                                Primer{i, j} = [];
                                break;
                            end
                        else
                            break;
                        end
                    end
                end
            end

            % Delete empty cells
            Primer = Primer(~cellfun('isempty', Primer));

            % Start points for Primers:
            for i = 1:numel(Primer) % Loop over all restriction site positions (if founded)
                [Score, Alignment, Start{i}] = swalign(sequence, Primer{i});
                disp(sprintf('Starting position %d', Start{i}(1)));
                PrimerSequence = seqdisp(Primer{i}, 'Column', 3);
            end

            % Applying primer to make new sequence
            newSequence = sequence;
            for i = 1:numel(Primer)
                newSequence = strcat(newSequence(1:Start{i}(1) - 1), Primer{i}, newSequence(Start{i}(1) + length(Primer{i}):end));
            end

            % Show both Sequences, new and old with different color in the changed base
            %[Score, Alignment] = nwalign(sequence, newSequence, 'ExtendGap', 2000);
            %showalignment(Alignment)

            % Comparing NEWSequence to standards

            for i = 1:numel(restSites)
                place{i} = findstr(newSequence, restSites{i});
                if size(place{i}) ~= 0
                    result_new(i) = 1;
                else
                    result_new(i) = NaN;
                end
            end

            % Specify compatibility or incomp..
            
            if sum(standards{DesiredStdN} == result_new) >= 1
                disp(sprintf('Incompatibility with RFC[%s] cannot be fixed', DesiredStd));
                Log = strcat('Cannot fix incompatibility with standard ', DesiredStd);
                PrimerSequence = '';
            elseif sum(standards{DesiredStdN} == result) >= 1 && sum(standards{DesiredStdN} == result_new) == 0
                disp(sprintf('Now is compatible with RFC[%s]', DesiredStd));
                Log = strcat('Fixed compatibility with standard ', DesiredStd);
            end

        else
            disp(sprintf('Compatible with RFC[%s]', DesiredStd));
            Log = strcat('Sequence is compatible with standard ', DesiredStd);
            PrimerSequence = '';
        end
            
    end
