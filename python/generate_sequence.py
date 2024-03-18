import networkx as nx
import itertools
import math
import random
from collections import Counter
def generate_trials(trial_types, block_num, test_num, sequence_length, generate_csv = False, file_name = "None"):
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
    new_node = random.choice(list(trial_graph.nodes))

    if trial_graph.nodes[new_node]["trial_count"]-1 == 0:
        if trial_graph.has_edge(new_node, new_node):
            trial_graph.remove_edge(new_node, new_node)
        pot_trials = get_good_nodes(trial_graph, new_node)
        trials = list(trial_graph.nodes[new_node]["trials"])
        trial_graph.remove_node(new_node)
    else:
        trial_graph.nodes[new_node]["trial_count"] -= 1
        trials = list(trial_graph.nodes[new_node]["trials"])
        pot_trials = get_good_nodes(trial_graph, new_node)

    # Start generating the rest of the trials.
    while len(trial_graph.nodes) > 0:
        new_node = random.choice(pot_trials)
        trials.append(trial_graph.nodes[new_node]["trials"][-1])
        trial_graph.nodes[new_node]["trial_count"] -= 1
        if trial_graph.nodes[new_node]["trial_count"] == 0:
            pot_trials = get_good_nodes(trial_graph, new_node)
            trial_graph.remove_node(new_node)
        else:
            pot_trials = get_good_nodes(trial_graph, new_node)
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

def get_good_nodes(trial_graph, node):
    node_neighbors = list(nx.neighbors(trial_graph, node))
    augmented_graph = trial_graph.copy()
    
    if augmented_graph.nodes[node]["trial_count"] == 0:
        if node in node_neighbors: node_neighbors.remove(node)
        augmented_graph.remove_node(node)

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
    print("Testing first order sequence")
    trials = generate_trials(["A","B","C","D"], 1, 60, 1)
    if list(set(Counter(list(trials)).values())) == [60]:
        print("First order test: Success")
    else:
        print("First order test: Fail")
    
    print("Testing second order sequence")
    trials = generate_trials(["A","B","C","D"], 1, 60, 2)
    trial_congruency = []
    for iTrial in range(0, len(trials)-1):
        trial_congruency.append(trials[iTrial]+trials[iTrial+1])
    if list(set(Counter(list(trial_congruency)).values())) == [60]:
        print("Second order test: Success")
    else:
        print("Second order test: Fail")

    print("Testing third order sequence")
    trials = generate_trials(["A","B","C","D"], 1, 60, 3)
    trial_congruency = []
    for iTrial in range(0, len(trials)-2):
        trial_congruency.append(trials[iTrial]+trials[iTrial+1]+trials[iTrial+2])
    if list(set(Counter(list(trial_congruency)).values())) == [60]:
        print("Third order test: Success")
    else:
        print("Third order test: Fail")

    print(trials)
if __name__ == "__main__":
    test_function()
