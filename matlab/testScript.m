trials = generatetrials({'A', 'B'}, 4, 60, 1);
trialTypeCounts = zeros(1, 2);

for iBlock = 1:size(trials, 1)
    for iTrial = 1:size(trials, 2)
        if strcmp(trials{iBlock, iTrial}, 'A')
            trialTypeCounts(1) = trialTypeCounts(1) + 1;
        elseif strcmp(trials{iBlock, iTrial}, 'B')
            trialTypeCounts(2) = trialTypeCounts(2) + 1;
        end
    end
end
if trialTypeCounts(1)==60 && trialTypeCounts(2) == 60
    disp("Single Sequence Test: Success")
else
    warning("Single Sequence Test: Fail")
end

trials = generatetrials({'A', 'B'}, 4, 60, 2);
trialTypeCounts = zeros(1, 4);

for iBlock = 1:size(trials, 1)
    for iTrial = 1:(size(trials, 2)-1)
        if strcmp(trials{iBlock, iTrial}, 'A') && strcmp(trials{iBlock, iTrial+1}, 'A')
            trialTypeCounts(1) = trialTypeCounts(1) + 1;
        elseif strcmp(trials{iBlock, iTrial}, 'A') && strcmp(trials{iBlock, iTrial+1}, 'B')
            trialTypeCounts(2) = trialTypeCounts(2) + 1;
        elseif strcmp(trials{iBlock, iTrial}, 'B') && strcmp(trials{iBlock, iTrial+1}, 'A')
            trialTypeCounts(3) = trialTypeCounts(3) + 1;
        elseif strcmp(trials{iBlock, iTrial}, 'B') && strcmp(trials{iBlock, iTrial+1}, 'B')
            trialTypeCounts(4) = trialTypeCounts(4) + 1;
        end
    end
end
if trialTypeCounts(1)==60 && trialTypeCounts(2) == 60 && trialTypeCounts(3) == 60 && trialTypeCounts(4) == 60
    disp("Two Sequence Test: Success")
else
    warning("Two Sequence Test: Fail")
end

trials = generatetrials({1, 2, 3, 4}, 1, 2, 2);
trials = [trials{:}];
trialWindows = [trials(1:end-1)' trials(2:end)'];
trialWindowCounts = [];
for row = 1:size(trialWindows,1)
    trialWindowCounts = [trialWindowCounts sum(min(trialWindows == [1 1], [], 2))];
end
if max(trialWindowCounts) == 2 && min(trialWindowCounts) == 2
    disp("Test succ")
end



if trialTypeCounts(1)==60 && trialTypeCounts(2) == 60 && trialTypeCounts(3) == 60 && trialTypeCounts(4) == 60
    disp("Two Sequence Test: Success")
else
    warning("Two Sequence Test: Fail")
end
