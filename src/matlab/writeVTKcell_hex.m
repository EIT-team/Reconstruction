function writeVTKcell_hex(filename,Hexes,Nodes,Data,DataName)
% vtk export for Hex elements

if size(Hexes,1) ~= size(Data,1)
    error('Size of data and hexes dont match');
end

if size(Hexes,2) ~= 8
    error('Hexes not correct, should be numHex x 8');
end

if size(Nodes,2) ~= 3
    error('Nodes not correct, should be numNodes x 3');
end

if size(Data,2) > 1
    error('Too much data, should be numHex x 1');
end

[np,dim]=size(Nodes);
[nt]=size(Hexes,1);

if exist('DataName','var') ==0 || isempty(DataName)
    DataName = 'Data';
end

%ensure we ahve .vtk at the end but dont add it if already given
[PATHSTR,NAME] = fileparts(filename);
fname=fullfile(PATHSTR,[NAME '.vtk']);

FID = fopen(fname,'w');
fprintf(FID,'# vtk DataFile Version 2.0\nUnstructured Grid Example\nASCII\n');
fprintf(FID,'DATASET UNSTRUCTURED_GRID\n');

fprintf(FID,'POINTS %d float\n',np);
s='%f %f %f \n';
P=[Nodes zeros(np,3-dim)];
fprintf(FID,s,P');

fprintf(FID,'CELLS %d %d\n',nt,nt*9);
s='%d ';
for k=1:8
    s=horzcat(s,{' %d'});
end
s=cell2mat(horzcat(s,{' \n'}));
fprintf(FID,s,[8*ones(nt,1) Hexes-1]');

fprintf(FID,'CELL_TYPES %d\n',nt);
s='%d\n';
fprintf(FID,s,12*ones(nt,1));

fprintf(FID,'CELL_DATA %s\nSCALARS %s float 1\nLOOKUP_TABLE default\n',num2str(nt),DataName);
s='%f\n';
fprintf(FID,s,Data);

fclose(FID);