function M_final  = testSVT(row_len,col_len,M_idx,M_val,max_itr,stoppingCriteria)

    M_val_len = length(M_val); 
    M_new = zeros(row_len,col_len);
    
    % taken from the paper
    p  = M_val_len/(row_len*col_len);
    tau = sqrt(row_len*col_len); 
    delta = 1.2/p;    
    
    %norm of M
    norm_M = norm(M_val);
    
    %Matrix update
    M_new(M_idx) = M_val;
    
    % initialize M_new with k_zero*delta*M_values
    k0 = ceil(tau/(delta*norm(M_new)));
    M_new(M_idx)= k0*delta*M_val;
    

    for itr = 1:max_itr
   
        %svd of sparce matrix gives error in matlab thus full.
        [U,Sigma,V] = svd(M_new,'econ');
        
        %extract diagonal values of Sigma 
        sigma_diag_val = diag(Sigma);
    
        % getting maxrank above threshold
        r = sum(sigma_diag_val > tau);
        
        %adjusting u v and Sigma
        U = U(:,1:r); 
        V = V(:,1:r); 
        sigma_diag_val = sigma_diag_val(1:r) - tau; 
    
        % diagonal matrix from values of sigma
        Sigma = diag(sigma_diag_val);
        
        A = (U*Sigma)*V';
        
        M_est = A(M_idx);
        error = norm(M_est-M_val)/norm_M;

        if (error < stoppingCriteria)
            break
        end
        % update M_new
        M_new(M_idx) = M_new(M_idx)+delta*(M_val-M_est);
    end
    M_final = A;
end