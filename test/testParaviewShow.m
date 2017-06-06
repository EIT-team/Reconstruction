% Example usages for paraview functions

Failed = 0;

%% load reference data

%load hex mesh
load('../resources/mesh/Neonate_hex_lowres.mat');
%load tetra mesh (which is rubbish)
load('../resources/mesh/Ex_Cyl_Small.mat');

temp_dir = [ pwd filesep 'test_output'];
temp_name = [ temp_dir filesep 'testfullpath'];
png_name = [ temp_dir filesep 'ani_testfull.png'];
avi_name = [ temp_dir filesep 'ani_testfull.avi'];

CameraFilePathRel='..\resources\vtk\iso.pvcc';

CameraFilePathFull=fullfile(pwd,CameraFilePathRel);

if ~isdir(temp_dir)
    mkdir(temp_dir)
end

%% Make example data for hexes
cnts=zeros(length(Mesh_hex.Hex),3);
for i=1:8
    cnts=cnts+Mesh_hex.Nodes(Mesh_hex.Hex(:,i),:)/8;
end

PertLocPos = [ -33 -141 510; -60 -141 510; -10 -110 540];
PertLocNeg = [ -60 -141 510; -10 -110 540; -33 -141 510;];
Radius = 50;


nPert=length(PertLocPos);

Data_hex=nan(size(Mesh_hex.Hex,1),nPert);

for ipert=1:nPert
    sigmanew_hexpos=zeros(size(Mesh_hex.mat));
    sigmanew_hexneg=zeros(size(Mesh_hex.mat));
    rad=Radius;
    %     rad=Radius(ipert);
    
    %positive blob
    pos=PertLocPos(ipert,:);
    % find distance from pos
    
    %find distances of each centre from position centre
    dist=cnts-repmat(pos,length(cnts),1);
    dist=sum(dist.^2,2).^0.5;
    
    sigmanew_hexpos(dist<(rad)) =   + (1 -0.9);
    sigmanew_hexpos(dist<(rad*0.75)) =  + (1 -0.75);
    sigmanew_hexpos(dist<(rad*0.5)) =  + (1 - 0.5);
    sigmanew_hexpos(dist<(rad*0.33)) =  + (1- 0.33);
    sigmanew_hexpos(dist<(rad*0.25)) =  + (1- 0.25);
    sigmanew_hexpos(dist<(rad*0.1)) =  + (1);
    
    %negative blob
    pos=PertLocNeg(ipert,:);
    % find distance from pos
    
    %find distances of each centre from position centre
    dist=cnts-repmat(pos,length(cnts),1);
    dist=sum(dist.^2,2).^0.5;
    
    sigmanew_hexneg(dist<(rad)) =   - (1 -0.9);
    sigmanew_hexneg(dist<(rad*0.75)) =  - (1 -0.75);
    sigmanew_hexneg(dist<(rad*0.5)) =  - (1 - 0.5);
    sigmanew_hexneg(dist<(rad*0.33)) =  - (1- 0.33);
    sigmanew_hexneg(dist<(rad*0.25)) =  - (1- 0.25);
    sigmanew_hexneg(dist<(rad*0.1)) =  - (1);
    
    Data_hex(:,ipert)=sigmanew_hexpos+ sigmanew_hexneg;
end

save('../resources/data/Neonate_hex_lowres_example','Data_hex');


%% Make example data for tetra mesh

cnts_tetra=(Mesh.Nodes(Mesh.Tetra(:,1),:)+Mesh.Nodes(Mesh.Tetra(:,2),:)+Mesh.Nodes(Mesh.Tetra(:,3),:)+Mesh.Nodes(Mesh.Tetra(:,4),:))/4;

PertLocPos = [ 0 0.7 0.5; 0 0.6 0.50; 0 0.5 0.5];
PertLocNeg = [ 0 -0.7 0.5; 0 -0.6 0.5; 0 -0.5 0.5];
Radius = 0.5;

nPert=length(PertLocPos);

Data=nan(size(Mesh.Tetra,1),nPert);

for ipert=1:nPert
    sigmanew_pos=zeros(size(Mesh.Tetra,1),1);
    sigmanew_neg=zeros(size(Mesh.Tetra,1),1);
    rad=Radius;
    %     rad=Radius(ipert);
    
    %positive blob
    pos=PertLocPos(ipert,:);
    % find distance from pos
    
    %find distances of each centre from position centre
    dist=cnts_tetra-repmat(pos,length(cnts_tetra),1);
    dist=sum(dist.^2,2).^0.5;
    
    sigmanew_pos(dist<(rad)) =   + (1 -0.9);
    sigmanew_pos(dist<(rad*0.75)) =  + (1 -0.75);
    sigmanew_pos(dist<(rad*0.5)) =  + (1 - 0.5);
    sigmanew_pos(dist<(rad*0.33)) =  + (1- 0.33);
    sigmanew_pos(dist<(rad*0.25)) =  + (1- 0.25);
    sigmanew_pos(dist<(rad*0.1)) =  + (1);
    
    %negative blob
    pos=PertLocNeg(ipert,:);
    % find distance from pos
    
    %find distances of each centre from position centre
    dist=cnts_tetra-repmat(pos,length(cnts_tetra),1);
    dist=sum(dist.^2,2).^0.5;
    
    sigmanew_neg(dist<(rad)) =   - (1 -0.9);
    sigmanew_neg(dist<(rad*0.75)) =  - (1 -0.75);
    sigmanew_neg(dist<(rad*0.5)) =  - (1 - 0.5);
    sigmanew_neg(dist<(rad*0.33)) =  - (1- 0.33);
    sigmanew_neg(dist<(rad*0.25)) =  - (1- 0.25);
    sigmanew_neg(dist<(rad*0.1)) =  - (1);
    
    Data(:,ipert)=sigmanew_pos+ sigmanew_neg;

