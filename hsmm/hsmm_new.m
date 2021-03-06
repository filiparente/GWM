function [PAI,A,B,P,Qest,lkh,ll]=hsmm_new(lambda, PAI,A,B,P,O,Vk, IterationNo)
% 
% Author: Shun-Zheng Yu
% Available: http://sist.sysu.edu.cn/~syu/Publications/hsmm_new.m
% 
% HSMM solve three fundamental problems for Hidden Semi-Markov Model using a new Forward-Backward algorithm
% Usage: [PAI,A,B,P,Stateseq,Loglikelihood]=hsmm_new(PAI,A,B,P,O,MaxIterationNo)
% MaxIterationNo=0: estimate StateSeq and calculate Loglikelihood only; 
% MaxIterationNo>1: re-estimate parameters, estimate StateSeq and Loglikelihood.
% First use [A,B,P,PAI,Vk,O,K]=hsmmInitialize(O,M,D,K) to initialize
% 
% Ref: Practical Implementation of an Efficient Forward-Backward Algorithm for an Explicit Duration Hidden Markov Model
% by Shun-Zheng Yu and H. Kobayashi
% IEEE Transactions on Signal Processing, Vol. 54, No. 5, MAY 2006, pp. 1947-1951 
% 
%  This program is free software; you can redistribute it and/or
%  modify it under the terms of the GNU General Public License
%  as published by the Free Software Foundation; either version
%  2 of the License, or (at your option) any later version.
%  http://www.gnu.org/licenses/gpl.txt
%
%++++++++ Markov Model +++++++++++
M=length(PAI);               %The total number of states
T=length(O);                 %The total time
D=size(P,2);                 %The maximum duration of states
K=size(B,2);                 %The total number of observation values
%----------------------------------------------------
ALPHA=zeros(M,D);   %States_x_MaxDuration (for FORWARD)
bmx=zeros(M,T);     %States_x_SequenceLength
S=zeros(M,T);       %States_x_SequenceLength
E=zeros(M,T);       %States_x_SequenceLength
BETA=ones(M,D);     %States_x_MaxDuration (for BACKWARD)
Ex=ones(M,D);       %States_x_MaxDuration
Sx=ones(M,D);       %States_x_MaxDuration
GAMMA=zeros(M,1);   %States_x_1 (FOR Pi)
Pest=zeros(M,D);    % re-ESTIMATED DURATION Matrix
Aest=zeros(M,M);    % re-ESTIMATED TRANSTITION Matrix
Best=zeros(M,K);    % re-ESTIMATED EMISSION Matrix
Qest=zeros(T,1);    % re-ESTIMATED Path
est_lambdas = zeros(M, 1); %re-ESTIMATED lambdas (Poisson)

ir1=max(1,IterationNo);
ir = 1;
tolerance = 10e-10;
prev_LL = 0.0; %previous loglikelihood
LL = 1000; %current log_likelihood

