%CLIQUETREECALIBRATE Performs sum-product or max-product algorithm for 
%clique tree calibration.

%   P = CLIQUETREECALIBRATE(P, isMax) calibrates a given clique tree, P 
%   according to the value of isMax flag. If isMax is 1, it uses max-sum
%   message passing, otherwise uses sum-product. This function 
%   returns the clique tree where the .val for each clique in .cliqueList
%   is set to the final calibrated potentials.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CliqueTreeCalibrate(P, isMax)


% Number of cliques in the tree.
N = length(P.cliqueList);

% Setting up the messages that will be passed.
% MESSAGES(i,j) represents the message going from clique i to clique j. 
MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We have split the coding part for this function in two chunks with
% specific comments. This will make implementation much easier.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE
% While there are ready cliques to pass messages between, keep passing
% messages. Use GetNextCliques to find cliques to pass messages between.
% Once you have clique i that is ready to send message to clique
% j, compute the message and put it in MESSAGES(i,j).
% Remember that you only need an upward pass and a downward pass.
%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
if isMax
    for i = 1:length(P.cliqueList)
        P.cliqueList(i).val = log(P.cliqueList(i).val);
    end
end

[i, j] = GetNextCliques(P, MESSAGES);
while i ~= 0 || j ~= 0
    from = P.cliqueList(i).var;
    to = P.cliqueList(j).var;
    diff = setdiff(from,to);
    neighbors = find(P.edges(i,:) == 1);
    
    F = P.cliqueList(i);
    for f = 1:length(neighbors)
        if neighbors(f) ~= j && ~isempty(MESSAGES(neighbors(f),i).var)
            if isMax
                F = FactorSum(F, MESSAGES(neighbors(f),i));
            else
                F = FactorProduct(F, MESSAGES(neighbors(f),i));
            end
        end
    end
    
    if(isMax)
        MESSAGES(i,j) = FactorMaxMarginalization(F, diff);
    else
        MESSAGES(i,j) = FactorMarginalization(F, diff);
        MESSAGES(i,j).val = MESSAGES(i,j).val ./ sum(MESSAGES(i,j).val(:));
    end
    
    [i, j] = GetNextCliques(P, MESSAGES);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Now the clique tree has been calibrated. 
% Compute the final potentials for the cliques and place them in P.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:N
    neighbors = find(P.edges(i,:) == 1);
    F = P.cliqueList(i);
    for j = 1:length(neighbors)
        M = MESSAGES(neighbors(j), i);
        if isMax
            F = FactorSum(F, M);
        else
            F = FactorProduct(F, M);
        end
    end
    P.cliqueList(i) = F;
end

return
