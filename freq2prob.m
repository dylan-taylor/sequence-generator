function X = freq2prob(F)
    X = zeros(length(F));
    for i = 1:length(F)
        if sum(F(i,:)) ~= 0
            X(i,:) = F(i,:)./sum(F(i,:));
        else
            X(i,:) = 0;
        end
    end
end