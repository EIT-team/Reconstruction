classdef tikhonov_object < handle
    
    properties (Access = public)
        n_lambda = 400
        lambda_range = [-15 -2]
        lambdas
        cv_error
    end
    
    properties (Access = private)
        
        U
        S
        V
        sv
        JV
        n_prt
        n_mesh
        JJinv_CV_sets
        SD_all
        IN
        OUT
        dV_predicted
        
    end
    

    
    methods
        function precompute(self,J)
            
            tic
            
            self.lambdas = logspace(self.lambda_range(1),self.lambda_range(2),self.n_lambda);
            
            
            [self.n_prt, self.n_mesh] = size(J);
            [self.U,self.S,self.V] = svd(J,'econ');
            self.sv = diag(self.S);
            self.JV = J*self.V;
            
            disp(sprintf('SVD done: %.1f seconds.',toc))
            
            
            tic
            
            %Generate noise array for correction
            Noise = 1e-6*randn(500,nnz(1:self.n_prt));
            disp('Generated Noise')
            
            % Create sets for leave one out cross validation
            self.OUT = (1:self.n_prt)';
            self.IN = zeros(self.n_prt-1,self.n_prt);
            for i=1:self.n_prt
                % choose the remaining indices
                self.IN(:,i) = setdiff(self.OUT,self.OUT(i));
            end
            disp('Created sets for CV')
            
            %Compute J*Jinv for each value of lambda (speeds up recon
            %later)
            for i = 1:self.n_lambda
                sv_i = self.sv+self.lambdas(i)./self.sv;
                JJinv(:,:,i) = self.JV*diag(1./sv_i)*self.U';
            end
            
            %Split JJinv according to training sets for cross validation
            for i = 1:self.n_prt
                self.JJinv_CV_sets(:,:,i) = JJinv(self.OUT(i),self.IN(:,i),:);
            end
            
            disp(sprintf('Created Psuedoinverse of J for all values of nfold: %.1f seconds',toc))
            
            % Create noise correction for all values of lambda, another big time saver
            tic
            
            UtNoise = self.U'*Noise';
            self.SD_all = zeros(self.n_mesh,self.n_lambda);
            for i = 1:self.n_lambda
                sv_i = self.sv+self.lambdas(i)./self.sv;
                self.SD_all(:,i) = std(self.V*(diag(1./sv_i)*UtNoise),0,2);
            end
            
            disp(sprintf('Generated noise for all lambda values: %.1f',toc))
            toc
        end
        
        function X = predict(self,dV)
            
            n_samples = size(dV,2);
            
            %Initialise empty arrays for predicted voltages and cross valiation error
            
            dV_predicted = zeros(self.n_lambda,self.n_prt);
            self.cv_error = zeros(self.n_prt,self.n_lambda);
            
            
            % Predict 'leave one out' values of dV
            for i = 1:self.n_prt
                self.dV_predicted(:,i) = dV(setdiff(self.OUT,i))'*self.JJinv_CV_sets(:,:,i);
            end
            
            % Calculate the CV error for each value of lambda and find the minimum
            self.cv_error = sqrt(sum( (repmat(dV,[1,self.n_lambda])'-dV_predicted).^2,2) );
            [cv_min,opt] = min(self.cv_error);
            
            % initialize array X, of conducivity values
            X = zeros(self.n_mesh,n_samples);
            
            UY = self.U'*dV; % Precompute
            
            for i=1:n_samples
                % regularise the singular values with optimal lambda and compute
                % conductivity values X
                sv_i = self.sv+self.lambdas(opt(i))./self.sv;
                X(:,i) = self.V*(diag(1./sv_i)*UY(:,i));
                
            end
            
            %Apply noise correction using optimal lambda
            [~,opt] = min(self.cv_error);
            X_corr = X./self.SD_all(:,opt);
            
            
        end
        
        
    
    
    
    end

end
