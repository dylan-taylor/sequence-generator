using Graphs
using MetaGraphs

function generate_trials(trial_types, block_num, test_num, sequence_length; save_csv=false, file_name="trials.csv")
    trial_permutations_iter = Iterators.product(fill(A, 3) ...)
    trial_permutations_matrix = collect(trial_permutations_iter)
    trial_permutations = reshape(trial_permutations_matrix, :, 1)
    permutation_num = length(trial_permutations)
    trials_per_block = ((permutation_num*test_num)/block_num)+sequence_length-1
    # ADD ERROR HERE IF TRIALS PER BLOCK IS NON WHOLE NUMBER

end

function generate_trial_graph(trial_permutations, test_num, sequence_length)
    # First generate a simple digraph
    
    # Then initialise the graph as a metagraph with test_num weights
end