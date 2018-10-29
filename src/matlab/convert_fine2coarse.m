function [Mesh_hex,J_hex] = convert_fine2coarse(tri,vtx,J_full,elem_size)
% [Mesh_hex,J_hex] = convert_fine2coarse(tri,vtx,J_full,elem_size)
%

if length(J_full) == 1 || exist('J_full','var') == 0 || isempty(J_full)
    DoJacobian =0;
else
    % do Jacobian only if it is asked
    if nargout ==2
        DoJacobian=1;
    else
        DoJacobian =0;
    end
end

% find the centres of each element
cnts=(vtx(tri(:,1),:)+vtx(tri(:,2),:)+vtx(tri(:,3),:)+vtx(tri(:,4),:))./4;

% Starting here with rounding the centres according to the hex
%size
Pnode=floor(cnts./elem_size);

%unique to find  all unique hex centres, and store the index
%to access the actual stuff
[Pcells, ~, ind]=unique(int32(Pnode),'rows');
Pcells=double(Pcells);
n_e=length(Pcells);

disp(['Number of hex = ' num2str(n_e)]);

%Store the indeces of the tetra in each hex with cells, and count
%their occurence with k, just to be sure
cells=cell(n_e,1);
k=zeros(n_e,1);
for iTetra=1:length(ind)
    cells{ind(iTetra)}=[cells{ind(iTetra)} iTetra];
    k(ind(iTetra))=k(ind(iTetra))+1;
    if (mod(iTetra,round(length(ind)/10))==0)
        disp (['processing:' num2str(round(100*iTetra/length(ind))) '% done' ]);
    end
end

% cheat output
disp (['processing:' num2str(100) '% done' ]);

% This is all possible nodes
node1=Pcells*elem_size;
Nodes=[node1; ...
    node1+repmat([1,0,0]*elem_size,n_e,1); ...
    node1+repmat([1,1,0]*elem_size,n_e,1); ...
    node1+repmat([0,1,0]*elem_size,n_e,1); ...
    node1+repmat([0,0,1]*elem_size,n_e,1); ...
    node1+repmat([1,0,1]*elem_size,n_e,1); ...
    node1+repmat([1,1,1]*elem_size,n_e,1); ...
    node1+repmat([0,1,1]*elem_size,n_e,1);];

% Each hex will have 8 of them according to numbering in previous
%block
Hex =[(1:n_e)',(1:n_e)'+n_e,(1:n_e)'+n_e*2,(1:n_e)'+n_e*3,(1:n_e)'+n_e*4,(1:n_e)'+n_e*5,(1:n_e)'+n_e*6,(1:n_e)'+n_e*7];

% only need unique nodes
[Nodes,~,J1]=unique(int32(round(Nodes/elem_size)),'rows');
Nodes=double(Nodes)*elem_size;
Hex=J1(Hex);

Mesh_hex.Hex=Hex;
Mesh_hex.Nodes=Nodes;
Mesh_hex.cells=cells;
Mesh_hex.mat=ones(n_e,1);
Mesh_hex.k=k;
Mesh_hex.d=elem_size;

%make hex jacobian if asked
if DoJacobian
    fprintf('Making Hex Jacobian...')
    J_hex=zeros(size(J_full,1),length(Mesh_hex.cells));
    for j=1:length(cells)
        J_hex(:,j)=sum(J_full(:,cells{j}),2);
    end
    fprintf('done!\n');
else
    J_hex=[];
end

end
