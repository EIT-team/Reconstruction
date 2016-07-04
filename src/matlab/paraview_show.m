function [ output_args ] = paraview_show( DataToShow,SaveDir )
%PARAVIEW_SHOW Summary of this function goes here
%   Detailed explanation goes here

% need to check if this format 
vtk_name='C:\\Users\\James\\Neonate2016\\Parallel\\Recon\\arm\\output\\plastic_seq4_1_53.vtk';

script_name=[pwd '\temp\test.py'];

% writeVTKcell_hex

%% Get variables to write

%check if passed or calculate
Cmap_name = 'u';
Cmap_title = 'The stuff';

Cmap = [-100, 100];
Thr_Neg =[-100, -50];
Thr_Pos =[25, 40];
Bkg_Op = 0.1;

%% Write python script

fid=fopen(script_name,'w+');

%imports
fprintf(fid,'from paraview.simple import *\n')
fprintf(fid,'from ParaviewLoad import ShowData\n');
% variables
fprintf(fid,'Cmap_name = ''%s'' \n', Cmap_name);
fprintf(fid,'Cmap_title = ''%s'' \n', Cmap_title);
fprintf(fid,'Cmap = [%d, %d]\n', Cmap(1),Cmap(2));
fprintf(fid,'Thr_Neg = [%d, %d]\n', Thr_Neg(1),Thr_Neg(2));
fprintf(fid,'Thr_Pos = [%d, %d]\n', Thr_Pos(1),Thr_Pos(2));
fprintf(fid,'Bkg_Op = %.1f \n', Bkg_Op);

%filenames
fprintf(fid,'VTK_Filenames = ''%s '' \n', vtk_name);

%load the data
fprintf(fid,'Data = LegacyVTKReader(FileNames=[VTK_Filenames])\n');

%showdata
fprintf(fid,'ShowData.ShowThresholdData(Data, Cmap, Thr_Neg, Thr_Pos, Cmap_name, Cmap_title, Bkg_Op)');

fclose(fid);

%% call paraview with this new script

cmdstr=sprintf('paraview --script=%s &',script_name);

[status, cmdout] = system(cmdstr,'-echo');


end

