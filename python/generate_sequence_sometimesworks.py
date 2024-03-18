import networkx as nx
import itertools
import math
import random
from collections import Counter
def generate_trials(trial_types, block_num, test_num, sequence_length):
    # Generates trial blocks with even sequence effects up to the order_effect order.
    # Basically it generates a graph that is traversed randomly, where the traversal removes edges,
    # the graph is created where edges are valid sequences of trials.
    trial_permutations = list(itertools.product(trial_types, repeat=sequence_length))
    permutation_num = len(trial_permutations)
    trials_per_block = ((permutation_num*test_num)/block_num)+sequence_length-1
    if math.floor(trials_per_block) - trials_per_block != 0:
        raise ValueError("Cannot evenly divide " + permutation_number*test_num + " trials over " + block_num + " blocks.")
        
    
    trial_graph = generate_trial_graph(trial_permutations, test_num, sequence_length)

    # Choose a random start node, then move from node to node recording the first letter of the node as the trial.
    start_node = random.choice(list(trial_graph.nodes))

    if trial_graph.nodes[start_node]["trial_count"]-1 == 0:
        if trial_graph.has_edge(start_node, start_node):
            trial_graph.remove_edge(start_node, start_node)
        pot_trials = nx.neighbors(trial_graph, start_node)
        trials = list(trial_graph.nodes[start_node]["trials"])
        trial_graph.remove_node(start_node)
    else:
        trial_graph.nodes[start_node]["trial_count"] -= 1
        trials = list(trial_graph.nodes[start_node]["trials"])
        pot_trials = nx.neighbors(trial_graph, start_node)
    # Start generating the rest of the trials.
    for i in range(0, int(trials_per_block)-2):
        pot_trials = list(pot_trials)
        new_node = random.choice(pot_trials)
        node_found = is_good_node(trial_graph, new_node)
       
        if not node_found:
            pot_trials.remove(new_node)
            while not node_found:
                new_node = random.choice(pot_trials)
                node_found = is_good_node(trial_graph, new_node)
                
                if not node_found:
                    pot_trials.remove(new_node)

        trials.append(trial_graph.nodes[new_node]["trials"][-1])

        if trial_graph.nodes[new_node]["trial_count"]-1 == 0:
            pot_trials = list(nx.neighbors(trial_graph, new_node))
            if new_node in pot_trials: pot_trials.remove(new_node)
            trial_graph.remove_node(new_node)
        else:
            trial_graph.nodes[new_node]["trial_count"] -= 1
            pot_trials = nx.neighbors(trial_graph, new_node) 
        
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

def is_good_node(trial_graph, node):
    cut_graph = trial_graph.copy()
    node_neighbors = list(nx.neighbors(cut_graph, node))
    
    # Set up what the network looks like after making the move.
    if cut_graph.nodes[node]["trial_count"]-1 == 0:
        cut_graph.remove_node(node)
        if node in node_neighbors: node_neighbors.remove(node)
        needs_cycle = False
    else:
        needs_cycle = True
    
    if nx.is_empty(cut_graph):
        return True

    # Find a traversal through all the remaining nodes.
    for source_node in node_neighbors:
        has_path, has_cycle = network_traversal(cut_graph, source_node)
        if needs_cycle and has_cycle:
            return True
        else:
            return has_path

def network_traversal(network, node):
    cut_network = network.copy()
    if cut_network.nodes[node]["trial_count"]-1 == 0:
        all_paths = []
        for neighbor in nx.neighbors(cut_network, node):
            if node != neighbor:
                all_paths.append([neighbor])
        cut_network.remove_node(node)
        needs_cycle = False
    else:
        all_paths = [[node]]
        needs_cycle = True
    
    for path in all_paths:
        current_neighbors = nx.neighbors(cut_network, path[-1])
        for neighbor in current_neighbors:
            if neighbor not in path:
                all_paths.append(path + [neighbor])

    if len(all_paths) != 0:
        max_path_length = len(max(all_paths, key=len))
    else:
        max_path_length = 0

    maximal_paths = []

    full_path = len(cut_network.nodes) == max_path_length
    
    for path in all_paths:
        if len(path) == max_path_length:
            maximal_paths.append(path)

    maximal_cycles = []
    
    for path in maximal_paths:
        if node in nx.neighbors(cut_network, path[-1]):
            maximal_cycles.append(path+[node])

    if len(maximal_cycles) > 0:
        full_cycle = len(cut_network.nodes) == len(max(maximal_cycles, key=len))
    else:
        full_cycle = False 

    return full_path, (full_cycle >= needs_cycle)
            
def test_function():
    fail = 0
    succ = 0
    trials = generate_trials(["A","B","C","D"], 1, 2, 2)
        #trial_congruency = []
        #for iTrial in range(0, len(trials)-1):
        #    trial_congruency.append(trials[iTrial]+trials[iTrial+1])
        #second_order_values = set(Counter(list(trial_congruency)).values())
        #if list(second_order_values) == [2]:
        #    print("Success")
    print(trials)
if __name__ == "__main__":
    test_function()
