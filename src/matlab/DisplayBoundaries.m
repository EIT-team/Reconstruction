function [h]=DisplayBoundaries(Mesh)
% Displays the boundaries of the mesh
% Requires iso2mesh

% change fields if using supersolver mesh output
if ~isfield(Mesh,'Tetra') && isfield(Mesh,'tri')
    Mesh = renameStructField(Mesh,'tri','Tetra');
end
if ~isfield(Mesh,'Nodes') && isfield(Mesh,'vtx')
    Mesh = renameStructField(Mesh,'vtx','Nodes');
end

if ~isfield(Mesh,'Tetra') && isfield(Mesh,'Hex')
    HexMesh=1;
else
    HexMesh=0;
end

%% Tetra mesh

if ~HexMesh
    [Mesh.Nodes,Mesh.Tetra]=removeisolatednode(double(Mesh.Nodes(:,1:3)),double(Mesh.Tetra(:,1:4)));
    
    trep = triangulation(Mesh.Tetra, Mesh.Nodes);
    [Triangle_Boundary, Nodes_Boundary] = freeBoundary(trep);
    h= trisurf(Triangle_Boundary, Nodes_Boundary(:,1), Nodes_Boundary(:,2), Nodes_Boundary(:,3));
else
    %% Hex Mesh
    
    % estimate boundary from centre of hexes
    cnts=zeros(length(Mesh.Hex),3);
    for i=1:8
        cnts=cnts+Mesh.Nodes(Mesh.Hex(:,i),:)/8;
    end
    
    %round to grid of hex size
    cnt_int=floor(cnts/Mesh.d);
    
    %make all positive
    cnt_shift=min(cnt_int)-2; % binsruface seems to get a bit confused if nodes are on the edge so shift a bit more than needed 
    cnt_int=cnt_int-cnt_shift;
    
    %make binary volume
    maxind=max(cnt_int);
    grd=zeros(maxind(1),maxind(2),maxind(3));
    
    %file in hex centres
    for iHex=1:size(cnt_int,1)
        grd(cnt_int(iHex,1),cnt_int(iHex,2),cnt_int(iHex,3))=1;
    end
    
    [node,elem]=binsurface(grd,4); % get just the surface of the binary mask
    node=(node+cnt_shift)*Mesh.d; % shift back to original positions
    
    h=patch('Vertices',node,'faces',elem);
end


%% figure settings
set(h,'EdgeColor',[0.3,0.3,0.3],'FaceColor','w');
% set(h,'EdgeColor',[100,143,229]/256,'EdgeAlpha',0.5);
% set(h,'EdgeAlpha',0.5);
% set(h,'FaceColor','None');
daspect([1,1,1]);


end


