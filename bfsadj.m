function visited = bfsadj(adj_matrix, source)
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