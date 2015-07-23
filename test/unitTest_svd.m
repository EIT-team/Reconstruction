classdef unitTest_svd < matlab.unittest.TestCase

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
function verify_uv_unitary(testCase)
test_matrix=rand(100,100);
[u,s,v]=svd(test_matrix);
testCase.verifyEqual(abs(det(u)), 1.0, 'RelTol', 1e-7)
testCase.verifyEqual(abs(det(v)), 1.0, 'RelTol', 1e-7)
end

% check s is diagonal
function verify_s_diag(testCase)
test_matrix=rand(100,100);
[u,s,v]=svd(test_matrix);
testCase.verifyEqual(isdiag(s),true)
end

% verify if give 1 as input, u,s,v should be 1
function verify_single_value(testCase)
[u,s,v]=svd(1);
testCase.verifyEqual(u,1)
testCase.verifyEqual(s,1)
testCase.verifyEqual(v,1)
end


end
end
