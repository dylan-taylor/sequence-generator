import networkx as nx
import csv
import itertools
import math
import random
from collections import Counter

def generate_trials(trial_types, block_num, test_num, sequence_length, save_csv = False, file_name = "trials.csv"):
    # Generates trial blocks with even sequence effects up to the order_effect order.
    # Basically it generates a graph that is traversed randomly, where the traversal removes edges,
    # the graph is created where edges are valid sequences of trials.
    trial_permutations = list(itertools.product(trial_types, repeat=sequence_length))
    permutation_num = len(trial_permutations)
    trials_per_block = ((permutation_num*test_num)/block_num)+sequence_length-1
    if math.floor(trials_per_block) - trials_per_block != 0:
        raise ValueError("Cannot evenly divide " + permutation_num*test_num + " trials over " + block_num + " blocks.")
    trials_per_block = int(trials_per_block)     
    
    trial_graph = generate_trial_graph(trial_permutations, test_num, sequence_length)
    trials = []
    initial_node = random.choice(list(trial_graph.nodes))
    potential_nodes = get_good_nodes(trial_graph, initial_node)    
    # Choose a random start node, then move from node to node recording the first letter of the node as the trial.
    for i_block in range(0, block_num):
        new_node = random.choice(list(potential_nodes))
        block_trials = list(trial_graph.nodes[new_node]["trials"])
        trial_graph.nodes[new_node]["trial_count"] -= 1
        
        if trial_graph.nodes[new_node]["trial_count"] == 0:
            potential_nodes = get_good_nodes(trial_graph, new_node)
            trial_graph.remove_node(new_node)
        else:
            potential_nodes = get_good_nodes(trial_graph, new_node)
        
        # Start generating the rest of the trials.
        for i_trial in range(sequence_length, trials_per_block):
            new_node = random.choice(potential_nodes)
            block_trials.append(trial_graph.nodes[new_node]["trials"][-1])
            trial_graph.nodes[new_node]["trial_count"] -= 1
            if trial_graph.nodes[new_node]["trial_count"] == 0:
                potential_nodes = get_good_nodes(trial_graph, new_node)
                trial_graph.remove_node(new_node)
            else:
                potential_nodes = get_good_nodes(trial_graph, new_node)
        trials.append(block_trials)
    if save_csv:
        with open(file_name, 'w') as csv_file:
            csv_writer = csv.writer(csv_file, delimiter = ',')
            for trial_block in trials:
                csv_writer.writerow(trial_block)

    return trials

def generate_trial_graph(trial_permutations, test_num, sequence_length):
    trial_graph = nx.DiGraph()
    for iPerm in trial_permutations:
        trial_graph.add_node("".join(iPerm), trials = iPerm, trial_count = test_num)

    for iPerm in trial_permutations:
        for jPerm in trial_permutations:
            if iPerm[1:] == jPerm[0:(sequence_length-1)]:
                trial_graph.add_edge("".join(iPerm), "".join(jPerm))
    return trial_graph

def get_good_nodes(trial_graph, node=None, global_search=False):
    augmented_graph = trial_graph.copy()
    if not global_search:
        if node != None:
            node_neighbors = list(nx.neighbors(trial_graph, node))
            if augmented_graph.nodes[node]["trial_count"] == 0:
                if node in node_neighbors: node_neighbors.remove(node)
                augmented_graph.remove_node(node)
        else:
            raise ValueError("Not a global search, but no node given")
    else:
        print("global search")
        node_neighbors = trial_graph.nodes

    if len(augmented_graph.nodes) == 1:
        return node_neighbors

    potential_nodes = []
    for neighbor in node_neighbors:
        cut_node = False
        cut_graph = augmented_graph.copy()
        neighbor_neighbors = list(nx.neighbors(cut_graph, neighbor))
        neighbor_bfs = list(nx.bfs_tree(cut_graph, neighbor))
        
        if len(neighbor_neighbors) == 0 and len(trial_graph.nodes) > 1:
            cut_node = True
        
        if neighbor not in trial_graph.nodes:
            cut_node = True

        if len(neighbor_neighbors) > 0:
            for graph_node in cut_graph.nodes:
                if (graph_node not in neighbor_bfs) and len(list(cut_graph.successors(graph_node))) > 0:
                    cut_node = True
        cut_graph.remove_node(neighbor)
        
        if not cut_node:
            potential_nodes.append(neighbor)

    return potential_nodes

            
def test_function():
    print("Testing first order single block sequence")
    first_order_single_block_repeats = 100
    test_results = []
    for i_test in range(0, 100):
        trial_type_count = random.randint(1, 100)
        trials = generate_trials(["A","B","C","D"], 1, trial_type_count, 1)
        if list(set(Counter(list(trials[0])).values())) == [trial_type_count]:
            test_results.append(True)
        else:
            test_results.append(False)
            print("Failed on: ", trial_type_count)
    if list(set(test_results)) == [True]: 
        print("First order test: Success")
    else:
        print("First order test: Fail")
    
    print("Testing first order, multiblock sequence")
    first_order_multiblock_repeats = 100
    test_results = []
    
    for i_test in range(0, first_order_multiblock_repeats):
        block_count = random.randint(2, 20)
        trial_type_count = random.randint(1,10)*block_count

        trials = generate_trials(["A","B","C","D"], block_count, trial_type_count, 1)
        counts = {}
        for block_trials in trials:
            trial_counts = Counter(block_trials)
            dict_keys = trial_counts.keys()
            for trial_type in dict_keys:
                if trial_type in counts:
                    counts[trial_type] += trial_counts[trial_type]
                else:
                    counts[trial_type] = trial_counts[trial_type]
        if list(set(counts.values())) == [trial_type_count]:
            test_results.append(True)
        else:
            test_results.append(False)

    if list(set(test_results)) == [True]:
        print("First order, multiblock test: Success")
    else:
        print("First order, multiblock test: Fail")
    
    print("Testing second order single block sequence")
    trials = generate_trials(["A","B","C","D"], 1, 60, 2)
    trial_congruency = []
    for iTrial in range(0, len(trials[0])-1):
        trial_congruency.append(trials[0][iTrial]+trials[0][iTrial+1])
    if list(set(Counter(list(trial_congruency)).values())) == [60]:
        print("Second order test: Success")
    else:
        print("Second order test: Fail")

    print("Testing second order, multiblock sequence.")
    trials = generate_trials(["A","B","C","D"], 4, 60, 2)
    counts = {}
    
    for block_trials in trials:
        trial_congruency = []
        for iTrial in range(0, len(trials[0])-1):
            trial_congruency.append(block_trials[iTrial]+block_trials[iTrial+1])
        trial_counts = Counter(trial_congruency)
        dict_keys = trial_counts.keys()
        for trial_type in dict_keys:
            if trial_type in counts:
                counts[trial_type] += trial_counts[trial_type]
            else:
                counts[trial_type] = trial_counts[trial_type]
    if list(set(counts.values())) == [60]:
        print("Second order, multiblock test: Success")
    else:
        print("Second order, multiblock test: Fail")
    
    print("Testing third order single block sequence")
    trials = generate_trials(["A","B","C","D"], 1, 60, 3)
    trial_congruency = []
    for iTrial in range(0, len(trials[0])-2):
        trial_congruency.append(trials[0][iTrial]+trials[0][iTrial+1]+trials[0][iTrial+2])
    if list(set(Counter(list(trial_congruency)).values())) == [60]:
        print("Third order test: Success")
    else:
        print("Third order test: Fail")
    

if __name__ == "__main__":
    test_function()
