function [ status ] = paraview_show( MeshStrucIn,Data,ReuseVTK,VTKSavePath,Thr_Neg,Thr_Pos,Cmap,Cmap_title,CameraStr,AnimationVTKSavePath,FrameRate)
%PARAVIEW_SHOW Display data in paraview, with transparent background, and Thresholds, with even colourbars.
% paraview_show( MeshStruc,Data,ReuseVTK,VTKSavePath,Thr_Neg,Thr_Pos,Cmap,Cmap_title,CameraStr,AnimationVTKSavePath,FrameRate)
%
%Creates loading script and call paraview with this script at start up.
%Can save animations and screenshots automatically. Can also load camera file.
%Paraview and this python library must be added to path.
%
% This has lots of inputs, but only the first two are  really needed for command window use.
% The rest are all needed when you are going to automate creating images or movies.
%
% Inputs
%
% Main two are:
%
% MeshStruc - standard struc - containing Nodes and either Hex or Tetra
% Data - data to write Hex x Timesteps. If none given then dummy array
% created
%
% Manually setting parameters, and saving images/movies automatically:
%
% ReuseVTK - Flag to save VTKs or not. 0 or empty saves them. 1 resuses
% them if they exist, throws error if they dont
% VTKVTKSavePath - Path to save the VTK and Python script, temp folder used if
% not. Can be relative or absolute path. doesnt have to end in .vtk
% Thr_Neg - Threshold to use for negative values. Give either 2 values
% [-100 -50], or a single value as a coefficient of max. i.e. giving a value
% of .1 shows top 10%. If not given full width half max used. set to [0,0]
% to disable.
% Thr_Pos - As above but with positive values
% Cmap - colour map range to use, i.e. [-100 100]. If empty -/+ max range is
% used i.e. centred around 0
% Cmap_title - Text above colourbar
% CameraStr - set camera to (-/+) X Y or Z directions with a single string
% i.e. 'x' or '-y' like the GUI in paraview. Or load a camera file, must
% end with '.pvcc', i.e. '/iso.pvcc'. Copes with relative or absolute paths
% AnimationVTKSavePath - Where to store animations, extensions that work are
% .png or .avi. .png used if none given. If empty then not used. Relative
% and absoluate path work
% FrameRate - Frame rate for animations. 10 used if not given
%
% Examples for Normal use:
%
% Display Full Width Half Max threshold for Postive and Negative Data, in
% mesh with transparent background, with colour bar range set to -/+ max :
%
% e.g. load the mesh /resources/mesh/Neonate_hex_lowres.mat and data /resources/data/Neonate_hex_lowres_example.mat
%
% 1. Test the mesh is ok - generates dummy data
% paraview_show(Mesh_hex);
%
% 2. load single recon data - as a single timepoint
% paraview_show(Mesh_hex,Data_hex(:,1));
%
% 2. load multiple timepoints of data - skip through timesteps to see each
% position
% paraview_show(Mesh_hex,Data_hex);
%
% Examples when automating making images are found in the TestParaviewShow
%paraview_show( MeshStruc,Data,ReuseVTK,VTKSavePath,Thr_Neg,Thr_Pos,Cmap,Cmap_title,CameraStr,AnimationVTKSavePath,FrameRate)





%% Check inputs

%should be usual Mesh structure
if ~isstruct(MeshStrucIn)
    if isa(MeshStrucIn,'toastMesh')
        disp('Converting TOAST mesh structure');
        [vtx,idx,eltp] = MeshStrucIn.Data;
        
        if all(eltp == 3) || all(eltp == 15)
            % extract the info about the tetra
            MeshStruc.Tetra = idx;
            MeshStruc.Nodes = vtx;
            
            if size(Data,1) == size(MeshStruc.Nodes,1)
                disp('Converting Node data to Tetra data');
                
                for iElem=1:size(MeshStruc.Tetra,1)
                    Data_temp=Data;
                    Data(iElem)=mean(full(Data_temp(MeshStruc.Tetra(iElem,:))));                  
                end
                Data=full(Data);
                
            end
            
        else
            error('Can only handle tetra input from toast atm');
        end
        
    else
        error('Need mesh structure input, with Nodes and Tetra/Hex or TOAST mesh');
    end
