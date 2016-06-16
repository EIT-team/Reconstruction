classdef tikhonov_object < handle
    % Implementation of Tikhonov regularisation using Singular Value Decomposition,
    % with optimal lambda selected by cross validation.
    % Example:
    % Tik = Tikhonov        Create object
    % Tik.precompute(J)     Precompute JJinv and noise matricies
    % X = predict(dV)       Predict conducitivity values for given voltages
    
    properties (Access = public)
        n_lambda = 400
        lambda_range = [-15 -2]
        lambdas                     %regularisation factor
        cv_error                    %Cross validated error
        
    end
    
    properties (Hidden = true)
        
        JJinv_CV_sets
        U
        S
        V
        sv
        JV
        n_prt
        n_mesh
        SD_all
        IN
        OUT
        verbose = 1 %If 1 print info messages
        
    end
    
    
    
    methods
        function precompute(self,J)
            
            tic
            % Define lambda values
            self.lambdas = logspace(self.lambda_range(1),self.lambda_range(2),self.n_lambda);
            
            %Do SVD and precompute JV to prevent duplication later
            [self.n_prt, self.n_mesh] = size(J);
            [self.U,self.S,self.V] = svd(J,'econ');
            self.sv = diag(self.S);
            self.JV = J*self.V;
            
            if self.verbose
                fprintf('SVD done: %.1f seconds.\n',toc)
            end
            
            tic
            
            %Generate noise array for correction
            Noise = 1e-6*randn(500,nnz(1:self.n_prt));
            
            
            % Create sets for leave one out cross validation
            self.OUT = (1:self.n_prt)';
            self.IN = zeros(self.n_prt-1,self.n_prt);
            for i=1:self.n_prt
                % choose the remaining indices
                self.IN(:,i) = setdiff(self.OUT,self.OUT(i));
            end
            
            %Compute J*Jinv for each value of lambda (speeds up recon
            %later).
            JJinv = zeros(self.n_prt,self.n_prt,self.n_lambda);
            for i = 1:self.n_lambda
                sv_i = self.sv+self.lambdas(i)./self.sv;
                JJinv(:,:,i) = self.JV*diag(1./sv_i)*self.U';
            end
            
            %Split JJinv according to training sets for cross validation
            % Has dimensions of n_prt-1 * n_lambda * n_prt.
            %This is the fastest indexing method, assuming that n_lambda >
            %n_prt.
            
            self.JJinv_CV_sets = zeros(self.n_prt-1,self.n_lambda,self.n_prt);
            for i = 1:self.n_prt
                self.JJinv_CV_sets(:,:,i) = JJinv(self.OUT(i),self.IN(:,i),:);
            end
            
            if self.verbose
                fprintf('Created Psuedoinverse of J for all values of nfold: %.1f seconds\n',toc)
            end
            
            % Create noise correction for all values of lambda, another big time saver
            tic
            
            UtNoise = self.U'*Noise';
            self.SD_all = zeros(self.n_mesh,self.n_lambda);
            for i = 1:self.n_lambda
                sv_i = self.sv+self.lambdas(i)./self.sv;
                self.SD_all(:,i) = std(self.V*(diag(1./sv_i)*UtNoise),0,2);
            end
            
            if self.verbose
                fprintf('Generated noise for all lambda values: %.1f seconds\n',toc)
            end
        end
        
        function [X_corr, X] = predict(self,dV)
            % returns Noise corrected conductivity values (X_corr) and
            % optionally non corrected values (X)
            
            %Number of sets of dV data
            n_samples = size(dV,2);
            
            %Initialise empty arrays for predicted voltages and cross valiation error
            dV_predicted = zeros(n_samples,self.n_lambda,self.n_prt);
            self.cv_error = zeros(self.n_lambda,n_samples);
            
            
            % Calculate 'leave one out' values of dV using the values in
            % the IN set.
            for i = 1:self.n_prt
                dV_predicted(:,:,i) = dV(self.IN(:,i),:)'*self.JJinv_CV_sets(:,:,i);
            end
            
            % Calculate the CV error for each value of lambda and find the minimum
            for i = 1:n_samples
                dV_repeated = repmat(dV(:,i),[1,self.n_lambda])';
                dV_predicted_squeeze = squeeze(dV_predicted(i,:,:));
                self.cv_error(:,i) = sqrt(sum( (dV_repeated - dV_predicted_squeeze ).^2,2) );
                
            end
            [~,opt] = min(self.cv_error);
            
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
