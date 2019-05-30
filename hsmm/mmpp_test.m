%Define the number of states of the markov chain
n_states = 3;

%Define the maximum length of state duration
length_dur = 3;

%Create the markov modulated poisson process original model
original_model = MMPP(n_states, length_dur);

%Initialize the state initial distribution vector of the markov chain with random values
original_model = original_model.generate_random_initial_dist();

%Initialize the transition matrix of the markov chain with random values
original_model = original_model.generate_random_transition_matrix_d();

original_model = original_model.generate_random_dur_dist();

original_lambdas = [2, 7, 10];

original_model = original_model.set_rates(original_lambdas);


%Number of observations
N = 1;

%Dimension of the observations
dim = 100;

%Obtain observations from the original model
[obs_seq, state_seq, state_trans] = original_model.sample(N, dim);

%Initialize hidden semi Markov model with transition matrix A, poisson
%emissions B, duration matrix P and initial state distribution PAI
%Vk contains the unique ordered values from the observation sequence,
%K is the maximum observed value in obs_seq
[lambda, A,B,P,PAI,Vk,O,K] = hsmmInitialize_new(obs_seq',n_states,length_dur,max(obs_seq), 'init_type','rand');

    
%Re-estimate parameters using the EM algorithm, Qest is the decoded
%sequence
[PAI,A,B,P,Qest,lkh,ll] = hsmm_new(lambda, PAI,A,B,P,O,Vk,1000);

%Compute estimated lambdas
est_lambdas = zeros(1, size(B,1));
for i=1:size(B,1)
    est_lambdas(i) = B(i,:)*Vk;
end

%Plots
figure
plot(obs_seq)
hold on
plot(original_lambdas(state_seq'+1))
hold on
plot(est_lambdas(Qest))

legend({'Observed sequence','True state sequence','Estimated sequence'},'Location','southwest')
xlabel('Time')
ylabel('Observations')

  
%Mean Squared Error (MSE)
%MSE between original state sequence (applied to original poisson rates) and estimated state sequence (applied to estimated poisson rates)
err = immse(original_lambdas(state_seq'+1), est_lambdas(Qest));
fprintf('Mean-squared error is %0.4f\n', err);

%Final comparision via Hungarian Method
disp('Results of the hungarian algorithm');

%Store the estimated parameters in a dictionary
keySet = {'pi','T','D','lambdas'};
valueSet = {PAI, A, P, est_lambdas};
my_parameters = containers.Map(keySet,valueSet);

[cost_lambdas, cost_pi, cost_T, cost_D] = hungarian_method(my_parameters, original_model);
