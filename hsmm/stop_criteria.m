function bool = stop_criteria(est_para, prev_para, tolerance)
    para_list = {'pi', 'T', 'D', 'lambdas'};
    errors = zeros(1,length(para_list));
    idx = 1;
    
    for i=1:length(para_list)
        el = para_list{i};
        
        %Check if norm1 (absolute error) is below tolerance for each parameter
        errors(idx) = norm(abs(est_para(el)-prev_para(el)), 1);
        idx = idx+1;
    end
    
    if max(errors) >= tolerance
        bool = 0;
        return;
    end
      
    bool = 1;
    return;
end