keySet = {'pi','T','D','lambdas'};
valueSet1 = {ones(1,M)', ones(M), ones(M,D), ones(1,M)'};
prev_para = containers.Map(keySet,valueSet1);
valueSet2 = {zeros(1,M)', zeros(M), zeros(M,D), zeros(1,M)'};
estimated_para = containers.Map(keySet,valueSet2);
        
                 
while (stop_criteria(estimated_para, prev_para, tolerance)==0  && ir < ir1 )%&& abs((LL-prev_LL)/LL) >= tolerance)
prev_LL = LL;
%    starttime=clock;
%++++++++++++++++++     Forward     +++++++++++++++++
%---------------    Initialization    ---------------
ALPHA(:)=0; ALPHA=repmat(PAI,1,D).*P;		%Equation (13)
%r=(B(:,O(1))'*sum(ALPHA,2));			%Equation (3)
r=(poisspdf(O(1), lambda)*sum(ALPHA,2));
bmx(:,1)=poisspdf(O(1), lambda)'./r;				%Equation (2)
E(:)=0; E(:,1)=bmx(:,1).*ALPHA(:,1);		%Equation (5)
S(:)=0; S(:,1)=A'*E(:,1);			%Equation (6)
lkh=log(r);
%---------------    Induction    ---------------
for t=2:T
    ALPHA=[repmat(S(:,t-1),1,D-1).*P(:,1:D-1)+repmat(bmx(:,t-1),1,D-1).*ALPHA(:,2:D),S(:,t-1).*P(:,D)];		%Equation (12)
    r=(poisspdf(O(t), lambda)*sum(ALPHA,2));		%Equation (3)
    bmx(:,t)=poisspdf(O(t), lambda)'./r;			%Equation (2)
    E(:,t)=bmx(:,t).*ALPHA(:,1);		%Equation (5)
    S(:,t)=A'*E(:,t);				%Equation (6)
    lkh=lkh+log(r);
end
%++++++++ To check if the likelihood is increased ++++++++
ll(ir)=lkh;
LL = lkh;
% if ir>1
% % %    clock-starttime
% %     %%%%%if (lkh-lkh1)/T<tolerance
%     if (ll(ir)-ll(ir-1))/T<tolerance
%         break
%     end
%  end
%%%%%lkh1=lkh;

%++++++++ Backward and Parameter Restimation ++++++++
%---------------    Initialization    ---------------

Aest(:)=0;  Aest=E(:,T)*ones(1,M);  %Since T_{T|T}(m,n) = E_{T}(m) a_{mn}
Pest(:)=0;  
GAMMA=bmx(:,T).*sum(ALPHA,2);
Best(:)=0;
Best(:,O(T))=GAMMA;
[X,Qest(T)]=max(GAMMA);

BETA=repmat(bmx(:,T),1,D);				%Equation (7)
Ex=sum(P.*BETA,2);					%Equation (8)
Sx=A*Ex;						%Equation (9)

%---------------    Induction    ---------------
for t=(T-1):-1:1
    %% for estimate of A
    Aest=Aest+E(:,t)*Ex';
    %% for estimate of P
    Pest=Pest+repmat(S(:,t),1,D).*BETA;
    %% for estimate of state at time t
    GAMMA=GAMMA+E(:,t).*Sx-S(:,t).*Ex;
    GAMMA(GAMMA<0)=0;           % eleminate errors due to inaccurace of the computation.
    [X,Qest(t)]=max(GAMMA);
    %% for estimate of B
    Best(:,O(t))=Best(:,O(t))+GAMMA;
    
    BETA=repmat(bmx(:,t),1,D).*[Sx,BETA(:,1:D-1)];	%Equation (14)
    Ex=sum(P.*BETA,2);					%Equation (8)
    Sx=A*Ex;						%Equation (9)
end

Pest=Pest+repmat(PAI,1,D).*BETA;    %Since D_{1|T}(m,d) = \PAI(m) P_{m}(d) \Beta_{1}(m,d)
prev_para = containers.Map(estimated_para.keys,estimated_para.values);

  if IterationNo>0            % re-estimate parameters
    PAI=GAMMA./sum(GAMMA);
    Aest=Aest.*A;   A=Aest./repmat(sum(Aest,2),1,M);
    B=Best./repmat(sum(Best,2),1,K);
    for i=1:M
        lambda(i) = B(i,:)*Vk;
    end
    Pest=Pest.*P;   P=Pest./repmat(sum(Pest,2),1,D);
    estimated_para('T') = Aest;
    estimated_para('lambdas') = lambda';
    estimated_para('pi') = PAI;
    estimated_para('D') = Pest;
  end
  fprintf('Iteration no: %d\n', ir);
  ir = ir+1;

end

if(ir == ir1)
    disp('Did not converge! Maximum iterations was reached!');
elseif stop_criteria(estimated_para, prev_para, tolerance)
    disp('Converged on parameters!');
elseif abs((LL-prev_LL)/LL) < tolerance
    disp('Converged on log likelihood!');
end

end
