function writeVTKcell(filename,Tetra,Nodes,Data,DataName,Format)
% writeVTKcell(filename,Tetra,Nodes,Data,DataName,Format)
% creates a vtk-file filename.vtk containing simplicial mesh data (2- or 3d)
% and additional cell data
% Based on code by Daniel Peterseim, 2009-11-07
%% Check inputs
if size(Tetra,1) ~= size(Data,1)
    error('Size of data and hexes dont match');
end

if size(Tetra,2) ~= 4 && size(Tetra,2) ~= 3
    error('Tetra not correct, should be numHex x 4(3d) or 3(2d)');
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

if exist('Format','var') ==0 || isempty(Format)
    Asciiflag=0;
else
    if strcmpi(Format,'ascii')
        Asciiflag=1;
    else
        if strcmpi(Format,'binary')
            Asciiflag=0;
        else
            error('format flag should be ascii or binary');
        end
    end
end

%% Calculate arrays to write
[np,dim]=size(Nodes);
[nt]=size(Tetra,1);
celltype=[3,5,10];

POINTS=[Nodes zeros(np,3-dim)]';
CELLS=[(dim+1)*ones(nt,1) Tetra-1]';
CELL_TYPES=celltype(dim)*ones(nt,1);
%% Write file
%ensure we have .vtk at the end but dont add it if already given
[PATHSTR,NAME] = fileparts(filename);
fname=fullfile(PATHSTR,[NAME '.vtk']);

% Open file and write the header
FID = fopen(fname,'w+');
fprintf(FID,'# vtk DataFile Version 2.0\n');
fprintf(FID,'Tetrahedral Mesh Data\n');

if Asciiflag
    fprintf(FID,'ASCII\n');
else
    fprintf(FID, 'BINARY\n');
end
fprintf(FID,'DATASET UNSTRUCTURED_GRID\n');

% Write the points
fprintf(FID,'POINTS %d float\n',np);
if Asciiflag
    s='%f %f %f \n';
    fprintf(FID,s,POINTS);
else
    fwrite(FID, POINTS, 'float', 'b');
end

% Write the cell definitons as INTEGERS because they are indices
fprintf(FID,'CELLS %d %d\n',nt,nt*(dim+2));
if Asciiflag
    s='%d ';
    for k=1:dim+1
        s=horzcat(s,{' %d'});
    end
    s=cell2mat(horzcat(s,{' \n'}));
    fprintf(FID,s,CELLS);
else
    fwrite(FID,CELLS, 'int32', 'b');
end

% Write the integer cell types as INTEGERS because they are ID Types
fprintf(FID,'CELL_TYPES %d\n',nt);
if Asciiflag
    s='%d\n';
    fprintf(FID,s,CELL_TYPES);
else
    fwrite(FID,CELL_TYPES, 'int32', 'b');
end

% Write the data array as float
fprintf(FID,'CELL_DATA %s\nSCALARS %s float 1\nLOOKUP_TABLE default\n',num2str(nt),DataName);
if Asciiflag
    s='%f\n';
    fprintf(FID,s,Data);
else
    fwrite(FID, Data, 'float', 'b');
end
fclose(FID);
end