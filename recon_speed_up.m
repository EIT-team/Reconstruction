
    %Do SVD
    tic
    [U,S,V] = svd(J,'econ');
    sv = diag(S);
    disp(sprintf('SVD done: %.2f min.',toc/60))
    
    n_J = size(J,1);
n = size(J,2);

    %Generate noise array for correction
    Noise = 1e-6*randn(500,nnz(1:n_J));

    disp('Generated Noise')
        
    nfold = n_J;
    k = nfold;
    
    ALL = (1:k)';
    OUT = zeros(nfold,1);
    IN = zeros(k-1,nfold);
    for i=1:nfold
        % randomly choose k/nfold indices that were not previously chosen
        OUT(i) = randsample(setdiff(ALL,(OUT(1:i-1))),floor(k/nfold));
        % choose the remaining indices
        IN(:,i) = setdiff(ALL,OUT(i));
    end
    IN(:,nfold) = OUT(1:nfold-1);
    OUT(nfold) = setdiff(ALL,IN(:,nfold));
    
    
    disp('Created sets for CV')
    
    lambda = logspace(-25,-2,400);
    l = size(lambda,2);

    tic
    JV = J*V;
    

clear JJinv
    for i = 1:l
        sv_i = sv+lambda(i)./sv;
        JJinv(:,:,i) = JV*diag(1./sv_i)*U';
    end
    
    
    clear JJinv_InOut
    for i = 1:nfold
        JJinv_InOut(:,:,i) = JJinv(OUT(i),IN(:,i),:);
    end
    
    disp('Created Psuedoinverse of J for all values of nfold')
    toc
    
    
    


  %%
  tic
        UtNoise = U'*Noise';
        sv = diag(S);
        
        %%
SD_all = zeros(n,l);
for i = 1:l
    sv_i = sv+lambda(i)./sv;
    SD_all(:,i) = std(V*(diag(1./sv_i)*UtNoise),0,2);
end

disp('Generated noise for all lambda values')
toc

