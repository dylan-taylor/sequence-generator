using Graphs
using MetaGraphs

function generate_trials(trial_types, block_num, test_num, sequence_length; save_csv=false, file_name="trials.csv")
    trial_permutations_iter = Iterators.product(fill(A, sequence_length) ...)
    trial_permutations_matrix = collect(trial_permutations_iter)
    trial_permutations = reshape(trial_permutations_matrix, :, 1)
    permutation_num = length(trial_permutations)
    trials_per_block = ((permutation_num*test_num)/block_num)+sequence_length-1
    # ADD ERROR HERE IF TRIALS PER BLOCK IS NON WHOLE NUMBER
    return(trial_permutations, generate_trial_graph(trial_permutations, test_num, sequence_length))
    
end

function generate_trial_graph(trial_permutations, test_num, sequence_length)
    # First generate a simple digraph
    adjacency_matrix = zeros(length(trial_permutations), length(trial_permutations))
    for (permutation_idx, source_permutation) in enumerate(trial_permutations)
        for (permutation_jdx, target_permutation) in enumerate(trial_permutations)
            if source_permutation[2:end] == target_permutation[1:(end-1)]
                adjacency_matrix[permutation_idx, permutation_jdx] = 1
            end
        end
    end
    simple_trial_graph = Graphs.SimpleDiGraph(adjacency_matrix)
    # Then initialise the graph as a metagraph with test_num weights
    weighted_named_trial_graph = MetaDiGraph(simple_trial_graph, test_num)
end