function transition_matrix = generate_random_transition_matrix(N)
    transition_matrix = zeros(N,N);
    
    for i=1:obj.n_states
        row = randsample(100, N);
        row = row/sum(row);

        transition_matrix(i, :) = row;
    end
 
end

