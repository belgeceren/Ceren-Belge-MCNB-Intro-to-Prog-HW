
n_participant = 60;                                  % Number of participants
factor_1 = {"familiar","unfamiliar"};                % Familiarity levels
factor_2 = {"positive","negative","neutral"};        % Emotion levels
n_blocks = length(factor_1) * length(factor_2);      % Total blocks per participant = 2 x 3 = 6

rng('shuffle');  % Random seed based on system time (different each run)

% Generate all possible orders (permutations) of the 3 emotions → 3! = 6
factor_2_permutation = perms(1:3);

% Assign 10 participants to each emotion order (60 participants / 6 permutations = 10)
perm_ids = repelem(1:size(factor_2_permutation,1), n_participant/size(factor_2_permutation,1))';

% Randomly shuffle the assignment so that participants receive the permutations in random order
perm_ids = perm_ids(randperm(n_participant));
%Counterbalance
factor_1_first = [true(30,1); false(30,1)];  % true = familiar-first, false = unfamiliar-first
factor_1_first = factor_1_first(randperm(n_participant));  % Randomize the order
%Output table
block_col_names = arrayfun(@(k) sprintf("Block%d",k), 1:n_blocks, "UniformOutput",false);
block_table = table('Size',[n_participant, 3+n_blocks], ...
    'VariableTypes', ["double","string","logical", repmat("string",1,n_blocks)], ...
    'VariableNames', ["Participant","StartEmotion","Factor1Start", block_col_names]);
%pseudorandomized block order
for p = 1:n_participant

    % Determine the emotion order for this participant
    emo_idx   = factor_2_permutation(perm_ids(p), :);
    emo_order = factor_2(emo_idx);

    % Determine the familiarity order (either familiar→unfamiliar or vice versa)
    if factor_1_first(p)
        fam_order = {factor_1{1}, factor_1{2}};  % familiar → unfamiliar
    else
        fam_order = {factor_1{2}, factor_1{1}};  % unfamiliar → familiar
    end

    % Create 6 blocks:
    % For each emotion (outer loop), add the two corresponding familiarity blocks consecutively
    % ensures that the same emotion's blocks are presented one after another.
    blocks = strings(1, n_blocks); 
    k = 1;
    for e = 1:numel(emo_order)
        for f = 1:numel(fam_order)
            blocks(k) = emo_order{e} + "_" + fam_order{f};
            k = k + 1;
        end
    end

    % Fill in the table for this participant
    block_table.Participant(p)  = p;
    block_table.StartEmotion(p) = string(emo_order{1});   % Emotion of the first block pair
    block_table.Factor1Start(p) = factor_1_first(p);      % Familiarity start flag (true = familiar)
    for b = 1:n_blocks
        block_table{p, 3+b} = blocks(b);
    end
end
%Display 
disp(block_table);
