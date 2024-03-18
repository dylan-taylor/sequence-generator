function adj_matrix = generateadjmatrix(permutation_list)
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