else
    MeshStruc=MeshStrucIn;
end

% check we have node coordinates in Nodes, and either Hex or Tetra refences
UsingHexes =0;

if (isfield(MeshStruc,'Hex') || isfield(MeshStruc,'Tetra')) && isfield(MeshStruc,'Nodes')
    % get the number of elements
    if  isfield(MeshStruc,'Hex')
        UsingHexes =1;
        NumElements = size(MeshStruc.Hex,1);
    else
        NumElements = size(MeshStruc.Tetra,1);
    end
    
else
    error ('Missing Fields from input mesh structure');
end

%make fake data if none given, use to check mesh etc.
if exist('Data','var') == 0 || isempty(Data)
    fprintf('No data given, using temp data\n');
    Data = 1:NumElements;
    Data = Data - max(Data)/2;
    Data = Data';
end

%check if mesh and data match etc.
if NumElements ~= size(Data,1)
    error('Size of data and elements dont match');
end

%number of files
NumSteps = size(Data,2);
TimeSteps=1:NumSteps;

%% Check where we are saving the data to
%shove it in the temp dir

temp_dir=[fileparts(mfilename('fullpath')) filesep 'temp'];
temp_vtk_name = 'test';
temp_script_name = 'test.py';

if exist('VTKSavePath','var') == 0 || isempty(VTKSavePath)
    
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
    javaFileObj = java.io.File(VTKSavePath);
    
    if ~javaFileObj.isAbsolute()
        VTKSavePath = fullfile(pwd,VTKSavePath);
    end
    
    [Save_root,Save_name] = fileparts(VTKSavePath);
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

%This is the colourbar legend, separate so we can have longer text

if exist('Cmap_title','var') == 0 || isempty(Cmap_title)
    Cmap_title = 'SigmaProbably';
end

% Find max of dataset rounded up
MaxinData = ceil(max(max(abs(Data))));

%sets the range of the colourmap
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

if isempty(MaxNeg)
    MaxNeg =0; % functions below dont like empty values. so set to zero
end


% Default threshold is FWHM in each direction
if exist('Thr_Neg','var') == 0 || isempty(Thr_Neg)
    %if not given then do defaults
    Thr_Neg =[MaxNeg, MaxNeg/2];
else % if 2 given then use these explicit values
    if length(Thr_Neg) == 1
        if Thr_Neg
            %only 1 given then take this as a coefficient - i.e. 0.5 is full
            %width half max. 0.3 is full width third max etc.
            Thr_Neg = [MaxNeg, (1-abs(Thr_Neg))*MaxNeg];
        else
            Thr_Neg = [0 0];
        end
    end
end

%find the biggest change of negative and positive directions
MaxPos = (max(max((Data(Data > 0)))));

if isempty(MaxPos)
    MaxPos =0; % functions below dont like empty values. so set to zero
end

if exist('Thr_Pos','var') == 0 || isempty(Thr_Pos)
    Thr_Pos =[MaxPos/2, MaxPos];
else % if 2 given then use these explicit values
    if length(Thr_Pos) == 1
        if Thr_Pos
            %only 1 given then take this as a coefficient - i.e. 0.5 is full
            %width half max. 0.3 is full width third max etc.
            Thr_Pos = [(1-abs(Thr_Pos))*MaxPos, MaxPos];
        else
            Thr_Pos = [0 0];
        end
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

%do camera flag - dont write the command if we dont want it
DoCamera = 0;

if exist('CameraStr','var') == 0 || isempty(CameraStr)
    DoCamera =0;
