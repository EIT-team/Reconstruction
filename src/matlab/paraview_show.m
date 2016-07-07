function [ status ] = paraview_show( MeshHex,MeshNodes,Data,SavePath,Thr_Neg,Thr_Pos,Cmap,Cmap_title,CameraStr)
%PARAVIEW_SHOW Summary of this function goes here
%   Detailed explanation goes here

%% Check inputs

%check if mesh and data match etc.

if size(MeshHex,1) ~= size(Data,1)
    error('Size of data and hexes dont match');
end

%number of files
NumSteps = size(Data,2);
TimeSteps=1:NumSteps;


%% Check where we are saving the data to
%shove it in the temp dir

temp_dir=[fileparts(mfilename('fullpath')) filesep 'temp'];
temp_vtk_name = 'test';
temp_script_name = 'test.py';

if exist('SavePath','var') == 0 || isempty(SavePath)
    
    fprintf('Saving vtkdata in temp directory\n');
    %if none given use temp directory in recon repo -  this is set to be
    %ignored by temp. so we good
    script_path= [temp_dir filesep temp_script_name];
    
    % first create string
    vtk_path_str = [ temp_dir filesep temp_vtk_name];
    
    %temp dir might not exist as it is included in .gitignore
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
    vtk_path_str = fullfile(Save_root,[Save_name]);
    fprintf('Saving vtkdata in: %s\n',vtk_path_str);
    
end

%then make cell array for each time step
vtk_path=cell(NumSteps,1);
vtk_path(:)={vtk_path_str};

% put in path_1 path_2 form
vtk_path=strcat(vtk_path,'_',strtrim(cellstr(num2str(TimeSteps'))')','.vtk');

% python and paraview dont like these path formats, so we need to convert
% to /
script_path_python = strrep(script_path,'\','/');
vtk_path_python = strrep(vtk_path,'\','/');

%% Get scale and threshold variables

%check if passed or calculate

%This is the colorbar legend, separate so we can have longer text

if exist('Cmap_title','var') == 0 || isempty(Cmap_title)
    Cmap_title = 'SigmaProbably';
end

% Find max of dataset rounded up
MaxinData = ceil(max(max(abs(Data))));

%sets the range of the colormap
if exist('Cmap','var') == 0 || isempty(Cmap)
    %if not given then take default which is centred at 0
    Cmap = [-MaxinData, MaxinData];
else %if 2 given then use these explicity
    if length(Cmap) == 1
        %if only 1 given, then duplicate this for both min and max changes
        Cmap = [-abs(Cmap) abs(Cmap)];
    end
end

% Find max of dataset rounded up
MaxNeg = (min(min((Data(Data < 0)))));
% Default threshold is FWHM in each direction
if exist('Thr_Neg','var') == 0 || isempty(Thr_Neg)
    %if not given then do defaults
    Thr_Neg =[MaxNeg, MaxNeg/2];
else % if 2 given then use these explicit values
    if length(Thr_Neg) == 1
        %only 1 given then take this as a coefficient - i.e. 0.5 is full
        %width half max. 0.3 is full width third max etc.
        Thr_Neg = [MaxNeg, (1-abs(Thr_Neg))*MaxNeg];
    end
end

%find the biggest change of negative and positive directions
MaxPos = (max(max((Data(Data > 0)))));
if exist('Thr_Pos','var') == 0 || isempty(Thr_Pos)
    Thr_Pos =[MaxPos/2, MaxPos];
else % if 2 given then use these explicit values
    if length(Thr_Pos) == 1
        %only 1 given then take this as a coefficient - i.e. 0.5 is full
        %width half max. 0.3 is full width third max etc.
        Thr_Pos = [(1-abs(Thr_Pos))*MaxPos, MaxPos];
    end
end

% SOME DEFAULTS THAT I DOUBT PEOPLE WILL WANT TO ALTER

% This is how the data is refered to in paraview
Cmap_name = 'Data';
%background opacity
Bkg_Op = 0.1;

%% Get Camera Setting

legit_camera ={'x','y','z'};
legit_camera = [strcat('-',legit_camera) legit_camera strcat('+',legit_camera)];

%do camera flag - dont write the command if we dont want it
DoCamera = 1;

if exist('Camera','var') == 0 || isempty(CameraStr)
    DoCamera =0;
else
    %check if input is legit
    CameraStr=lower(CameraStr);
    if ismember(CameraStr, legit_camera)
        %added this as I forgot the correct format after 10 minutes of
        %writing this
        if strcmp(CameraStr(1),'+')
            CameraStr(1)=[];
        end
    else
        fprintf(2,'Didnt understand camera direction. Ignoring'\n');
        DoCamera =0;
    end
end

%% Display Text
%output to user
fprintf('Values used: Cmap=[%d,%d] ', Cmap(1),Cmap(2));

if any(Thr_Neg)
    fprintf('Thr_Neg=[%.2f,%.2f] ', Thr_Neg(1),Thr_Neg(2));
end
if any(Thr_Pos)
    fprintf('Thr_Pos=[%.2f, %.2f] ', Thr_Pos(1),Thr_Pos(2));
end
if DoCamera
    fprintf('\nSetting Camera with %s',CameraStr);
end

fprintf('\n');

%% Write the VTK file

fprintf('Writing VTKs...\n');
for iStep = 1:NumSteps
    writeVTKcell_hex(vtk_path{iStep},MeshHex,MeshNodes,Data(:,iStep),Cmap_name);
end

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
fprintf(fid,'Thr_Neg = [%.2f, %.2f]\n', Thr_Neg(1),Thr_Neg(2));
fprintf(fid,'Thr_Pos = [%.2f, %.2f]\n', Thr_Pos(1),Thr_Pos(2));
fprintf(fid,'Bkg_Op = %.1f \n', Bkg_Op);

%filenames
%now *this* is hacky as fuck
fprintf(fid,'VTKnamesIn = [''%s''] \n', strjoin(vtk_path_python,''','''));

fprintf(fid,'VTK_Filenames = ShowData.ConvertFilenames(VTKnamesIn) \n');

%load the data
fprintf(fid,'Data = LegacyVTKReader(FileNames=VTK_Filenames)\n');

%showdata
fprintf(fid,'ShowData.ShowThresholdData(Data, Cmap, Thr_Neg, Thr_Pos, Cmap_name, Cmap_title, Bkg_Op)\n');

%change camera if we want to
if DoCamera
    fprintf(fid,'ShowData.SetCamera(Data, ''%s'')',CameraStr);
end

fclose(fid);

%% call paraview with this new script

cmdstr=sprintf('paraview --script=%s &',script_path);

[status, cmdout] = system(cmdstr,'-echo');


end

