
%these are located in resources subfolder of repo

load('Cyl_Mesh'); %load the Mesh and the Jacobian (from fwd solver)
load('Ex_Cyl_DV'); % load boundary voltages

%%

%display boundaries of mesh
DisplayBoundaries(Mesh); 

%create hex mesh and hex jacobian - 10mm elements
[Mesh_hex,J_hex]=convert_fine2coarse(Mesh.Tetra,Mesh.Nodes,J,10e-3);


tic

%this is the number of folds used in the cross validation in tikhonov_CV,
%here we are using the maximum number
n_J = size(J_hex,1);% J is the Jacobian matrix
nLambda=3000;
%SVD
[U,S,V] = svd(J_hex,'econ');% Singular value decomposition
disp(sprintf('SVD done: %.2f min.',toc/60))

%pick lambda searchspace
lambda = logspace(-20,-2,nLambda);

%Do inversion
[X,cv_error] = tikhonov_CV(J_hex,DV,lambda,n_J,U,S,V,1);% DV is the measurement.
disp(sprintf('X done: %.2f min.',toc/60));


%% make vtk

writeVTKcell_hex('CylTest',Mesh_hex.Hex,Mesh_hex.Nodes,X);