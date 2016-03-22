function [X_corr] = tikhonov_CV_fast(Y,lambda,nfold,U,S,V,k,m,n,l,Jinv,Y_m,OUT,SD_all)
%
% tSVD_CV: matrix pseudoinversion by truncated singular value
%   decomposition (tSVD). Truncation level is set by minimizing the
%   cross-validated (CV) error.
% Input:
%   - J: k x n Jacobian matrix to be inverted. 
%   - Y: k x m matrix of target values. k is the number of boundary
%        voltage measurements in one sample, m is number of samples.
%   - sv_level: l x 1 vector of singular value levels to be checked.    
%   - nfold: number of splits for the estimation of the cross-
%            validated error
%   - PLOT: generates plot of CV error if set to true (default: false)
% Output: 
%   - X: n x m matrix of conductivity values, where n is the number of 
%        elements in the mesh. X = Jinv*Y, where Jinv is the Jacobian
%        pseudoinverse
%   - cv_error: l x m matrix of estimated cross-validated error values.
%
% ------------------
    

    Y_cv = zeros(l,k);
    cv_error = zeros(nfold,l);
    
    sv = diag(S);
    
for i = 1:nfold
                Y_cv(:,OUT(i)) = Y_m(:,i)'*Jinv(:,:,i);
      
end
                 cv_error = sqrt(sum( (repmat(Y,[1,l])'-Y_cv).^2,2) );

    
    % opt: sv level indices that minimize the CV error
    [cv_min,opt] = min(cv_error);
    
    % initialize X
    X = zeros(n,m);
    
    % iterate over samples
    UY = U'*Y;
    for i=1:m
        % regularise the singular values with optimal lambda
        sv_i = sv+lambda(opt(i))./sv;
        X(:,i) = V*(diag(1./sv_i)*UY(:,i));

    end  
           [~,opt] = min(cv_error);
        
       X_corr = X./SD_all(:,opt);
    
    
  
  