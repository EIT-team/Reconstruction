function [X,cv_error] = tikhonov_CV(J,Y,lambda,nfold,U,S,V,PLOT)
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
% 16.02.12 Gustavo
    
    % set PLOT to false if not set
    if nargin<8
        PLOT = false;
    end
    
    % get matrix dimensions
    [k,n] = size(J);
    m = size(Y,2);
    l = length(lambda); 
  
    % compute SVD if necessary
    if nargin<5
        [U,S,V] = svd(J,'econ');
    end
    
    % sv: vector of singular values
    sv = diag(S);
    % JV: pre-compute for greater efficiency
    JV = J*V;

    if iscell(nfold)
        IN = nfold{1};
        OUT = nfold{2};
        nfold = length(IN);
    else
        % ALL: set of all row indices (1 thru k)
        % IN, OUT: we randomly split the row indices nfold-ways and store the
        % non-overlapping sets in these cell arrays
        ALL = (1:k)';
        IN = cell(nfold,1);
        OUT = cell(nfold,1);
        for i=1:nfold-1
            % randomly choose k/nfold indices that were not previously chosen
            OUT{i} = randsample(setdiff(ALL,cell2mat(OUT(1:i-1))),floor(k/nfold));
            % choose the remaining indices
            IN{i} = setdiff(ALL,OUT{i});
        end
        IN{nfold} = cell2mat(OUT(1:nfold-1));
        OUT{nfold} = setdiff(ALL,IN{nfold});
    end
    
    % initialize cv_error
    cv_error = zeros(l,m); 

    % iterate over sv levels
% $$$     tic
    for i=1:l
        % regularise the singular values with lambda
        sv_i = sv+lambda(i)./sv;

        % Jinv: Jacobian pseudoinverse
        JJinv = JV*diag(1./sv_i)*U';
        
        % Y_cv: we compute the conductivities with the IN subsets
        % and predict the boundary voltages for the OUT subsets
        Y_cv = zeros(k,m);
        for j=1:nfold
            Y_cv(OUT{j},:) = JJinv(OUT{j},IN{j})*Y(IN{j},:);
        end
        
        % compute the norm error between Y and Y_cv
        cv_error(i,:) = sqrt(sum((Y-Y_cv).^2));
        if mod(i,100)==0
            disp(['CV_level: ',num2str([i,toc/60])]);
        end
    end
    
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
% $$$         % Jinv: recompute Jacobian pseudoinverse
% $$$         Jinv = V*diag(1./sv_i)*U';
% $$$         % compute X with all measurements
% $$$         X(:,i) = Jinv*Y(:,i);
    end  
    
    % plot error if necessary
    if PLOT
        figure
        subplot(1,2,1)
        semilogx(lambda,cv_error)
        hold on
        semilogx(lambda(opt),cv_min,'ok')
        subplot(1,2,2)
        scatter(Y,J*X)
        hold on
        plot(xlim,xlim,'-k')
    end
  
  