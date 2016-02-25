function [img_err] = comp_img (bg_img, img, D_ref, V_ref, weights) 
 
% bg_img, img - images structures: cm (center of mass), Vol (volume), D_sd (diameters), img_noise, img_signal
% D_ref - whole mesh xyz diameters
% V_ref - whole mesh volume
% weights - weights vectors for the different errors to sum up for total
% error
 
%slightly modifyed by jimmy sept 14
 
% localization error
bg_cm= bg_img.cm_or;
cm= img.cm_or;
distance= sqrt(sum((cm-bg_cm).^2));
loc_err= (distance/mean(D_ref))*100;
 
% volume error
vol_err= (abs(img.vol-bg_img.vol)/V_ref)*100;
 
% total change error
sum_of_change = abs(img.sum_of_change - bg_img.sum_of_change) / bg_img.sum_of_change;

% shape error
bg_D_sd= bg_img.D_sd;
D_sd= img.D_sd;
 
shape_err= (nanmean(abs(D_sd-bg_D_sd)./D_ref))*100;
 
% noise error
nsr_err= (img.img_noise/ img.img_signal)*100;
 
% total error
tot_err= (loc_err * weights(1) + vol_err * weights(2) + shape_err * weights(3) + nsr_err * weights(4))/sum (weights);
 
%% using emmas version
 
emma.imnoise=img.img_noise/abs(img.img_signal-img.img_noise_mean);
emma.centre=norm(cm-bg_cm)./norm(D_ref);
emma.shape=mean(abs(img.D_minmax-bg_img.D_minmax)./D_ref);

%% using markus version

markus.centre       = loc_err;
markus.ROIchange    = abs(mean(img.details.sigma(bg_img.details.bin==0))) / abs(mean(img.details.sigma(bg_img.details.bin==1))) * 100; % for TD
    if sign(mean(img.details.sigma(bg_img.details.bin==1)))~=sign(mean(bg_img.details.sigma(bg_img.details.bin==1)))
        markus.ROIchange = markus.ROIchange + 100; % IF ROI HAS WRONG CHANGE, PUNISH THIS ERROR MEASURE
    end
markus.ROInoise     = mean(abs(img.details.sigma(bg_img.details.bin==0))) / mean(abs(img.details.sigma(bg_img.details.bin==1))) * 100; % for TD
markus.shape        = sqrt(sum((img.D_minmax-bg_img.D_minmax).^2)/sqrt(sum((bg_img.D_minmax).^2)))*100; % for MF
markus.noise2contr  = img.img_noise/abs(img.img_signal-img.img_noise_mean)*100; % for MF

%% output
img_err.loc_err= loc_err;
img_err.distance=distance;
img_err.vol_err= vol_err;
img_err.shape_err= shape_err;
img_err.nsr_err= nsr_err;
img_err.tot_err= tot_err;
img_err.emma=emma;
img_err.sum_of_change = sum_of_change;
img_err.markus = markus;
 