% tic  
%load('Jacobian_hex_All_Prt.mat','BV0','prt_electrodes','Biosemi_num','J');
  %disp('Jacobian Loaded') ; toc

for k = [1]
    
    
    disp(['Processing ' Rat_Data{k}.Name])
    
    %Get Protocol indicies from full protocol which correspond to this rat
    ind_prt = index_protocol(Rat_Data{k}.prtfull,prt_electrodes);
    
    %Get dVs for rat we want to use, and resize dVs to eliminate injections which are only using one side of the
    %electrode array - these aren't in the full protocol/Jacobian
    dV_All  = Rat_Data{k}.Good_dV(ind_prt~=0,:);
    BV0_Exp  = Rat_Data{k}.Good_Data(ind_prt~=0,1);
    %Remove the unwanted injections from the list, so that only the correct
    %ones are selected from the Jacobian
%         
       sel = (Rat_Data{k}.prtfull(ind_prt~=0,1) ~=33) & (abs(dV_All(:,end)) < 50e-3);% (Rat_Data{k}.prtfull(ind_prt~=0,3) ~=32);
          ind_prt = ind_prt(ind_prt ~=0);
% 
%     
       ind_prt = ind_prt(sel);
    dV_All = dV_All(sel,:);

    
  tic
    
    %Select the needed lines from the protocol
    J_sel = J(ind_prt,:);
    [k,n] = size(J_sel);
        disp('Selected protocol lines');toc

    %Do SVD
    tic
    [U,S,V] = svd(J_sel,'econ');
    disp(sprintf('SVD done: %.2f min.',toc/60))
    
       %Generate noise array for correction
    Noise = 1e-6*randn(500,nnz(1:size(ind_prt,1)));
    
    n_T = size(dV_All,1);
    N_Frame = size(dV_All,2);
    n_N = size(Noise,1);
    n_J = size(J_sel,1);
    
    disp('Generated Noise')

    
    
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
    Y_m = Y(IN);
    
    disp('Created sets for CV')
    
    lambda = logspace(-25,-2,100);
    l = size(lambda,2);

    tic
    JV = J_sel*V;
    

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
      %Things moved out of loop
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
    
    for j = 1:19; %Final frame
        tic
%         dV = dV_All(:,j);
             
        
            %Run time of this step is now more or less independent of the
            %size of the mesh
            % O(n_lambda,n_dV)
            
            [X_corr] = tikhonov_CV_fast(dV_All(:,j),lambda,n_J,U,S,V,k,m,n,l,JJinv_InOut,Y_m,OUT,SD_all);
                            
                
%         [~,opt] = min(cv_error);
%         
%        X_corr = X./SD_all(:,opt);

    toc    
    end
    
    %%
end



