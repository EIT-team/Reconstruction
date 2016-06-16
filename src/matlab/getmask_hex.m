function [ Mask_hex ] = getmask_hex( Mesh_hex,Matref, SelectMatRef,ThresholdRatio )
%GETMASK_HEX Finds the hex in Mesh_hex which were made with tetrahedra in
%Mesh with a ratio of MatRefSelect to others which are above threshold
%ratio. Use this to find which hex correspond to skull
%   Detailed explanation goes here


nHex=size(Mesh_hex.Hex,1);


Mask_hex=nan(size(Matref));

MaskCount=0;

%%

for iHex=1:nHex
    curTetraMatRef=Matref(Mesh_hex.cells{iHex}); %Mat ref of the tetra which made this hex
    
    curTetraNum=length(curTetraMatRef); %number of tetra for this hex
    
    SelectTetra=length(find(curTetraMatRef == SelectMatRef)); %idx of tetra with matref meeting criteria
    
    if SelectTetra > round(curTetraNum*ThresholdRatio) % if the number of tetrawith matref is greater than the thresholdratio
        MaskCount=MaskCount+1; %increment the number of hex found
        
        Mask_hex(MaskCount)=iHex; %store idx
        
        
    end
    
end
%%
Mask_hex(isnan(Mask_hex))=[];

if MaskCount >0
    fprintf('Found %d of %d Hex matching criteria\n',MaskCount,nHex);
else
    fprintf(2,'No matching hexes found!\n');
end






end

