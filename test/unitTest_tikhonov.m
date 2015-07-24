classdef unitTest_tikhonov < matlab.unittest.TestCase
    properties
        OriginalPath
    end
    
    % TestMethodSetup is an attribute in testCase,
    % which sets up parameters before running the
    % testing suit. In this demonstration, we only
    % added path in this method
    methods (TestMethodSetup)
        function addTestPath (testCase)
            testCase.OriginalPath = path;
            addpath(fullfile(pwd,'../src/matlab'))
        end
    end
    
    % restore the path
    methods (TestMethodTeardown)
        function restoreTestPath (testCase)
            path(testCase.OriginalPath)
        end
    end
    
    % test suit
    methods (Test)
        % check u,v are unitary
        function verify_svd (testCase)
            test_matrix=rand(100,100);
            [u,s,v]=svd(test_matrix);
            testCase.verifyEqual(abs(det(u)), 1.0, 'RelTol', 1e-7, 'u has to be unitary matrix')
            testCase.verifyEqual(abs(det(v)), 1.0, 'RelTol', 1e-7, 'v has to be unitary matrix')
            testCase.verifyEqual(isdiag(s),true, 's has to be diagonal')
            [u,s,v]=svd(1);
            testCase.verifyEqual(u,1)
            testCase.verifyEqual(s,1)
            testCase.verifyEqual(v,1)
            
            testCase.verifyEqual(1,2,'This is an example of testing failure')
        end
        %------------Verify by testing with smaple data
        function verify_tikhonov(testCase)
            load('../resources/mesh/Ex_Cyl_Small.mat'); %load the Mesh and the Jacobian (from fwd solver), and the boundary votlages DV
            [Mesh_hex,J_hex]=convert_fine2coarse(Mesh.Tetra,Mesh.Nodes,J,0.2);
            n_J = size(J_hex,1);% J is the Jacobian matrixtest
            [U,S,V] = svd(J_hex,'econ');% Singular value decomposition
            
            %----------check given USV and non given USV
            nLambda=300;
            lambda = logspace(-20,-2,nLambda);
            [X,cv_error] = tikhonov_CV(J_hex,DV,lambda,n_J,U,S,V,0);% DV is the measurement.
            [X_2,cv_error] = tikhonov_CV(J_hex,DV,lambda,n_J);
            testCase.verifyEqual(X,X_2,'calculate SVD failed')
            
            %--------- recursively test tikhonov result X
            disp('Rcursive Testing Start:')
            for nLambda=100:1000:3000
                nLambda
                lambda = logspace(-20,-2,nLambda);
                [X,cv_error] = tikhonov_CV(J_hex,DV,lambda,n_J,U,S,V,0);
                testCase.verifyTrue(mean(abs(J_hex*X-DV)) < 1e-3, 'A*x!=b')
            end
        end
        
        
        %------------Verify by testing with random data
        function verify_tikhonov2(testCase)
            A=rand(5,5);
            b=rand(5,1);
            testCase.verifyTrue(max(A*tikhonov_CV(A,b,0,1)-b)<1e-15)
        end
    end
end
