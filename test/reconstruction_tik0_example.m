%these relative paths only work on windows I think...

%addpath('../src/matlab');
Failed = 0;

load('../resources/mesh/Ex_Cyl_Small.mat'); %load the Mesh and the Jacobian (from fwd solver), and the boundary votlages DV
load('reconTestData.mat');
[h]=DisplayBoundaries(Mesh);

tol = 1e-14;


%create hex mesh and hex jacobian - 10mm elements
[Mesh_hex,J_hex]=convert_fine2coarse(Mesh.Tetra,Mesh.Nodes,J,0.2);


tic
n_J = size(J_hex,1);% J is the Jacobian matrix
nLambda=3000;
%SVD
[U,S,V] = svd(J_hex,'econ');% Singular value decomposition
disp(sprintf('SVD done: %.2f min.',toc/60))

%pick lambda searchspace
lambda = logspace(-20,-2,nLambda);

%Do inversion
[X,cv_error] = tikhonov_CV(J_hex,DV,lambda,n_J,U,S,V,0);% DV is the measurement.
disp(sprintf('X done: %.2f min.',toc/60));

% Check we get right value of X
try
assert( max(abs(X-X_test)) < tol)
catch
    disp('Recon test error')
    Failed = 1;
end

if Failed
     exit(1)
end
%% make vtk

%write VTK file to view in paraview
%writeVTKcell_hex('CylTest',Mesh_hex.Hex,Mesh_hex.Nodes,X);