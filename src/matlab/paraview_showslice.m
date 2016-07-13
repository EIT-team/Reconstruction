function [ status ] = paraview_showslice( MeshHex,MeshNodes,Data,CameraStr,Centre,Cmap,Cmap_title,SavePath,ReuseVTK,AnimationSavePath,FrameRate)
%PARAVIEW_SHOWSLICE Display data in paraview as a slice. Creates loading script and call
%paraview with this script at start up. Can save animations and
%screenshots automatically. Can also load camera file.

% This has lots of inputs, but only 3 really needed for command window use.
% The rest are all needed when you are going to automate creating images or
% movies.

% Inputs
% MeshHex - from the Mesh_hex standard struc
% MeshNodes - from the Mesh_hex standard struc
% Data - data to write Hex x Timesteps. If none given then dummy array
% created
% SavePath - Path to save the VTK and Python script, temp folder used if
% not. Can be relative or absolute path. doesnt have to end in .vtk
% Cmap - colour map range to use, i.e. [-100 100]. If empty -/+ max range is
% used
% Cmap_title - Text above colourbar
% CameraStr - set camera to (-/+) X Y or Z directions with a single string
% i.e. 'x' or '-y' like the GUI in paraview. Or load a camera file, must
% end with '.pvcc', i.e. '/iso.pvcc'. Copes with relative or absolute paths
% ReuseVTK - Flag to save VTKs or not. 0 or empty saves them. 1 resuses
% them if they exist, throws error if they dont
% AnimationSavePath - Where to store animations, extensions that work are
% .png or .avi. .png used if none given. If empty then not used. Relative
% and absoluate path work
% FrameRate - Frame rate for animations. 10 used if not given

% example usages....

%% Check inputs

%make fake data if none given, use to check mesh etc.
if exist('Data','var') == 0 || isempty(Data)
    fprintf('No data given, using temp data\n');
    Data = 1:size(MeshHex,1);
    Data = Data - max(Data)/2;
    Data = Data';
end

%check if mesh and data match etc.
if size(MeshHex,1) ~= size(Data,1)
    error('Size of data and hexes dont match');
end

%check if centre given - pyuthon script will take centre of mesh if not
%given
if exist('Centre','var') == 0 || isempty(Centre)
    fprintf('No centre given, using centre of mesh\n');
    DoCentre =0;
else
    if size(Centre,2) == 3
        DoCentre =1;
        fprintf('Using centre : [%.2f,%.2f,%.2f]\n',Centre(1),Centre(2),Centre(3));
    else
        DoCentre =0;
        fprintf(2,'Dont understand centre input. Using default');
    end
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
    vtk_path_str = fullfile(Save_root,Save_name);
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
    DoCmapTitle =0;
else
    DoCmapTitle =1;
end

% Find max of dataset rounded up
MaxinData = ceil(max(max(abs(Data))));

%sets the range of the colormap
if exist('Cmap','var') == 0 || isempty(Cmap)
    %if not given then take default which is centred at 0
    Cmap = [-MaxinData, MaxinData];
    
    DoColourMap = 0;
    
else %if 2 given then use these explicity
    
    DoColourMap = 1;
    
    if length(Cmap) == 1
        %if only 1 given, then duplicate this for both min and max changes
        Cmap = [-abs(Cmap) abs(Cmap)];
    end
end

% SOME DEFAULTS THAT I DOUBT PEOPLE WILL WANT TO ALTER

% This is how the data is refered to in paraview
Cmap_name = 'Data'; %NOT the text on the colorbar
%background opacity
Bkg_Op = 0.1;

%% Get Camera Setting

legit_camera ={'x','y','z'};
legit_camera = [strcat('-',legit_camera) legit_camera strcat('+',legit_camera)];

if exist('CameraStr','var') == 0 || isempty(CameraStr)
    CameraStr = 'y';
    fprintf(2,'No Camera string given, so using ''y'' \n');
    
