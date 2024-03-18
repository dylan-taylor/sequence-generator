function no_cut = graphcut(prob_matrix, node)
    cut_graph = prob_matrix;
    cut_graph(:,node) = 0;
    cut_graph = cut_graph~=0;
    visited = bfsadj(cut_graph, node);
    no_cut = 1;
    for k = 1:length(prob_matrix)
        if (visited(k) == 0) && (sum(cut_graph(:,k))>0)
            no_cut = 0;
        end
    end
end