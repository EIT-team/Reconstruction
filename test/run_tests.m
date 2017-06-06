%% Relative path of source code - Essential for Jenkins testing
addpath('../src/matlab')

%% Run tests - each will exit(1) if error is thrown
testTikhonov                %Test fast tikhonov solver 
reconstruction_tik0_example %Test original tikhonov solver

