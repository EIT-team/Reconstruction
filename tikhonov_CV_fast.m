function [X_corr, X] = tikhonov_CV_fast(dV,lambda,U,sv,V,JJinv,SD_all)
%
% tikhonov_CV_fast: Selects optimum value of lambda for tikhonov
% regularisation by leave one out cross validation. pseudoinverse of J
% and lambda values should already have been calculated.
%
% Input:
% dV:       Voltage difference data
% lambda:   lambda values
% U, sv, V: Jacobina matrix SVD values
% JJinv:    Psuedoinverse of J for all values of lambda, split into cross
%           validation sets
% SD_all:   Noise correction matrix for all values of lambda

% Output
% X:        n x m matrix of conductivity values, where n is the number of
%           elements in the mesh and m is the number of dV samples. 
% X_corr:   X, after noise based correction has been applied
% 
% Tom Dowrick 11.4.2016
% ------------------
[n_prt,n_samples] = size(dV);
[n_mesh, n_lambda] = size(SD_all);
OUT = (1:n_prt)';

%Initialise empty arrays for predicted voltages and cross valiation error
dV_predicted = zeros(n_lambda,n_prt);
cv_error = zeros(n_prt,n_lambda);

% Predict 'leave one out' values of dV
for i = 1:n_prt
    dV_predicted(:,i) = dV(setdiff(OUT,i))'*JJinv(:,:,i);
end

% Calculate the CV error for each value of lambda and find the minimum
cv_error = sqrt(sum( (repmat(dV,[1,n_lambda])'-dV_predicted).^2,2) );
[cv_min,opt] = min(cv_error);

% initialize array X, of conducivity values
X = zeros(n_mesh,n_samples);

UY = U'*dV; % Precompute

for i=1:n_samples
    % regularise the singular values with optimal lambda and compute
    % conductivity values X
    sv_i = sv+lambda(opt(i))./sv;
    X(:,i) = V*(diag(1./sv_i)*UY(:,i));
    
end

%Apply noise correction using optimal lambda
[~,opt] = min(cv_error);
X_corr = X./SD_all(:,opt);



