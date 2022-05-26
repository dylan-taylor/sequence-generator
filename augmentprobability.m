function aug_prob = augmentprobability(prob_matrix, pos)
    pos_prob = prob_matrix(pos, :);
    for i = 1:length(pos_prob)
        if pos_prob(i) > 0 
            if (sum(prob_matrix)==0) <= 1
                cut = graphcut(prob_matrix, i);
                pos_prob(i) = pos_prob(i)*cut;
            end 
        end
    end
    aug_prob = pos_prob;
end