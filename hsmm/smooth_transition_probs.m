function T = smooth_transition_probs(T,M)
  EPSILON=1.0e-100; % smoothing parameter

  u = create_matrix(M, 0);
  for i=1:M
     sum_ = 0.0;
     cnt = 0;
     for j=1:M
        u(j) = 0;
     end
     for j=1:M
        if T(i,j) < EPSILON
           T(i,j) = EPSILON;
           u(j) = 0;
           cnt = cnt + 1;
        else
           u(j) = 1;
           sum_ = sum_ + T(i,j);
        end
     end
     if cnt ~= 0
        for j=1:M
           if u(j) == 1
              T(i,j) = (1-cnt*EPSILON) * T(i, j) / sum_;
           end
        end
     end
  end
end

     


