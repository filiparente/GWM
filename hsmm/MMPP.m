classdef MMPP < Markov_Chain
   properties
      length_dur
      lambdas
      dur_probs
   end
   methods
      function obj = MMPP(n_states, length_dur, T, pi)
         %super-class initialization
          obj@Markov_Chain(n_states);
          if nargin > 0
            obj.length_dur = length_dur;
            %vector of rates of the poisson process associated to each state
            obj.lambdas = zeros(1,n_states);
         end
      end
      
      function obj = generate_random_dur_dist(obj)
        obj.dur_probs = generate_random_dur_dist(obj.n_states, obj.length_dur);
      end
      
            
      function obj = set_rates(obj, lambdas)
        obj.lambdas = lambdas;
      end
      
      % Sample an MMPP according to a state duration probability distribution
      function [observation_seq, state_seq, state_trans] = sample(obj, N, dim)
        if obj.n_states~=0 && sum(obj.lambdas)~=0
            
            % dim is the dimension of the observation sequence, N is the number of observed sequences
            observation_seq = [];
            state_seq = [];
            state_trans = [];
            
            for obs=1:N
                
                % initialize variable for first state using the initial distribution
                next_state = obj.select_state(obj.pi);
                k = 0;
                
                while 1
                    prev_k = k;
                    dur = obj.select_state(obj.dur_probs(next_state,:));
                    k = prev_k + dur;
                    if k > dim
                        k = dim;
                    end
                        
                    next_lambda = obj.lambdas(next_state);
                    
                    x = poissrnd(next_lambda, [1,k-prev_k]);
                    observation_seq = [observation_seq,x];
                    
                        
                    for i = prev_k:k-1
                        state_seq = [state_seq, next_state-1];
                    end
                                         
                    i = k-1;
                        
                    if k == dim
                        break
                    end
                    
                    % probability vector to simulate next state X_{t+1}
                    p_vec = obj.T(next_state,:);
                    
                    prev_state = next_state;
                    
                    % draw from multinomial and determine state
                    next_state = obj.select_state(p_vec);
                    
                    state_trans = [state_trans; [prev_state,next_state,dur]];
                    
                end
            end
        else
            observation_seq = false;
            state_seq = false;
            state_trans = false;
        end 
        observation_seq = reshape(observation_seq, [N, dim]);
        state_seq = reshape(state_seq, [N, dim]);
     end
   end
end