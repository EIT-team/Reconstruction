# This code is heavily influenced by (stolen from) http://comments.gmane.org/gmane.comp.science.paraview.user/15091

from paraview.simple import *
from ParaviewLoad import ShowData

Cmap_title = 'The stuff'

Cmap = [-100, 100]
Thr_Neg =[-100, -50]
Thr_Pos =[25, 40]
Bkg_Op = 0.1
VTK_Filenames = 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_22.vtk'

#VTK_Filenames = 'C:\\Users\\James\\Neonate2016\\Parallel\\Recon\\arm\\output\\plastic_seq4_1_53.vtk'

#VTKnames='E:/Neonate2016/Parallel/Recon/arm_new/output/p_seq9_1_22.vtk'
#VTK_Filenames=os.path.abspath(VTKnames)

Data = LegacyVTKReader(FileNames=[VTK_Filenames])

ShowData.ShowThresholdData(Data, Cmap, Thr_Neg, Thr_Pos, Cmap_title, Bkg_Op)

ShowData.SetCamera(Data, 'x')
