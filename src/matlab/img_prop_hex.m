function [img_prop] = img_prop_hex(nodes, hex, sigma,d, thresh,thresh_type)
 
% input - hex mesh nodes (nodes) and hexes (hex), sigma change (sigma),
% imaging threshold as coef of maximum (thresh), thresh_type is either 'g'
% for global value i.e. abs(max(sigma))*thres or 'g-' 'g+' for forcing a
% certain direction (i.e. cheating) or 's-' or 's+' for threshold above
% significant values (calculated in a specific direction).
 
% output - image properties structure: cm (center of mass), Vol (volume), D_sd (sd based diameters), D_minmax (minmax based diameters),
% img_noise, img_signal
 
% this converts the hexes into a uniform grid with integer values, so it is
% like a grid of pixels. Then it is possible to use the image functions
% BWconn etc.
% thresholds the image, finds the biggest blob and then finds the centre of
% mass and calculates the shape like an ellipsoid. SNR is taken to be
% Signal - mean of significant blob, Noise is the std of the non blob image
 
%written by jimmy sept 2014 modified from Kirill/Nir code
 
 
%%
 
if exist('thresh_type','var') ==0
    thresh_type='g';
end


legit_threstype={'g','g+','g-','s-','s+'};
if ~ismember(thresh_type,legit_threstype)
    error('weird threstype');
end
 
 
%% move mesh into positive space and make integer values
 
% finding the center of elements
cnts=zeros(length(hex),3);
for i=1:8
    cnts=cnts+nodes(hex(:,i),:)/8;
end
 
%find the volume of the hexes
hex_vol=d^3;
 
 
% Flooring coordinates
% d=1.5; %THIS IS USED TO SCALE THE HEX MESH INTO A SPACING OF 1 between hexes!
Pnode_all=floor(cnts./d);
 
% centering the image
 
 
pos_shift=[min(Pnode_all(:,1))-1,min(Pnode_all(:,2))-1,min(Pnode_all(:,3))-1];%translation vector
Pnode_all=Pnode_all-repmat(pos_shift,length(Pnode_all),1);
%% construct grids and smooth
 
grd_img=zeros(max(Pnode_all(:,1)),max(Pnode_all(:,2)),max(Pnode_all(:,3))); % 3d grid
vol_grd= zeros(max(Pnode_all(:,1)),max(Pnode_all(:,2)),max(Pnode_all(:,3))); % 3d volumes grid
 
%this bit could be written better for hexes as the grid is already made!
 
% Assigning values from image to grids
for i=1:length(Pnode_all)
    %!!! Sigma is conductivity, or X, or corrected conductivity (t-score) ->
    grd_img(Pnode_all(i,1),Pnode_all(i,2),Pnode_all(i,3)) = grd_img(Pnode_all(i,1),Pnode_all(i,2),Pnode_all(i,3)) + sigma(i);
    vol_grd(Pnode_all(i,1),Pnode_all(i,2),Pnode_all(i,3)) = vol_grd(Pnode_all(i,1),Pnode_all(i,2),Pnode_all(i,3)) + hex_vol;
end
 
%% thresholding
th_grd_img= grd_img; % th_grd_img = thresholded grd_img
 
%threshold according to type
switch thresh_type
    case 'g' %normal "above half max" style threshold
        th_grd_img(abs(th_grd_img)<thresh*max(abs(th_grd_img(:))))=0;
    case 'g-'
        th_grd_img(th_grd_img > thresh*min(th_grd_img(:)))=0;
    case 'g+'
        th_grd_img(th_grd_img < thresh*max(th_grd_img(:)))=0;
       
    case 's-' %forces negative changes, significant if greater than the mag of the postive change
        sig_thres=-max(th_grd_img(:))-thresh*(abs(min(th_grd_img(:)))-abs(max(th_grd_img(:))));
        th_grd_img(th_grd_img > sig_thres) =0;
    case 's+'
        sig_thres=abs(min(th_grd_img(:)))+thresh*(max(th_grd_img(:))-abs(min(th_grd_img(:))));
        th_grd_img(th_grd_img < sig_thres) =0;
end
 
%% find blobs
 
% choosing the largest connected volume
conn=conndef(ndims(th_grd_img),'minimal'); % create connectivity array
CC=bwconncomp(th_grd_img,conn); % find connected components in the image
% CC.PixelIdxList holds indices groups of  the connected groups
numPixels = cellfun(@numel,CC.PixelIdxList); % holds the number of elements in every connected part (pert)
idx = find(numPixels==max(numPixels)); % finding the index of the largest pert in numPixels list
if (length(idx) > 1) % if two or more areas have the same size, select the first of them
    idx = idx(1);
end
 
% binary mask for chosen perturbation
bin=zeros(size(th_grd_img));
bin(CC.PixelIdxList{idx}) = 1;
 
msk_grd_img= th_grd_img; % msk_grd_img = masked grd_img
msk_grd_img(bin==0)=0; % leaves only values within the chosen perturbation
 
%% find centres
 
% centre of mass co-ordinates(cm)
[X,Y,Z] = ind2sub(size(msk_grd_img),(1:prod(size(msk_grd_img)))');
cm = [sum(msk_grd_img(:).*X),sum(msk_grd_img(:).*Y),sum(msk_grd_img(:).*Z)]/sum(msk_grd_img(:));
cm_or=(cm+pos_shift)*d; %put the perturbation in the original coordinates of the mesh
 
% shape representation: Dx,Dy,Dy - coordinates from cm#
 
% method 1 - max distance in X Y Z of the perturbation
Dxyz_m= d*[max(X(msk_grd_img(:)~=0))-min(X(msk_grd_img(:)~=0)),max(Y(msk_grd_img(:)~=0))-min(Y(msk_grd_img(:)~=0)),max(Z(msk_grd_img(:)~=0))-min(Z(msk_grd_img(:)~=0))];
% method 2 - sd from cm of pert in X Y Z
Dxyz_sd = d*4*sqrt(nanmean([(X(msk_grd_img(:)~=0)-cm(1)),(Y(msk_grd_img(:)~=0)-cm(2)),(Z(msk_grd_img(:)~=0)-cm(3))].^2));
 
% summing volumes of chosen perturbation
vol= sum (vol_grd(bin==1));

% summing the volume scaled by change
sum_of_change = sum(vol_grd(bin==1).*grd_img(bin==1));
 
%% Calculating Image SNr
% noise
bg_grd_img= grd_img;
bg_grd_img(bin==1)=NaN;
img_noise= nanstd(abs(bg_grd_img(:)));
img_noise_mean=nanmean(abs(bg_grd_img(:)));% for emmas calcs
% signal
pert_grd_img= grd_img;
pert_grd_img(bin==0)=NaN;
img_signal= nanmean(abs(pert_grd_img(:)));
 
%% output
img_prop.cm= cm;
img_prop.cm_or=cm_or;
img_prop.D_sd= Dxyz_sd;
img_prop.D_minmax= Dxyz_m;
img_prop.vol= vol;
img_prop.img_noise= img_noise;
img_prop.img_noise_mean=img_noise_mean;
img_prop.img_signal= img_signal;
img_prop.sum_of_change = sum_of_change;

img_prop.details.bin = bin;
img_prop.details.sigma = grd_img;
img_prop.details.volumes = vol_grd;
 

