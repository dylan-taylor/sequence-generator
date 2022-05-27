function trialsOutput = generatetrials(trialTypes, blockNum, testNum, sequenceLength)
    % Creates a cell array containing each trial block on each row, with
    % columns representing the trial ordering. The blocks and trial
    % ordering are designed so that each sequence effect has equal number
    % of trials.
    %
    % trialsOutput = GENERATETRIALS(trialType, blockNum, testNum, sequenceLength)
    %
    % trialsOutput - A blockNum-by-trialType^sequenceLength cell array.
    % trialType - A list of the types of trials in the experiment.
    % blockNum - Number of blocks in the experiment.
    % testNum - The number of times each sequence effect should be run.
    % sequenceLength - The length of the sequence of interest.

    syms = trialTypes;
    symbol_num = length(syms);
    symbols = 1:symbol_num;
    
    permutations = generatepermutations(symbols, sequenceLength);
    perm_num = length(permutations);

    trials_per_block = ((perm_num*testNum)/blockNum)+sequenceLength-1; % NEED TO CHECK IF NATURAL NUMBER

    adj_matrix = generateadjmatrix(permutations);

    trial_order = zeros(blockNum, trials_per_block);
    order_idx = sequenceLength+1;

    freq_matrix = (adj_matrix*testNum);

    pos = randsample(1:perm_num, 1, true, sum(freq2prob(freq_matrix)));

    for block = 1:blockNum

        prob_matrix = freq2prob(freq_matrix~=0);
        pos_prob = augmentprobability(prob_matrix, pos);
        pos = randsample(1:perm_num, 1, true, pos_prob);
        trial_order(block, 1:sequenceLength) = permutations(pos, :);
        freq_matrix(:,pos)=max(freq_matrix(:,pos)-1, 0);

        for trial = sequenceLength+1:trials_per_block
            prob_matrix = freq2prob(freq_matrix~=0);
            pos_prob = augmentprobability(prob_matrix, pos);
            pos = randsample(1:perm_num, 1, true, pos_prob);
            trial_order(block, trial) = permutations(pos, sequenceLength);
            freq_matrix(:,pos)=max(freq_matrix(:,pos)-1, 0);
        end
    end

    trialsOutput = cell(blockNum, size(trial_order, 2));
    for i = 1:blockNum
        for j = 1:size(trial_order, 2)
            trialsOutput(i,j) = syms(trial_order(i,j));
        end
    end
end