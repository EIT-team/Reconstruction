function [img_prop] = img_prop(vtx, tri, sigma, thresh, volumes) 
 
% input - mesh vertices (vtx) and tetras (tri), sigma change (sigma),
% imaging threshold (thresh), elements volumes (volumes)
 
% output - image properties structure: cm (center of mass), Vol (volume), D_sd (sd based diameters), D_minmax (minmax based diameters),
% img_noise, img_signal
 
% finding the center of elements
cnts=(vtx(tri(:,1),:)+vtx(tri(:,2),:)+vtx(tri(:,3),:)+vtx(tri(:,4),:))./4;
 
% Flooring coordinates
d=3;
Pnode_all=floor(cnts./d);
 
% centering the image
Pnode_all=Pnode_all-repmat([min(Pnode_all(:,1))-1,min(Pnode_all(:,2))-1,min(Pnode_all(:,3))-1],length(Pnode_all),1);
% grids 
n=zeros(max(Pnode_all(:,1)),max(Pnode_all(:,2)),max(Pnode_all(:,3))); % element counting grid
grd_img=zeros(max(Pnode_all(:,1)),max(Pnode_all(:,2)),max(Pnode_all(:,3))); % 3d grid
vol_grd= zeros(max(Pnode_all(:,1)),max(Pnode_all(:,2)),max(Pnode_all(:,3))); % 3d volumes grid
 
% Assigning values from image to grids
for i=1:length(Pnode_all)
    %!!! Sigma is conductivity, or X, or corrected conductivity (t-score) ->
    grd_img(Pnode_all(i,1),Pnode_all(i,2),Pnode_all(i,3)) = grd_img(Pnode_all(i,1),Pnode_all(i,2),Pnode_all(i,3)) + sigma(i);
    vol_grd(Pnode_all(i,1),Pnode_all(i,2),Pnode_all(i,3)) = vol_grd(Pnode_all(i,1),Pnode_all(i,2),Pnode_all(i,3)) + volumes(i);
    n(Pnode_all(i,1),Pnode_all(i,2),Pnode_all(i,3)) = n(Pnode_all(i,1),Pnode_all(i,2),Pnode_all(i,3)) + 1;
end
 
% averaging grid img with n
n(n==0)=1;
grd_img=grd_img./n;
 
% filtering to increase connetivity of perturbation
% [b,a]=butter(3,1/3,'low');                                    %%%%% proportional to pixels size
% for i=1:size(grd_img,1)    
%     grd_img(i,:,:)=filtfilt(b,a,filtfilt(b,a,squeeze(grd_img(i,:,:)))')';
% end
% for i=1:size(grd_img,3)
%     grd_img(:,:,i)=filtfilt(b,a,filtfilt(b,a,squeeze(grd_img(:,:,i)))')';
% end
 smooth3()
% thresholding 
th_grd_img= grd_img; % th_grd_img = thresholded grd_img
th_grd_img(abs(th_grd_img)<thresh*max(abs(th_grd_img(:))))=0; % thresholding grd_img to full width half max
 
% choosing the largest connected volume
conn=conndef(ndims(th_grd_img),'minimal'); % create connectivity array
CC=bwconncomp(th_grd_img,conn); % find connected components in the image
% CC.PixelIdxList holds indices groups of  the connected groups 
numPixels = cellfun(@numel,CC.PixelIdxList); % holds the number of elements in every connected part (pert)
idx = find(numPixels==max(numPixels)); % finding the index of the largest pert in numPixels list
    
% binary mask for chosen perturbation
bin=zeros(size(th_grd_img));
bin(CC.PixelIdxList{idx}) = 1;
 
msk_grd_img= th_grd_img; % msk_grd_img = masked grd_img
msk_grd_img(bin==0)=0; % leaves only values within the chosen perturbation
 
% centre of mass co-ordinates(cm)
[X,Y,Z] = ind2sub(size(msk_grd_img),(1:prod(size(msk_grd_img)))');
cm = [sum(msk_grd_img(:).*X),sum(msk_grd_img(:).*Y),sum(msk_grd_img(:).*Z)]/sum(msk_grd_img(:)); 
 
% shape representation: Dx,Dy,Dy - coordinates from cm#
 
% method 1 - max distance in X Y Z of the perturbation
Dxyz_m= d*[max(X(msk_grd_img(:)~=0))-min(X(msk_grd_img(:)~=0)),max(Y(msk_grd_img(:)~=0))-min(Y(msk_grd_img(:)~=0)),max(Z(msk_grd_img(:)~=0))-min(Z(msk_grd_img(:)~=0))];
% method 2 - sd from cm of pert in X Y Z 
Dxyz_sd = d*4*sqrt(nanmean([(X(msk_grd_img(:)~=0)-cm(1)),(Y(msk_grd_img(:)~=0)-cm(2)),(Z(msk_grd_img(:)~=0)-cm(3))].^2));
 
% summing volumes of chosen perturbation
vol= sum (vol_grd(bin==1));
 
% Calculating Image SNr
% noise
bg_grd_img= grd_img;
bg_grd_img(bin==1)=NaN;
img_noise= nanstd(abs(bg_grd_img(:)));
% signal
pert_grd_img= grd_img;
pert_grd_img(bin==0)=NaN;
img_signal= nanmean(abs(pert_grd_img(:)));
 
% output
img_prop.cm= cm;
img_prop.D_sd= Dxyz_sd;
img_prop.D_minmax= Dxyz_m;
img_prop.vol= vol;
img_prop.img_noise= img_noise;
img_prop.img_signal= img_signal;