else
    %if its not a string then set to default it
    if ~ischar(CameraStr)
        CameraStr = 'y';
        fprintf(2,'No Camera string given, so using ''y'' \n');
    end
    
    if ismember(lower(CameraStr), legit_camera) %check if input is legit
        CameraStr=lower(CameraStr);
        %added this as I forgot the correct format after 10 minutes of
        %writing this
        if strcmp(CameraStr(1),'+')
            CameraStr(1)=[];
        end
        
    else
        fprintf(2,'Didnt understand camera direction, ignoring. Must end with .pvcc to use camera file.\n');
        CameraStr = 'y';
        fprintf(2,'No Camera string given, so using ''y'' \n');
    end
end

%% Display Text
%output to user

if DoColourMap
fprintf('Values used: Cmap=[%d,%d] ', Cmap(1),Cmap(2));
else
    fprintf('Setting colourmap based on range in slice');
end
fprintf('\nSetting Camera and slicing with %s\n',CameraStr);

%% Write the VTK file

%set defaults for resuing vtk flag
if exist('ReuseVTK','var') == 0 || isempty(ReuseVTK)
    ReuseVTK = 0;
end

if ReuseVTK
    % check all vtks exist if asked not to create them
    fprintf('Using existing VTKs, checking...');
    file_exists=zeros(NumSteps,1);
    
    for iStep = 1:NumSteps
        file_exists(iStep) = exist(vtk_path{1,1},'file');
    end
    
    if ~all(file_exists)
        fprintf(':(\n');
        error('VTK FILES MISSING');
    end
    fprintf('done\n');
    
else
    %write all vtks with the correct suffix
    fprintf('Writing VTKs...');
    for iStep = 1:NumSteps
        writeVTKcell_hex(vtk_path{iStep},MeshHex,MeshNodes,Data(:,iStep),Cmap_name);
    end
    fprintf('done\n');
end

%% Check Animation

DoAnimation =1;

if exist('AnimationSavePath','var') == 0 || isempty(AnimationSavePath)
    DoAnimation = 0;
    AnimationSavePath='';
end
if exist('FrameRate','var') == 0 || isempty(FrameRate)
    FrameRate = 10;
end

if DoAnimation
    
    % make path absolute if not given as such
    javaFileObj = java.io.File(AnimationSavePath);
    
    if ~javaFileObj.isAbsolute()
        AnimationSavePath = fullfile(pwd,AnimationSavePath);
    end
    
    % make output a png if not given otherwise
    [AnimationSave_root,AnimationSave_name,AnimationSave_ext] = fileparts(AnimationSavePath);
    if isempty(AnimationSave_ext)
        AnimationSave_ext='.png';
        fprintf(2,'NO FILETYPE GIVEN FOR OUTPUT. Using .png\n');
    end
    
    %make a pythony path string
    animation_path_str = fullfile(AnimationSave_root,[AnimationSave_name AnimationSave_ext]);
    fprintf('Saving output to file(s) : %s\n',animation_path_str);
    
    animation_path_str = strrep(animation_path_str,'\','/');
    
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

fprintf(fid,'Cmap = [%d, %d]\n', Cmap(1),Cmap(2));
fprintf(fid,'Cmap_title = ''%s'' \n', Cmap_title);

%filenames
%now *this* is hacky as fuck
fprintf(fid,'VTKnamesIn = [''%s''] \n', strjoin(vtk_path_python,''','''));

fprintf(fid,'VTK_Filenames = ShowData.ConvertFilenames(VTKnamesIn) \n');

%load the data
fprintf(fid,'Data = LegacyVTKReader(FileNames=VTK_Filenames)\n');

%showslice with required arguments
fprintf(fid,'ShowData.ShowSliceData(Data, ''%s''',CameraStr);

if DoCentre
    fprintf(fid,',Centre=[%.2f,%.2f,%.2f]',Centre(1),Centre(2),Centre(3));
end

if DoColourMap
    fprintf(fid,',ColourMapRange=Cmap');
end

if DoCmapTitle
    fprintf(fid,',ColourMapLegend=Cmap_title');
end
fprintf(fid,')\n');


if DoAnimation
    fprintf(fid,'ShowData.SaveAnimation(''%s'', %d)',animation_path_str,FrameRate);
end

fprintf(fid,'\n');

fclose(fid);

%% call paraview with this new script

cmdstr=sprintf('paraview --script=%s &',script_path);

[status, cmdout] = system(cmdstr,'-echo');


end

