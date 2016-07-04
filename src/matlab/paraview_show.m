function [ status ] = paraview_show( MeshHex,MeshNodes,Data,SavePath)
%PARAVIEW_SHOW Summary of this function goes here
%   Detailed explanation goes here

%% Check inputs

%check if mesh and data match etc.


%% Check where we are saving the data to
%shove it in the temp dir

temp_dir=[fileparts(mfilename('fullpath')) filesep 'temp'];
temp_vtk_name = 'test.vtk';
temp_script_name = 'test.py';


if exist('SavePath','var') == 0
    
    %if none given use temp directory in recon repo -  this is set to be
    %ignored by temp. so we good
    script_path= [temp_dir filesep temp_script_name];
    vtk_path = [ temp_dir filesep temp_vtk_name];
    
    if ~isdir(temp_dir)
        mkdir(temp_dir)
    end
    
else
    %check if input directory is absolute or relative - we have to write
    %full relative paths for python script
    
    % make path absolute if not given as such
    javaFileObj = java.io.File(SavePath);
    
    if ~javaFileObj.isAbsolute()
        SavePath = fullfile(pwd,SavePath);
    end

    [Save_root,Save_name] = fileparts(SavePath);
    script_path = fullfile(Save_root,[Save_name '.py']);
    vtk_path = fullfile(Save_root,[Save_name '.vtk']);
    
end

% python and paraview dont like these path formats, so we need to convert
% to /
script_path_python = strrep(script_path,'\','/');
vtk_path_python = strrep(vtk_path,'\','/');



%% Get variables to write

%check if passed or calculate

% This is how the data is refered to in paraview
Cmap_name = 'Data';
%This is the colorbar legend, separate so we can have longer text
Cmap_title = 'Legend FTW';

%sets the range of the colormap

% Find max of dataset rounded up
MaxinData = ceil(max(max(abs(Data)))); 
Cmap = [-MaxinData, MaxinData];

% Default threshold is FWHM in each direction

%find the biggest change of negative and positive directions
MaxPos = (max(max((Data(Data > 0))))); 
MaxNeg = (min(min((Data(Data < 0))))); 

%set FWHM thresholds - SET BOTH TO ZERO TO DISABLE
Thr_Neg =[MaxNeg, MaxNeg/2];
Thr_Pos =[MaxPos/2, MaxPos];

%background opacity
Bkg_Op = 0.1;


%% Write the VTK file

writeVTKcell_hex(vtk_path,MeshHex,MeshNodes,Data,Cmap_name);


%% Write python script

%this is hacky as fuck and I dont like it. But it works.
%this could be avoided if you could pass arguments to the python script

fid=fopen(script_path,'w+');

%imports
fprintf(fid,'import os\n');
fprintf(fid,'from paraview.simple import *\n');
fprintf(fid,'from ParaviewLoad import ShowData\n');
% variables
fprintf(fid,'Cmap_name = ''%s'' \n', Cmap_name);
fprintf(fid,'Cmap_title = ''%s'' \n', Cmap_title);
fprintf(fid,'Cmap = [%d, %d]\n', Cmap(1),Cmap(2));
fprintf(fid,'Thr_Neg = [%d, %d]\n', Thr_Neg(1),Thr_Neg(2));
fprintf(fid,'Thr_Pos = [%d, %d]\n', Thr_Pos(1),Thr_Pos(2));
fprintf(fid,'Bkg_Op = %.1f \n', Bkg_Op);

%filenames
fprintf(fid,'VTK_Filenames = os.path.abspath(''%s'') \n', vtk_path_python);

%load the data
fprintf(fid,'Data = LegacyVTKReader(FileNames=[VTK_Filenames])\n');

%showdata
fprintf(fid,'ShowData.ShowThresholdData(Data, Cmap, Thr_Neg, Thr_Pos, Cmap_name, Cmap_title, Bkg_Op)');

fclose(fid);

%% call paraview with this new script

cmdstr=sprintf('paraview --script=%s &',script_path);

[status, cmdout] = system(cmdstr,'-echo');


end

