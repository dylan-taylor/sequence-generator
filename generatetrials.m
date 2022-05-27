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

    trialsPerBlock = ((perm_num*testNum)/blockNum)+sequenceLength-1;
    if floor(trialsPerBlock)-trialsPerBlock ~= 0
        error(strcat("Cannot evenly divide ", num2str(perm_num*testNum),  " trials over ", num2str(blockNum),  " blocks."))
    end

    adj_matrix = generateadjmatrix(permutations);

    trialOrder = zeros(blockNum, ceil(trialsPerBlock));
    order_idx = sequenceLength+1;

    freq_matrix = (adj_matrix*testNum);

    pos = randsample(1:perm_num, 1, true, sum(freq2prob(freq_matrix)));

    for block = 1:blockNum
        prob_matrix = freq2prob(freq_matrix~=0);
        pos_prob = augmentprobability(prob_matrix, pos);
        pos = randsample(1:perm_num, 1, true, pos_prob);
        trialOrder(block, 1:sequenceLength) = permutations(pos, :);
        freq_matrix(:,pos)=max(freq_matrix(:,pos)-1, 0);

        for trial = sequenceLength+1:trialsPerBlock
            prob_matrix = freq2prob(freq_matrix~=0);
            pos_prob = augmentprobability(prob_matrix, pos);
            pos = randsample(1:perm_num, 1, true, pos_prob);
            trialOrder(block, trial) = permutations(pos, sequenceLength);
            freq_matrix(:,pos)=max(freq_matrix(:,pos)-1, 0);
        end

    end

    trialsOutput = cell(blockNum, size(trialOrder, 2));
    for i = 1:blockNum
        for j = 1:size(trialOrder, 2)
            trialsOutput(i,j) = syms(trialOrder(i,j));
        end
    end
end