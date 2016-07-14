#### import the simple module from the paraview

import os
from paraview.simple import *
from ParaviewLoad import ShowData
import csv

Cmap_title = 'The stuff'

Cmap = [-100, 100]
Thr_Neg = [-100, -50]
Thr_Pos = [20, 40]
Bkg_Op = 0.1

VTKnames = ['../../resources/vtk/nn1.vtk', '../../resources/vtk/nn2.vtk', '../../resources/vtk/nn3.vtk', '../../resources/vtk/nn4.vtk', '../../resources/vtk/nn5.vtk']

#VTK_Filenames = ShowData.ConvertFilenames(VTKnames)

#Data = LegacyVTKReader(FileNames=VTK_Filenames)

#ShowData.ShowThresholdData(Data)

#ShowData.ShowThresholdData(Data, Cmap, Thr_Neg, Thr_Pos)

csvfilename = '../../resources/vtk/testpos.csv'

ShowData.ShowSphereCSV(csvfilename, TimePoint= 4)




# csvfilename= os.path.abspath(csvfilename)
#
# animationScene1 = GetAnimationScene()
# target = int(animationScene1.AnimationTime)
# print "Target value is: " + str(target)
#
# pos = [0.0, 0.0, 0.0]
# count=0
# with open(csvfilename) as f:
#     r = csv.reader(f)
#     for row in r:
#         print "Current row :" + str(row)
#         if count == target:
#             print "found it"
#             pos = [float(i) for i in row]
#             break
#         count += 1
#
#
# print "Pos is now : " + str(pos)
#
# sphere1 = Sphere()
# sphere1.Center = pos
# sphere1.Radius = 5
#
# # Properties modified on sphere1
# sphere1.ThetaResolution = 16
# sphere1.PhiResolution = 16
#
# #RenameSource(Name, sphere1)
#
# renderView1 = GetActiveViewOrCreate('RenderView')
# # show data in view
# sphere1Display = Show(sphere1, renderView1)
# # reset view to fit data
# renderView1.ResetCamera()
#
# Render()
