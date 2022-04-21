% Start with this, but in final have user give the wanted strings, and then
% convert to numbers. When the sequence is generated convert back to the
% requested symbols.

trials = generate_trials({'iL', 'iR', 'cL', 'cR'}, 8, 60, 2);

function trials_output = generate_trials(trial_types, block_num, trial_num, sequence_length)
    syms = trial_types;
    symbol_num = length(syms);
    symbols = 1:symbol_num;
    
    permutations = generate_permutations(symbols, sequence_length);
    perm_num = length(permutations);

    trials_per_block = ((perm_num*trial_num)/block_num)+sequence_length-1; % NEED TO CHECK IF NATURAL NUMBER

    adj_matrix = generate_adj_matrix(permutations);

    trial_order = zeros(block_num, trials_per_block);
    order_idx = sequence_length+1;

    freq_matrix = (adj_matrix*trial_num);

    pos = randsample(1:perm_num, 1, true, sum(freq2prob(freq_matrix)));

    for block = 1:block_num

        prob_matrix = freq2prob(freq_matrix~=0);
        pos_prob = augment_probability(prob_matrix, pos);
        pos = randsample(1:perm_num, 1, true, pos_prob);
        trial_order(block, 1:sequence_length) = permutations(pos, :);
        freq_matrix(:,pos)=max(freq_matrix(:,pos)-1, 0);

        for trial = sequence_length+1:trials_per_block
            prob_matrix = freq2prob(freq_matrix~=0);
            pos_prob = augment_probability(prob_matrix, pos);
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

function visited = BFS_adj(adj_matrix, source)
    visits = zeros(1, length(adj_matrix));
    queue = [source];
    while ~isempty(queue)
        visit = queue(1);
        visits(queue(1)) = 1;
        queue(1) = [];
        for j = 1:length(adj_matrix)
            if (adj_matrix(visit, j) == 1) && (visits(j) ~= 1)
                queue = [queue j];
                visits(j) = 1;
            end
        end
    end
    visited = visits;
end

function no_cut = graph_cut(prob_matrix, node)
    cut_graph = prob_matrix;
    cut_graph(:,node) = 0;
    cut_graph = cut_graph~=0;
    visited = BFS_adj(cut_graph, node);
    no_cut = 1;
    for k = 1:length(prob_matrix)
        if (visited(k) == 0) && (sum(cut_graph(:,k))>0)
            no_cut = 0;
        end
    end
end

function aug_prob = augment_probability(prob_matrix, pos)
    pos_prob = prob_matrix(pos, :);
    for i = 1:length(pos_prob)
        if pos_prob(i) > 0 
            if (sum(prob_matrix)==0) <= 1
                cut = graph_cut(prob_matrix, i);
                pos_prob(i) = pos_prob(i)*cut;
            end 
        end
    end
    aug_prob = pos_prob;
end

function X = freq2prob(F)
    X = zeros(length(F));
    for i = 1:length(F)
        if sum(F(i,:)) ~= 0
            X(i,:) = F(i,:)./sum(F(i,:));
        else
            X(i,:) = 0;
        end
    end
end

function permutations = generate_permutations(symbols, permutation_length)
    % Generate all the possible permutations of the given number symbol set.
    perm_iter = permutation_length;
    
    % If permutation_length is greater than 1, compute first cartesian
    % product and then loop through cartesian products until desired 
    % permutation  length is reached. Else, if permutation length is 1  
    % return the list. Toss out an error for < 1 or non-integer entries.
    if permutation_length > 1
        A = symbols';
        ma = size(A,1);
        [a, b] = ndgrid(1:ma, 1:ma);
        permutations_array = [A(a,:), A(b,:)];
        for i = 3:perm_iter
            ma = size(A,1);
            mb = size(permutations_array,1);
            [a, b] = ndgrid(1:ma, 1:mb);
            permutations_array = [A(a,:), permutations_array(b,:)];
        end
        permutations = permutations_array;
    elseif permutation_length == 1
        permutations = symbols';
        % ADD ERROR IF INPUT NOT NATURAL NUMBER
    end
end

function adj_matrix = generate_adj_matrix(permutation_list)
    % Create a matrix representing what permutations start and end with
    % each other. Defines the allowed grammer of the string.
    perm_num = size(permutation_list, 1);
    adj = zeros(perm_num);
    perm_length = size(permutation_list, 2);
    
    % For each permutation, find all other permutations that start with the
    % sequence that the permutation ends with. Since only a single symbol
    % is added each time, the entire rest of the permutation must much.
    for i = 1:perm_num
        [row, ~] = find(ismember(permutation_list(:,1:(perm_length-1)), permutation_list(i,(2:perm_length)), 'rows'));
        adj(i, row') = 1;
    end
    adj_matrix = adj;
end