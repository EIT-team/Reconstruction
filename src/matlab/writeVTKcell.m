function writeVTKcell(filename,Tetra,Nodes,Data,DataName)
% vtk export
% creates a vtk-file filename.vtk containing simplicial mesh data (2- or 3d)
% and additional cell data
% Based on code by Daniel Peterseim, 2009-11-07

if size(Tetra,1) ~= size(Data,1)
    error('Size of data and hexes dont match');
end

if size(Tetra,2) ~= 4 && size(Tetra,2) ~= 3
    error('Tetra not correct, should be numHex x 4(3d) 3(2d)');
end

if size(Nodes,2) ~= 3 && size(Nodes,2) ~= 2
    error('Nodes not correct, should be numNodes x 3');
end

if size(Data,2) > 1
    error('Too much data, should be numTetra x 1');
end

if exist('DataName','var') ==0 || isempty(DataName)
    DataName = 'Data';
end

[np,dim]=size(Nodes);
[nt]=size(Tetra,1);
celltype=[3,5,10];


%ensure we ahve .vtk at the end but dont add it if already given
[PATHSTR,NAME] = fileparts(filename);
fname=fullfile(PATHSTR,[NAME '.vtk']);
 
FID = fopen(fname,'w+');
fprintf(FID,'# vtk DataFile Version 2.0\nUnstructured Grid Example\nASCII\n');
fprintf(FID,'DATASET UNSTRUCTURED_GRID\n');
 
fprintf(FID,'POINTS %d float\n',np);
s='%f %f %f \n';
P=[Nodes zeros(np,3-dim)];
fprintf(FID,s,P');
 
fprintf(FID,'CELLS %d %d\n',nt,nt*(dim+2));
s='%d ';
for k=1:dim+1
    s=horzcat(s,{' %d'});
end
s=cell2mat(horzcat(s,{' \n'}));
fprintf(FID,s,[(dim+1)*ones(nt,1) Tetra-1]');
 
fprintf(FID,'CELL_TYPES %d\n',nt);
s='%d\n';
fprintf(FID,s,celltype(dim)*ones(nt,1));
 
fprintf(FID,'CELL_DATA %s\nSCALARS %s float 1\nLOOKUP_TABLE default\n',num2str(nt),DataName);
s='%f\n';
fprintf(FID,s,Data);
 
fclose(FID);
