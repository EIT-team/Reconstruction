#### import the simple module from the paraview

import os
from paraview.simple import *
from ParaviewLoad import ShowData

Cmap_name = 'u'
Cmap_title = 'The stuff'

Cmap = [-100, 100]
Thr_Neg = [-100, -50]
Thr_Pos = [20, 40]
Bkg_Op = 0.1

VTKnames = ['../../resources/vtk/nn1.vtk', '../../resources/vtk/nn2.vtk', '../../resources/vtk/nn3.vtk', '../../resources/vtk/nn4.vtk', '../../resources/vtk/nn5.vtk']

VTK_Filenames = ShowData.ConvertFilenames(VTKnames)

Data = LegacyVTKReader(FileNames=VTK_Filenames)

ShowData.ShowThresholdData(Data, Cmap, Thr_Neg, Thr_Pos, Cmap_name, Cmap_title, Bkg_Op)