else
    %if its not a string then ignore it
    if ~ischar(CameraStr)
        CameraStr='';
    end
    
    %check if string entered is a camera file ending in .pvcc
    
    [Cam_root,Cam_name,Cam_ext] = fileparts(CameraStr);
    
    if strcmp(Cam_ext,'.pvcc') % load file if camera path given
        
        DoCamera = 2; % set flag to load file value
        
        %make sure the path is absolute
        javaFileObj = java.io.File(CameraStr);
        
        if ~javaFileObj.isAbsolute()
            CameraStr = fullfile(pwd,CameraStr);
        end
        
        %get the (possibly) updated new file name
        [Cam_root,Cam_name,Cam_ext] = fileparts(CameraStr);
        Camera_path_str = fullfile(Cam_root,[Cam_name Cam_ext]);
        fprintf('Loading camera file : %s\n',Camera_path_str);
        
        %make it linux/python friendly
        Camera_path_str = strrep(Camera_path_str,'\','/');
        
    elseif ismember(lower(CameraStr), legit_camera) %check if input is legit
        CameraStr=lower(CameraStr);
        %added this as I forgot the correct format after 10 minutes of
        %writing this
        if strcmp(CameraStr(1),'+')
            CameraStr(1)=[];
        end
        DoCamera =1;
        
    else
        fprintf(2,'Didnt understand camera direction, ignoring. Must end with .pvcc to use camera file.\n');
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
        
        if UsingHexes
            writeVTKcell_hex(vtk_path{iStep},MeshStruc.Hex,MeshStruc.Nodes,Data(:,iStep),Cmap_name);
        else
            writeVTKcell(vtk_path{iStep},MeshStruc.Tetra,MeshStruc.Nodes,Data(:,iStep),Cmap_name);
        end
        
    end
    fprintf('done\n');
end

%% Check Animation

DoAnimation =1;

if exist('AnimationVTKSavePath','var') == 0 || isempty(AnimationVTKSavePath)
    DoAnimation = 0;
    AnimationVTKSavePath='';
end
%set default frame rate, this is meaningless for pngs by themselves
if exist('FrameRate','var') == 0 || isempty(FrameRate)
    FrameRate = 10;
end

if DoAnimation
    
    % make path absolute if not given as such
    javaFileObj = java.io.File(AnimationVTKSavePath);
    
    if ~javaFileObj.isAbsolute()
        AnimationVTKSavePath = fullfile(pwd,AnimationVTKSavePath);
    end
    
    % make output a png if not given otherwise
    [AnimationSave_root,AnimationSave_name,AnimationSave_ext] = fileparts(AnimationVTKSavePath);
    if isempty(AnimationSave_ext)
        AnimationSave_ext='.png';
        fprintf(2,'NO FILETYPE GIVEN FOR OUTPUT. Using .png\n');
    end
    
    %make a pythony path string
    animation_path_str = fullfile(AnimationSave_root,[AnimationSave_name AnimationSave_ext]);
    fprintf('Saving output to file(s) : %s\n',animation_path_str);
    %adjust path string again to make paraview happy
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
fprintf(fid,'ShowData.ShowThresholdData(Data, Cmap, Thr_Neg, Thr_Pos, Cmap_title, Bkg_Op)\n');

%change camera if we want to
if DoCamera == 1 %% using default view
    fprintf(fid,'ShowData.SetCamera(Data, ''%s'')\n',CameraStr);
elseif DoCamera == 2 % using a file previously saved
    fprintf(fid,'ShowData.LoadCameraFile(''%s'')\n',Camera_path_str);
end

%create animation if we want to
if DoAnimation
    fprintf(fid,'ShowData.SaveAnimation(''%s'', %d)\n',animation_path_str,FrameRate);
    fprintf(fid,'ShowData.SaveGif(''%s'', %d)\n',animation_path_str,FrameRate);
    fprintf(fid,'ShowData.SaveVideo(''%s'', %d)\n',animation_path_str,FrameRate);
end

fprintf(fid,'\n');

fclose(fid);

%% call paraview with this new script

fprintf('Opening Paraview...\n');
cmdstr=sprintf('paraview --script="%s" &',script_path);

[status, cmdout] = system(cmdstr,'-echo');


end

