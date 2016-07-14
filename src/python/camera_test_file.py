# This code is heavily influenced by (stolen from) http://comments.gmane.org/gmane.comp.science.paraview.user/15091
# add https://www.mail-archive.com/paraview@paraview.org/msg20341.html to that list!

from paraview.simple import *
from ParaviewLoad import ShowData

Cmap_title = 'The stuff'

Cmap = [-100, 100]
Thr_Neg =[-100, -50]
Thr_Pos =[25, 40]
Bkg_Op = 0.1

VTKnames = ['../../resources/vtk/nn1.vtk']

VTK_Filenames = ShowData.ConvertFilenames(VTKnames)

CameraFileName = '../../resources/vtk/iso.pvcc'

Data = LegacyVTKReader(FileNames=VTK_Filenames)

ShowData.ShowThresholdData(Data, Cmap, Thr_Neg, Thr_Pos, Cmap_title, Bkg_Op)

ShowData.LoadCameraFile(CameraFileName)
