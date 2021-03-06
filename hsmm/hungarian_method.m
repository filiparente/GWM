function [totalcost_lambdas, totalcost_pi, totalcost_T, totalcost_D] = hungarian_method(predicted_parameters, true_model)
    pi = predicted_parameters('pi');
    T = predicted_parameters('T');
    D = predicted_parameters('D');
    lambdas = predicted_parameters('lambdas');
    
    %First create the cost matrix to compare
    cost_lambdas = zeros(true_model.n_states);
    
    for i=1:true_model.n_states
        cost_lambdas(i, :) = abs(true_model.lambdas(i)-lambdas);
    end
    
    %Find the permutations of the cost matrix which give lowest total cost
    %indexes are tuples with the association between the indexes of the true model 
    %and the corresponding indexes in the predicted model
    %due to the identifiability problem, the states are not always estimated in the right order
    [assignment, totalcost_lambdas] = munkres(cost_lambdas);
    
    %Print state associations
    disp('State associations: (original state, algorithm state)');
    for i=1:length(assignment)
        fprintf('(%d,%d)\n', i, assignment(i));
    end
    
    %Print total cost for lambdas
    fprintf('total cost for lambdas: %f\n', totalcost_lambdas);
    
    %With the indexes association, compute total cost for the initial distribution
    totalcost_pi = 0;
    for i=1:length(assignment)
        value = abs(true_model.pi(i) - pi(assignment(i)));
        totalcost_pi = totalcost_pi+value;
    end
    
    %Print total cost for pi
    fprintf('total cost for pi: %f\n', totalcost_pi)
    
    %With the indexes association, permute the rows and columns of the predicted 
    %transition matrix so that it matches the true transition matrix
    %Same for the duration probability density function (but only rows, since rows are states and columns are durations)
    for i=1:length(assignment)
        T([i, assignment(i)], :) = T([assignment(i),i], :);     % swap rows.
        T(:, [i, assignment(i)]) = T(:, [assignment(i),i]);     % swap columns.
        D([i, assignment(i)], :) = D([assignment(i),i], :);
    end 
        
    %Compute total cost for the transition matrix
    totalcost_T = sum(sum(abs(T-true_model.T)));
    fprintf('total cost for T: %f\n', totalcost_T);
    
    %Compute total cost for the duration probability density function
    totalcost_D = sum(sum(abs(D-true_model.dur_probs)));
    fprintf('total cost for D: %f\n', totalcost_D);
    
end
    
    
    