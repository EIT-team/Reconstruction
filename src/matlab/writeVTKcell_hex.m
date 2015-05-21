function writeVTKcell_hex(filename,t,p,u)
% vtk export for Hex elements
% t - Mesh_hex.Hex
% p - Mesh_hex.Nodes
% u - Sigma (size of the Hex) 
 
[np,dim]=size(p);
[nt]=size(t,1);
 
 
FID = fopen(strcat(filename,'.vtk'),'w+');
fprintf(FID,'# vtk DataFile Version 2.0\nUnstructured Grid Example\nASCII\n');
fprintf(FID,'DATASET UNSTRUCTURED_GRID\n');
 
fprintf(FID,'POINTS %d float\n',np);
s='%f %f %f \n';
P=[p zeros(np,3-dim)];
fprintf(FID,s,P');
 
fprintf(FID,'CELLS %d %d\n',nt,nt*9);
s='%d ';
for k=1:8
    s=horzcat(s,{' %d'});
end
s=cell2mat(horzcat(s,{' \n'}));
fprintf(FID,s,[8*ones(nt,1) t-1]');
 
fprintf(FID,'CELL_TYPES %d\n',nt);
s='%d\n';
fprintf(FID,s,12*ones(nt,1));
 
fprintf(FID,'CELL_DATA %s\nSCALARS u float 1\nLOOKUP_TABLE default\n',num2str(nt));
s='%f\n';
fprintf(FID,s,u);
 
fclose(FID);
