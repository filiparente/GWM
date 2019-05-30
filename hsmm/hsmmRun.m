function hsmmRun()
%%
%A: transition matrix
%B: observation probability matrix
%P:
%PAI: initial state distribution
%Vk: 
%O: Observation sequence
%K: maximum value of the observed sequence
%D: maximum duration
%M: number of states

%Define the number of states of the Markov chain
M = 3;

%Define the maximum length of state duration
D = 5;

%Initialize model
original_model = MMPP(M,D);
original_model = original_model.generate_random_initial_dist()
original_model = original_model.generate_random_transition_matrix()
original_model.T
original_model.pi
state = original_model.select_state(original_model.pi)
%original_model.generate_random_dur_dist()
%original_lambdas = [3,12,25];
%original_model.set_rates(original_lambdas);
%%
%Number of observation sequences
N = 1;

%Dimension of the observations
dim = 100;

%Obtain observations from the original model
obs_seq, state_seq, state_trans = original_model.sample(N, dim);
        
%Get the maximum observed value in the observation sequence
K = max(obs_seq);

[A,B,P,PAI,~,O,~] = hsmmCreate([],M,D,K,'rand');
[PAI_est,A_est,B_est,P_est,Stateseq_est,Loglikelihood_est]=hsmm_new(PAI,A,B,P,O,100);
disp(PAI_est);
disp(A_est);
disp(B_est);
disp(P_est);
disp('Log likelihood ', Loglikelihood_est);
plotseq(O,StateSeq_est);

end
