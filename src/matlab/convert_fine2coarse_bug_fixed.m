function [Mesh_hex,J_hex] = convert_fine2coarse_new_final(tri,vtx,J_full,elem_size)
%--------- You can add a criteria for selecting here
%  
ind_el=[1:length(tri)]; 
%  ind_el=find(Mesh.mat==0.3);
%  
% grey=Mesh.Tetra(ind_el,:); 
% ind_el= (mat_ref==2);
grey=tri(ind_el,:); 
 
g_cnts=(vtx(grey(:,1),:)+vtx(grey(:,2),:)+vtx(grey(:,3),:)+vtx(grey(:,4),:))./4;
 
%--------- Starting here with rounding the centres according to the hex
%size
d=elem_size;

Pnode=floor(g_cnts./d);
 
%--------- unique to find out all unique hex centres, and store the index
%to access the actual stuff
[Pcells, ~, ind]=unique(int32(Pnode),'rows');  
Pcells=double(Pcells);
n_e=length(Pcells);
 
%--------- You need to know this, right?
disp(['Number of hex = ' num2str(n_e)]);
 
%--------- Store the indeces of the tetra in each hex with cells, and count
%their occurence with k, just to be sure
cells=cell(n_e,1);
k=zeros(n_e,1);
for i=1:length(ind)
    cells{ind(i)}=[cells{ind(i)} ind_el(i)];
    k(ind(i))=k(ind(i))+1;
    if (mod(i,round(length(ind)/10))==0)
        disp (['processing:' num2str(round(100*i/length(ind))-5) '%' ]);
    end
end
 
%--------- This is all possible nodes
%node1=Pcells*d-repmat([0.5,0.5,0.5]*d,n_e,1);
node1=Pcells*d;
Nodes=[node1; ...
    node1+repmat([1,0,0]*d,n_e,1); ...
    node1+repmat([1,1,0]*d,n_e,1); ...
    node1+repmat([0,1,0]*d,n_e,1); ...
    node1+repmat([0,0,1]*d,n_e,1); ...
    node1+repmat([1,0,1]*d,n_e,1); ...
    node1+repmat([1,1,1]*d,n_e,1); ...
    node1+repmat([0,1,1]*d,n_e,1);];
 
%--------- Each hex will have 8 of them according to numbering in previous
%block
Hex =[(1:n_e)',(1:n_e)'+n_e,(1:n_e)'+n_e*2,(1:n_e)'+n_e*3,(1:n_e)'+n_e*4,(1:n_e)'+n_e*5,(1:n_e)'+n_e*6,(1:n_e)'+n_e*7];
 
%--------- But we only need unique nodes, we do not need duplicates, so
%fuck them
% [Nodes,I,J1]=unique(int32(Nodes/d),'rows');
% Nodes=double(Nodes)*d;
[Nodes,~,J1]=unique(int32(round(Nodes/d)),'rows');
Nodes=double(Nodes)*d;
Hex=J1(Hex);
 
%--------- If you need to check it
% if exist('is_write_vtk')
%     writeVTKcell_hex('_hex_test',Hex,Nodes,k);
% end
 
Mesh_hex.Hex=Hex;
Mesh_hex.Nodes=Nodes;
Mesh_hex.cells=cells;
Mesh_hex.mat=ones(n_e,1);
Mesh_hex.k=k;
Mesh_hex.d=d;

for j=1:length(Mesh_hex.cells)
        J_hex(:,j)=sum(J_full(:,Mesh_hex.cells{j}),2);
end 