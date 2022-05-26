% Start with this, but in final have user give the wanted strings, and then
% convert to numbers. When the sequence is generated convert back to the
% requested symbols.

function trials_output = generatetrials(trial_types, block_num, trial_num, sequence_length)
    syms = trial_types;
    symbol_num = length(syms);
    symbols = 1:symbol_num;
    
    permutations = generatepermutations(symbols, sequence_length);
    perm_num = length(permutations);

    trials_per_block = ((perm_num*trial_num)/block_num)+sequence_length-1; % NEED TO CHECK IF NATURAL NUMBER

    adj_matrix = generateadjmatrix(permutations);

    trial_order = zeros(block_num, trials_per_block);
    order_idx = sequence_length+1;

    freq_matrix = (adj_matrix*trial_num);

    pos = randsample(1:perm_num, 1, true, sum(freq2prob(freq_matrix)));

    for block = 1:block_num

        prob_matrix = freq2prob(freq_matrix~=0);
        pos_prob = augmentprobability(prob_matrix, pos);
        pos = randsample(1:perm_num, 1, true, pos_prob);
        trial_order(block, 1:sequence_length) = permutations(pos, :);
        freq_matrix(:,pos)=max(freq_matrix(:,pos)-1, 0);

        for trial = sequence_length+1:trials_per_block
            prob_matrix = freq2prob(freq_matrix~=0);
            pos_prob = augmentprobability(prob_matrix, pos);
            pos = randsample(1:perm_num, 1, true, pos_prob);
            trial_order(block, trial) = permutations(pos, sequence_length);
            freq_matrix(:,pos)=max(freq_matrix(:,pos)-1, 0);
        end
    end

    trials_output = cell(block_num, size(trial_order, 2));
    for i = 1:block_num
        for j = 1:size(trial_order, 2)
            trials_output(i,j) = syms(trial_order(i,j));
        end
    end
end