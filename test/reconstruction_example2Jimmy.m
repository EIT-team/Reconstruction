    tic
    n_J = size(J,1);% J is the Jacobian matrix
    nLambda=3000;
    %SVD
    [U,S,V] = svd(J,'econ');% Singular value decomposition
    disp(sprintf('SVD done: %.2f min.',toc/60))
    
    %pick lambda searchspace
    lambda = logspace(-20,-2,nLambda);
    
    %Do inversion
    [X,cv_error] = tikhonov_CV(J,DV,lambda,n_J,U,S,V,1);% DV is the measurement.
    disp(sprintf('X done: %.2f min.',toc/60));