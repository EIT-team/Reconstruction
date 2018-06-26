function [h,Triangle_Boundary,Nodes_Boundary]=DisplayBoundaries(Mesh)
% Displays the boundaries of the mesh

% change fields if using supersolver mesh output
if ~isfield(Mesh,'Tetra') && isfield(Mesh,'tri')
    Mesh = renameStructField(Mesh,'tri','Tetra');
end
if ~isfield(Mesh,'Nodes') && isfield(Mesh,'vtx')
    Mesh = renameStructField(Mesh,'vtx','Nodes');
end

[Mesh.Nodes,Mesh.Tetra]=removeisolatednode(double(Mesh.Nodes(:,1:3)),double(Mesh.Tetra(:,1:4)));

trep = triangulation(Mesh.Tetra, Mesh.Nodes);
[Triangle_Boundary, Nodes_Boundary] = freeBoundary(trep);
h= trisurf(Triangle_Boundary, Nodes_Boundary(:,1), Nodes_Boundary(:,2), Nodes_Boundary(:,3));


set(h,'EdgeColor',[0.3,0.3,0.3],'FaceColor','w');
% set(h,'EdgeColor',[100,143,229]/256,'EdgeAlpha',0.5);
% set(h,'EdgeAlpha',0.5);
%set(h,'FaceColor','None');
daspect([1,1,1]);
end

