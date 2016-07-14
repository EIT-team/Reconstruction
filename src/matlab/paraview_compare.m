function [ status ] = paraview_compare( MeshHex,MeshNodes,Data,CentreToCompare,Radius,ReuseVTK,VTKSavePath,Thr_Neg,Thr_Pos,Cmap,Cmap_title,CameraStr,AnimationSavePath,FrameRate)
%PARAVIEW_SHOW Display data in paraview, along with a sphere in the
%expected position, useful for checking reconstructions

%Creates loading script and call
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
% CentreToCompare - [x,y,z] coords of positions you wish to compare to.
% Rows must equal timesteps, or a single row given, which is duplicated for
% all timesteps given
% Radius - 
% ReuseVTK - Flag to save VTKs or not. 0 or empty saves them. 1 resuses
% them if they exist, throws error if they dont
% VTKSavePath - Path to save the VTK and Python script, temp folder used if
% not. Can be relative or absolute path. doesnt have to end in .vtk
% Thr_Neg - Threshold to use for negative values. Give either 2 values
% [-100 -50], or a single value as a coefficient of max. i.e. giving a value
% of .1 shows top 10%. If not given full width half max used. set to [0,0]
% to disable.
% Thr_Pos - As above but with positive values
% Cmap - colour map range to use, i.e. [-100 100]. If empty -/+ max range is
% used
% Cmap_title - Text above colourbar
% CameraStr - set camera to (-/+) X Y or Z directions with a single string
% i.e. 'x' or '-y' like the GUI in paraview. Or load a camera file, must
% end with '.pvcc', i.e. '/iso.pvcc'. Copes with relative or absolute paths

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

%number of files
NumSteps = size(Data,2);
TimeSteps=1:NumSteps;

if exist('CentreToCompare','var') == 0 || isempty(CentreToCompare)
    error('No comparison positions given');
else
    if size(CentreToCompare,2) == 3
        
        if size(CentreToCompare,1) == 1
            CentreToCompare = repmat(CentreToCompare,NumSteps,1);
        elseif size(CentreToCompare,1) ~= NumSteps
            error('Number of positions dont match timesteps. Use 1 or NumSteps');
        end
        
        fprintf('Comparing to centre(s) : [%.2f,%.2f,%.2f]...\n',CentreToCompare(1,1),CentreToCompare(1,2),CentreToCompare(1,3));
    else
        error('Dont understand centre to compare input');
    end
end

if exist('Radius','var') == 0 || isempty(Radius)
    fprintf('Using default radius of 5mm\n');
    DoRadius = 0;
    Radius=5; %but we just dont set it as use python default
else
    if ~isnumeric(Radius)
        error('Dont understand radius');
    end
    DoRadius =1;
end


%% Check where we are saving the data to
%shove it in the temp dir

temp_dir=[fileparts(mfilename('fullpath')) filesep 'temp'];
temp_vtk_name = 'test';
temp_script_name = 'test.py';
temp_positioncsv_name = 'testpositions.csv';

if exist('SavePath','var') == 0 || isempty(VTKSavePath)
    
    fprintf('Saving vtkdata in temp directory\n');
    %if none given use temp directory in recon repo -  this is set to be
    %ignored by temp. so we good
    script_path= [temp_dir filesep temp_script_name];
    csv_path = [temp_dir filesep temp_positioncsv_name];
    
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
    csv_path = fullfile(Save_root,[Save_name '.csv']);
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
csv_path_python = strrep(csv_path,'\','/');

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

if isempty(MaxNeg)
    MaxNeg =0; % functions below dont like empty values. so set to zero
end

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

if isempty(MaxPos)
    MaxPos =0; % functions below dont like empty values. so set to zero
end

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
%% save positions to CSV file

%these positions are loaded by python script.
dlmwrite(csv_path,CentreToCompare);



%% Write python script

%this is hacky as fuck and I dont like it. But it works.
%this could be avoided if you could pass arguments to the python script

fid=fopen(script_path,'w+');

%imports
fprintf(fid,'import os\n');
fprintf(fid,'from paraview.simple import *\n');
fprintf(fid,'from ParaviewLoad import ShowData\n');
% variables

fprintf(fid,'CSVpath = ''%s'' \n',csv_path_python);
fprintf(fid,'Centre = [%.2f, %.2f, %.2f]\n', CentreToCompare(1),CentreToCompare(2),CentreToCompare(3));

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


%use single function if just one given

if NumSteps == 1
    
    %create sphere object
    fprintf(fid,'ShowData.ShowSphere(Centre');
    
    if DoRadius
        fprintf(fid,', Radius=%.2f ',Radius);
    end
    fprintf(fid,')\n');
else
    
    fprintf(fid,'ShowData.ShowSphereCSVClip(Data, CSVpath');
    if DoRadius
        fprintf(fid,', Radius=%.2f ',Radius);
    end
    fprintf(fid,')\n');
end


%change camera if we want to
if DoCamera == 1 %% using default view
    fprintf(fid,'ShowData.SetCamera(Data, ''%s'')\n',CameraStr);
elseif DoCamera == 2 % using a file previously saved
    fprintf(fid,'ShowData.LoadCameraFile(''%s'')\n',Camera_path_str);
end


if DoAnimation
    fprintf(fid,'ShowData.SaveAnimation(''%s'', %d)',animation_path_str,FrameRate);
end

fprintf(fid,'\n');

fclose(fid);

%% call paraview with this new script

cmdstr=sprintf('paraview --script=%s &',script_path);

[status, cmdout] = system(cmdstr,'-echo');


end

