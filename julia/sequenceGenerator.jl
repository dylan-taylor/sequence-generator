using Graphs
using MetaGraphs

function generate_trials(trial_types, block_num, test_num, sequence_length; save_csv=false, file_name="trials.csv")
    trial_permutations_iter = Iterators.product(fill(trial_types, sequence_length) ...)
    trial_permutations_matrix = collect(trial_permutations_iter)
    trial_permutations = reshape(trial_permutations_matrix, :, 1)
    permutation_num = length(trial_permutations)
    trials_per_block = ((permutation_num*test_num)/block_num)+sequence_length-1
    # ADD ERROR HERE IF TRIALS PER BLOCK IS NON WHOLE NUMBER
    
    trial_graph = generate_trial_graph(trial_permutations, test_num, sequence_length)
    
    trials = []
    # initial_node = 

    return trial_graph
end

function generate_trial_graph(trial_permutations, test_num, sequence_length)
    adjacency_matrix = zeros(length(trial_permutations), length(trial_permutations))
    for (permutation_idx, source_permutation) in enumerate(trial_permutations)
        for (permutation_jdx, target_permutation) in enumerate(trial_permutations)
            if source_permutation[2:end] == target_permutation[1:(end-1)]
                adjacency_matrix[permutation_idx, permutation_jdx] = 1
            end
        end
    end
    simple_trial_graph = Graphs.SimpleDiGraph(adjacency_matrix)
    
    weighted_trial_graph = MetaDiGraph(simple_trial_graph, test_num)
    
    for vertex in vertices(weighted_trial_graph)
        set_prop!(weighted_trial_graph, :trial_names, join(trial_permutations[vertex], ""))
    end

    return weighted_trial_graph
end
