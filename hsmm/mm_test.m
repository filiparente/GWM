% setup transition matrix 
n_states = 4;
MC = Markov_Chain(n_states);

%simulate 10 chains by generating samples with length 10
num_chains = 50;
num_iterations = 10;
chain_states = zeros(num_chains, num_iterations);

% simulate chains
for c=1:num_chains
  [MC, chain_states(c ,:)] = MC.simulate_MC(num_iterations);
end

MC.plot_MC(chain_states);

disp(chain_states);
