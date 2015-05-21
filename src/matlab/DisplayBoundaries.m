function [h,TR]=DisplayBoundaries(mesh)
%display boundaries of mesh from Kirill 


%[mesh.Nodes,mesh.Tetra]=removeisolatednode(double(mesh.Nodes(:,1:3)),double(mesh.Tetra(:,1:4)));
facenb=faceneighbors(double(mesh.Tetra(:,1:4)), 'surface');
TR=TriRep(facenb, mesh.Nodes(:,1),mesh.Nodes(:,2),mesh.Nodes(:,3));
%figure;
h=trimesh(TR);
set(h,'EdgeColor',[0.3,0.3,0.3],'FaceColor','w');
% set(h,'EdgeColor',[100,143,229]/256,'EdgeAlpha',0.5);
% set(h,'EdgeAlpha',0.5);
%set(h,'FaceColor','None');
daspect([1,1,1]); 