end

save('../resources/data/Cyl_tetra_lowres_example','Data');


%% test demo usage

%test loading with just mesh, creating dummy data

try
    c=paraview_show(Mesh);
    assert(~c);
catch err
    disp('Error with dummy data - tetra')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_show(Mesh_hex);
    assert(~c);
catch err
    disp('Error with dummy data - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

pause(5);
if ispc
    system('taskkill /IM paraview.exe');
end

%% test given data

try
    c=paraview_show(Mesh_hex,Data_hex);
    assert(~c);
catch err
    disp('Error with example data - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_show(Mesh_hex,Data_hex,1);
    assert(~c);
catch err
    disp('Error with example data and reusevtk - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_show(Mesh,Data);
    assert(~c);
catch err
    disp('Error with example data - tetra')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_show(Mesh,Data,1);
    assert(~c);
catch err
    disp('Error with example data and reusevtk - tetra')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end






pause(5);
if ispc
    system('taskkill /IM paraview.exe');
end


%% test vtk path
try
    c=paraview_show(Mesh_hex,Data_hex,[],temp_name);
    assert(~c);
catch err
    disp('Error with example data and reusevtk - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_show(Mesh_hex,Data_hex,[],'/test_output/testingabs');
    assert(~c);
catch err
    disp('Error with example data and reusevtk - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


pause(5);
if ispc
    system('taskkill /IM paraview.exe');
end

%% test vtk path with reuse
try
    c=paraview_show(Mesh_hex,Data_hex,1,temp_name);
    assert(~c);
catch err
    disp('Error with example data and reusevtk - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_show(Mesh_hex,Data_hex,1,'/test_output/testingabs');
    assert(~c);
catch err
    disp('Error with example data and reusevtk - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


pause(5);
if ispc
    system('taskkill /IM paraview.exe');
end

%% test thresholds
%set ratio of full width - i.e. full width third max
try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[0.3],[0.3]);
    assert(~c);
catch err
    disp('Error with thres coefficent - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

%set manually
try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[-0.9 -0.4],[0.1 0.5]);
    assert(~c);
catch err
    disp('Error with thres manual set - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[0],[0.1 0.5]);
    assert(~c);
catch err
    disp('Error with thres disable neg - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[-0.9 -0.4],[0]);
    assert(~c);
catch err
    disp('Error with thres disable pos - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

pause(5);
if ispc
    system('taskkill /IM paraview.exe');
end

%% test cmap

try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[],[],[3],[]);
    assert(~c);
catch err
    disp('Error with cmap coeff - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[],[],[-1 2],'hello');
    assert(~c);
catch err
    disp('Error with cmap manual and name - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


pause(5);
if ispc
    system('taskkill /IM paraview.exe');
end

%% test camera

try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[],[],[],[],'x');
    assert(~c);
catch err
    disp('Error with camera str x - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[],[],[],[],'-y');
    assert(~c);
catch err
    disp('Error with camera str -y - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[],[],[],[],CameraFilePathRel);
    assert(~c);
catch err
    disp('Error with camera relative path - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[],[],[],[],CameraFilePathFull);
    assert(~c);
catch err
    disp('Error with camera full path - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

pause(5);
if ispc
    system('taskkill /IM paraview.exe');
end

%% test animation

try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[],[],[],[],[],'/test_output/tstrel.png');
    assert(~c);
catch err
    disp('Error with animate png relative - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[],[],[],[],[],'/test_output/tstrel.avi');
    assert(~c);
catch err
    disp('Error with animate avi relative - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[],[],[],[],[],png_name);
    assert(~c);
catch err
    disp('Error with animate png abs - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[],[],[],[],[],avi_name);
    assert(~c);
catch err
    disp('Error with animate avi abs - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_show(Mesh_hex,Data_hex,[],[],[],[],[],[],[],avi_name,1);
    assert(~c);
catch err
    disp('Error with animate avi abs framerate - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

pause(10);
if ispc
    system('taskkill /IM paraview.exe');
end

%% END

if Failed
    fprintf(2,'BOOO FAILED \n');
else
    fprintf('yay! all ok! \n');
end







