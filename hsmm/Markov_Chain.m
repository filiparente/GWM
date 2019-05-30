% %%MM.m
% 
% Class Markov Chain to simulate and plot multiple and N-sized Markov Chains, 
% generate random transition matrices and random initial state distributions

% Simulate discrete Markov chains according to transition matrix T
classdef Markov_Chain
   properties
      num_iterations
      n_states
      T
      pi  
   end
   methods
      function obj = Markov_Chain(n_states, T, pi)
         if(nargin > 0)
             %number of states
             obj.n_states = n_states;
             obj.num_iterations = 0;
             if nargin < 3
                obj = obj.generate_random_transition_matrix();
                obj = obj.generate_random_initial_dist();
             else
                obj.T = T;
                obj.pi = pi;
             end
         else
             obj.num_iterations = 0;
             obj.n_states = 0;
             obj.T = [];
             obj.pi = [];
         end
         
      end
      
      function obj = generate_random_transition_matrix(obj)
          obj.T = generate_random_transition_matrix(obj.n_states);
      end
      
      function obj = generate_random_initial_dist(obj)
          obj.pi = generate_random_initial_dist(obj.n_states);
      end
      
      %With state durations, self-state transitions are not allowed 
      %and therefore the transition matrix has null diagonal entries
      function obj = generate_random_transition_matrix_d(obj)
        obj.T = generate_random_transition_matrix_d(obj.n_states);
      end
      
      function state = select_state(obj, p)
        landings = mnrnd(1, p, 1);
        state = find(landings == 1);
      end
      
      % dim is the dimension of the sample generated from the markov chain
      function [obj, states] = simulate_MC(obj, dim)     
          obj.num_iterations = dim;

          % stores the states X_t through time
          states = [];

          % initialize variable for first state
          next_state = obj.select_state(obj.pi);
          states(length(states)+1) = next_state;

          for t=1:dim-1

            % probability vector to simulate next state X_{t+1}
            p_vec = obj.T(states(t),:);

            % draw from multinomial and determine state
            next_state = obj.select_state(p_vec);

            states(length(states)+1) = next_state;
          end
      end
      function plot_MC(obj, sample_states)
          
        figure
        
        for i=1:length(sample_states)
          hold on;
          plot(sample_states(i,:))
        end
        
        ax = gca;
        
        set(gca,'XTick',1:obj.num_iterations+1)
        set(gca,'YTick',1:obj.n_states+1)
       
        xlabel('time')
        ylabel('states')
      end
        
      function print_transition_matrix(obj)
        disp(obj.T)
      end
    
      function print_initial_dist(obj)
        disp(obj.pi)
      end
      
   end
end