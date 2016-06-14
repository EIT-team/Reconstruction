% precompute_Recon : Precomputes Jinv (using SVD) and noise matrices for all
% values of lambda, to speed up reconstruction, plus a few other performance
% tweaks to speed up processing (About 40x faster than previous method)
%
%   Inputs
%   J           : Jacobian matrix (n_prt * n_mesh_elements)
%   n_lambda    : how many lambda values to use for cross validation
%   lambda_range: 2-element array with min/max values for lambda, as an
%                 exponent - e.g. [-10,5] gives 10^-10 and 10^5 as range.
%
%   Outputs
%   JJinv_CV_sets : Psuedoinverse of J for all values of lambda, split
%                   according to sets for cross validation
%   SD_all        : Noise correction matrix for all values of lambda
%
% Memory usage
% JJinv_CV_sets will have dimensions of n_prt * n_prt * n_lambda
% SD_all will have dimensions of n_mesh_elements * n_lambda
%
% Tom Dowrick 11.4.2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define range of lambda values
n_lambda = 100;
lambda_range = [-15 -2];
lambda = logspace(lambda_range(1),lambda_range(2),n_lambda);

%Do SVD and precompute JV to prevent duplication later
tic
[n_prt, n_mesh] = size(J);

[U,S,V] = svd(J,'econ');
sv = diag(S); %Singluar values
JV = J*V;
disp(sprintf('SVD done: %.2f min.',toc/60))


%Generate noise array for correction
Noise = 1e-6*randn(500,nnz(1:n_prt));
disp('Generated Noise')

% Create sets for leave one out cross validation
OUT = (1:n_prt)';
IN = zeros(n_prt-1,n_prt);
for i=1:n_prt
    % choose the remaining indices
    IN(:,i) = setdiff(OUT,OUT(i));
end
disp('Created sets for CV')


tic
%Compute J*Jinv for each value of lambda
%Jinv is 
for i = 1:n_lambda
    sv_i = sv+lambda(i)./sv;
    JJinv(:,:,i) = JV*diag(1./sv_i)*U';
end


%Split JJinv according to training sets for cross validation
% This is a big time saving step, at the expense of increased memory usage
for i = 1:n_prt
    JJinv_CV_sets(:,:,i) = JJinv(OUT(i),IN(:,i),:);
end

disp('Created Psuedoinverse of J for all values of nfold')
toc

% Create noise correction for all values of lambda, another big time saving
% bit.

tic
UtNoise = U'*Noise';

SD_all = zeros(n_mesh,n_lambda);
for i = 1:n_lambda
    sv_i = sv+lambda(i)./sv;
    SD_all(:,i) = std(V*(diag(1./sv_i)*UtNoise),0,2);
end

disp('Generated noise for all lambda values')
toc

clear S Noise JJinv IN OUT JV

