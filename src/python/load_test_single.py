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
#VTK_Filenames = 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_22.vtk'

VTKnames = '../../resources/vtks/nn1.vtk'

#VTKnames='E:/Neonate2016/Parallel/Recon/arm_new/output/p_seq9_1_22.vtk'
VTK_Filenames=ShowData.ConvertFilenames(VTKnames)

Data = LegacyVTKReader(FileNames=[VTK_Filenames])

ShowData.ShowThresholdData(Data, Cmap, Thr_Neg, Thr_Pos, Cmap_name, Cmap_title, Bkg_Op)

