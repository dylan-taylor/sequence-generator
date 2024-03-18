function permutations = generatepermutations(symbols, permutation_length)
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