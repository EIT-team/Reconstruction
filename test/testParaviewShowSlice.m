% Example usages for paraview functions

Failed = 0;

%% load reference data

%load hex mesh
load('../resources/mesh/Neonate_hex_lowres.mat');
%load tetra mesh
load('../resources/mesh/Ex_Cyl_Small.mat');

temp_dir = [ pwd filesep 'test_output'];
temp_name = [ temp_dir filesep 'testfullpath_slice'];
png_name = [ temp_dir filesep 'ani_testfull_slice.png'];
avi_name = [ temp_dir filesep 'ani_testfull_slice.avi'];

CameraFilePathRel='..\resources\vtk\iso.pvcc';

CameraFilePathFull=fullfile(pwd,CameraFilePathRel);

if ~isdir(temp_dir)
    mkdir(temp_dir)
end

%load data from paraview_showslice
load('../resources/data/Neonate_hex_lowres_example','Data_hex');
load('../resources/data/Cyl_tetra_lowres_example','Data');

%% test demo usage

%test loading with just mesh, creating dummy data

try
    c=paraview_showslice(Mesh);
    assert(~c);
catch err
    disp('Error with dummy data - tetra')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_showslice(Mesh_hex);
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
    c=paraview_showslice(Mesh_hex,Data_hex);
    assert(~c);
catch err
    disp('Error with example data - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[],1);
    assert(~c);
catch err
    disp('Error with example data and reusevtk - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_showslice(Mesh,Data);
    assert(~c);
catch err
    disp('Error with example data - tetra')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_showslice(Mesh,Data,[],[],1);
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

%% test camera string

try
    c=paraview_showslice(Mesh_hex,Data_hex,'x');
    assert(~c);
catch err
    disp('Error with example data - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_showslice(Mesh_hex,Data_hex,'-z');
    assert(~c);
catch err
    disp('Error with example data and reusevtk - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_showslice(Mesh,Data,'x');
    assert(~c);
catch err
    disp('Error with example data - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_showslice(Mesh,Data,'-z');
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


%% test centre
PertLocPos = [ -33 -141 510; -60 -141 510; -10 -110 540];
PertLocPos = [ 0 0.7 0.5; 0 0.6 0.50; 0 0.5 0.5];

try
    c=paraview_showslice(Mesh_hex,Data_hex,'z',[-33 -141 510]);
    assert(~c);
catch err
    disp('Error with example data - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[-33 -141 510]);
    assert(~c);
catch err
    disp('Error with example data and reusevtk - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_showslice(Mesh,Data,'z',[0 0.7 0.5]);
    assert(~c);
catch err
    disp('Error with example data - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_showslice(Mesh,Data,[],[0 0.7 0.5]);
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


%% test vtk path
try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[],[],temp_name);
    assert(~c);
catch err
    disp('Error with full path - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[],[],'/test_output/testingabs');
    assert(~c);
catch err
    disp('Error with rel path - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


pause(5);
if ispc
    system('taskkill /IM paraview.exe');
end

%% test vtk path with reuse
try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[],1,temp_name);
    assert(~c);
catch err
    disp('Error with full path and reusevtk - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[],1,'/test_output/testingabs');
    assert(~c);
catch err
    disp('Error with rel path and reusevtk - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


pause(5);
if ispc
    system('taskkill /IM paraview.exe');
end


%% test cmap

try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[],[],[],[3]);
    assert(~c);
catch err
    disp('Error with cmap coeff - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[],[],[],[-1 2],'hello');
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

%% test animation

try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[],[],[],[],[],'/test_output/tstrel_slice.png');
    assert(~c);
catch err
    disp('Error with animate png relative - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[],[],[],[],[],'/test_output/tstrel_slice.avi');
    assert(~c);
catch err
    disp('Error with animate avi relative - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[],[],[],[],[],png_name);
    assert(~c);
catch err
    disp('Error with animate png abs - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end


try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[],[],[],[],[],avi_name);
    assert(~c);
catch err
    disp('Error with animate avi abs - hex')
    Failed = 1;
    fprintf(2, '%s\n', getReport(err, 'extended'));
end

try
    c=paraview_showslice(Mesh_hex,Data_hex,[],[],[],[],[],[],avi_name,1);
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







