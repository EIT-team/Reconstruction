% Example usages for paraview functions

Failed = 0;

%% load reference data

%load hex mesh
load('../resources/mesh/Neonate_hex_lowres.mat');
%load tetra mesh
load('../resources/mesh/Ex_Cyl_Small.mat');

temp_dir = [ pwd filesep 'test_output'];
temp_name = [ temp_dir filesep 'testfullpath_comp'];
png_name = [ temp_dir filesep 'ani_testfull_comp.png'];
avi_name = [ temp_dir filesep 'ani_testfull_comp.avi'];

CameraFilePathRel='..\resources\vtk\iso.pvcc';

CameraFilePathFull=fullfile(pwd,CameraFilePathRel);

if ~isdir(temp_dir)
    mkdir(temp_dir)
end

%load data from paraview_compareslice
load('../resources/data/Neonate_hex_lowres_example','Data_hex');
load('../resources/data/Cyl_tetra_lowres_example','Data');

PertLocHex = [ -33 -141 510; -60 -141 510; -10 -110 540];
PertLocTetra = [ 0 0.7 0.5; 0 0.6 0.50; 0 0.5 0.5];

%% test given data - single 

try
    c=paraview_compare(Mesh_hex,Data_hex(:,1),PertLocHex(1,:));
    assert(~c);
catch err
    disp('Error with example data single - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_compare(Mesh,Data(:,1),PertLocTetra(1,:),0.2);
    assert(~c);
catch err
    disp('Error with example data single - tetra')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


pause(5);
if ispc
    system('taskkill /IM paraview.exe');
end

%% test given data - multi 

try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10);
    assert(~c);
catch err
    disp('Error with example data multi - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_compare(Mesh,Data,PertLocTetra,0.2);
    assert(~c);
catch err
    disp('Error with example data multi - tetra')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


pause(5);
if ispc
    system('taskkill /IM paraview.exe');
end


%% test vtk path
try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],temp_name);
    assert(~c);
catch err
    disp('Error with example data and reusevtk - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],'/test_output/testingabs');
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
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,1,temp_name);
    assert(~c);
catch err
    disp('Error with example data and reusevtk - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,1,'/test_output/testingabs');
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
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[0.3],[0.3]);
    assert(~c);
catch err
    disp('Error with thres coefficent - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

%set manually
try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[-0.9 -0.4],[0.1 0.5]);
    assert(~c);
catch err
    disp('Error with thres manual set - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[0],[0.1 0.5]);
    assert(~c);
catch err
    disp('Error with thres disable neg - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[-0.9 -0.4],[0]);
    assert(~c);
catch err
    disp('Error with thres disable pos - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

pause(5);
if ispc
%     system('taskkill /IM paraview.exe');
end

%% test cmap

try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[],[],[3],[]);
    assert(~c);
catch err
    disp('Error with cmap coeff - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[],[],[-1 2],'hello');
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
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[],[],[],[],'x');
    assert(~c);
catch err
    disp('Error with camera str x - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[],[],[],[],'-y');
    assert(~c);
catch err
    disp('Error with camera str -y - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[],[],[],[],CameraFilePathRel);
    assert(~c);
catch err
    disp('Error with camera relative path - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[],[],[],[],CameraFilePathFull);
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
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[],[],[],[],[],'/test_output/tstrel_comp.png');
    assert(~c);
catch err
    disp('Error with animate png relative - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[],[],[],[],[],'/test_output/tstrel_comp.avi');
    assert(~c);
catch err
    disp('Error with animate avi relative - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[],[],[],[],[],png_name);
    assert(~c);
catch err
    disp('Error with animate png abs - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[],[],[],[],[],avi_name);
    assert(~c);
catch err
    disp('Error with animate avi abs - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_compare(Mesh_hex,Data_hex,PertLocHex,10,[],[],[],[],[],[],[],avi_name,1);
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







