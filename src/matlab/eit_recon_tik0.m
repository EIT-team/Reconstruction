function [Sigma,X,sv_i] = eit_recon_tik0(Data,J,Savename,Noise,U,S,V,lambda)
%eit_recon_tik0 Creates EIT images using 0th order tiknonov and noise based
%correction

tstart=tic;
%% Prepare noise for correction

if exist('Noise','var') ==0
    Noise=3e-6*randn(500,length(Data));
end

if exist('lambda','var') ==0
    %pick lambda searchspace
lambda = logspace(-20,-2,500);
end


%% Put variables in common names

n_T = size(Data,1);
n_J = size(J,1);


%% Cross-validated inversion
tic;
if (exist('U','var') ==1) && (exist('S','var') ==1) && (exist('V','var') ==1)
    disp('SVD given');
else
    disp('Doing SVD');
    %SVD
    [U,S,V] = svd(J,'econ');
    fprintf('SVD done: %.2f min\n',toc(tstart)/60);
end
%%
disp('inverting');
%Do inversion
[X,cv_error,sv_i] = tikhonov_CV(J,Data',lambda,n_J,U,S,V);
fprintf('X done: %.2f min\n',toc(tstart)/60);

%% Find opt lambda

opt = zeros(n_T,1);
for iT=1:n_T
    e = cv_error(:,iT);
    f = (e(1:end-2)>=e(2:end-1))&(e(3:end)>e(2:end-1));
    if any(f)
        opt(iT) = find(f,1,'last')+1;
        disp(['Check your cv_error, sample=' num2str(iT)]);
    else
        [m,opt(iT)] = min(e);
    end
end
%%
figure
hold on
for iT=1:n_T
    plot(lambda,cv_error(:,iT),'-')
    plot(lambda(opt(iT)),cv_error(opt(iT),iT),'o')
end
xlabel('Lambda');
ylabel('CV error');
hold off
set(gca,'Xscale','log')
drawnow


%% Compute correction
disp('Applying correction');

UtNoise = U'*Noise';
sv = diag(S);

SD = zeros(size(X));
for iT=1:size(SD,2)
    sv_i = sv+lambda(opt(iT))./sv;
    SD(:,iT) = std(V*(diag(1./sv_i)*UtNoise),0,2);
end

Sigma=X./SD;


%% Save
disp('Saving');


savedir=[pwd filesep];

save([savedir Savename '.mat'],...
    'Sigma','X','cv_error','lambda','Data','-v7.3');


end

