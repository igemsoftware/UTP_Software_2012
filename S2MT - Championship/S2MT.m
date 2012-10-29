function [Log, PrimerSequence, newSequence] = S2MT(UserInput, DesiredStd)
%   Test values:
%   UserInput = 'http://partsregistry.org/Part:BBa_K743005';
%   DesiredStd = '10';
    clc;
    PrimerSequence = '';
    newSequence = '';
    if strfind(DesiredStd, '25')
        DesiredStd = '25';
    end
    % Analyze the user input

    valid = 0;
    
    if strfind(lower(UserInput),'partsregistry.org') ~= 0
        %% Get the sequence from the URL

        sourcePart = urlread(UserInput);

        % Identifying the sequence within the source code

        searchStart = 'var sequence = new String(';
        searchEnd = ');';
        m = strfind(sourcePart, searchStart);

        % Can we get the DNA sequence with the given URL?
        if isempty(m)
            frpintf(2, 'ERROR: The URL is not valid or the part have no accesible DNA sequence \n');
            Log = 'ERROR: The URL is not valid or the part have no accesible DNA sequence';
            valid = 1;
        else
            n = strfind(sourcePart(m:length(sourcePart)), searchEnd);

            % Display the Sequence

            disp(upper(sourcePart(m + length(searchStart) + 1:n(1) + m - 3)));
            sequence = upper(sourcePart(m + length(searchStart) + 1:n(1) + m - 3));
        end
    else
        %% Validate the DNA sequence from the input
        UserInput=regexprep(UserInput,'[^\w'']','');
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
        % Find the restriction sites. 
        [place, result, standardnames, ~, standards] = restsites(sequence); 

        % Specify compatibility or incomp..
        for i = 1:numel(standardnames)
            if str2num(DesiredStd) == str2num(standardnames{i})
                DesiredStdN = i;
            end
        end

        if sum(standards{DesiredStdN} == result) >= 1
            disp(sprintf('Incompatible with RFC[%s]', DesiredStd));
            
            % Codons to aminoacids for different frames
%             for i = 1:3
%                 aminoSeqFrames{i} = nt2aa(sequence, 'Frame', i);
%             end
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

            % Delete empty cells and duplicates
            Primer = Primer(~cellfun('isempty', Primer));
            Primer = unique(Primer);
%             ~isempty(Primer)
            if ~isempty(Primer)
                % Start points for Primers:
                for i = 1:numel(Primer) % Loop over all restriction site positions (if founded)
                    [~, ~, Start{i}] = swalign(sequence, Primer{i});
                    string(1, Start{i}(1):Start{i}(1)+length(Primer{i}) - 1) = Primer{i};
                end
                % View the complete sequence aligned with primers
                string = adddashes(string, length(sequence));
                [~, Alignment] = nwalign(sequence, string);    
                showalignment(Alignment)

                % Add the start position values to the sequence
                primerdisp = seqdisp(Primer);
                for i = 1:numel(Start)
                    PrimerSequence(2*i - 1, :) = strrep(primerdisp(2*i - 1, :), '1', num2str(Start{i}(1)));  
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
            
                [~, result] = restsites(newSequence);
            end    
            % Specify compatibility or incomp..
            
            if sum(standards{DesiredStdN} == result) >= 1
                disp(sprintf('Incompatibility with RFC[%s] cannot be fixed', DesiredStd));
                Log = strcat('The selected standard (', DesiredStd, ') is unfixable with this method.');
                PrimerSequence = '';
                newSequence = '';
                
            elseif sum(standards{DesiredStdN} == result) == 0
                disp(sprintf('Now is compatible with RFC[%s]', DesiredStd));
                Log = strcat('Fixed compatibility with standard ', DesiredStd);
                
            end

        else
            disp(sprintf('Compatible with RFC[%s]', DesiredStd));
            Log = strcat('Sequence is compatible with standard ', DesiredStd);
            PrimerSequence = '';
            
        end
            
    end
