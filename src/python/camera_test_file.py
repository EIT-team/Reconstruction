# This code is heavily influenced by (stolen from) http://comments.gmane.org/gmane.comp.science.paraview.user/15091
# add https://www.mail-archive.com/paraview@paraview.org/msg20341.html to that list!


#from paraview.simple import *
#from ParaviewLoad import ShowData

import xml.etree.ElementTree as ET
import os

Cmap_name = 'u'
Cmap_title = 'The stuff'

Cmap = [-100, 100]
Thr_Neg =[-100, -50]
Thr_Pos =[25, 40]
Bkg_Op = 0.1

VTKnames = ['../../resources/vtk/nn1.vtk']

#VTK_Filenames = ShowData.ConvertFilenames(VTKnames)

CameraFileName = '../../resources/vtk/iso.pvcc'
CameraFileNameAbs = os.path.abspath(CameraFileName)



pos =[0.0,0.0,0.0]
foc = [0.0,0.0,0.0]
viewup = [0.0,0.0,0.0]
parallelscale = 0.0

tree = ET.parse(CameraFileNameAbs)
root = tree.getroot()

for child in root[0]:
    if child.attrib['name'] == 'CameraPosition':
        for subChild in child:
            pos[int(subChild.attrib['index'])] = float(subChild.attrib['value'])
    if child.attrib['name'] == 'CameraViewUp':
        for subChild in child:
            viewup[ int(subChild.attrib['index'])] = float(subChild.attrib['value'])
    if child.attrib['name'] == 'CameraParallelScale':
        parallelscale = float(child[0].attrib['value'])
    if child.attrib['name'] == 'CameraFocalPoint':
        for subChild in child:
            foc[int(subChild.attrib['index'])] = float(subChild.attrib['value'])


print "pos is now: " + str(pos)

print "viewup is now: " + str(viewup)
print "foc is now: " + str(foc)

print "parallelscale is now: " + str(parallelscale)

#Data = LegacyVTKReader(FileNames=VTK_Filenames)

#ShowData.ShowThresholdData(Data, Cmap, Thr_Neg, Thr_Pos, Cmap_name, Cmap_title, Bkg_Op)

#ShowData.SetCamera(Data, 'z')


# ganesh
# import xml.etree.ElementTree as ET
# from numpy import *
# from scipy import interpolate
#
#
# class animateParaviewCamera:
#     timeList = empty(0)
#     positionSplrep = []
#     viewUpSplrep = []
#     parallelScaleSplrep = 0
#     position = empty((2, 3))
#     viewUp = empty((2, 3))
#     parallelScale = empty(2)
#
#     def __init__(self, t, f):
#         self.timeList = t
#         fileNames = f
#         #        self.timeList = arange(0.3,0.8,0.005)
#         #        fileNames = ['camera1.pvcc','camera2.pvcc','camera3.pvcc','camera4.pvcc']
#         nPositions = len(fileNames)
#         interpTime = linspace(self.timeList[0], self.timeList[-1], nPositions)
#         print interpTime
#
#         self.position = empty((nPositions, 3))
#         self.viewUp = empty((nPositions, 3))
#         self.parallelScale = empty(nPositions)
#
#         for i in range(nPositions):
#             tree = ET.parse(fileNames[i])
#             root = tree.getroot()
#             for child in root[0]:
#                 if child.attrib['name'] == 'CameraPosition':
#                     for subChild in child:
#                         self.position[i, int(subChild.attrib['index'])] = float(subChild.attrib['value'])
#                 if child.attrib['name'] == 'CameraViewUp':
#                     for subChild in child:
#                         self.viewUp[i, int(subChild.attrib['index'])] = float(subChild.attrib['value'])
#                 if child.attrib['name'] == 'CameraParallelScale':
#                     self.parallelScale[i] = float(child[0].attrib['value'])
#
#         print self.position
#
#         for i in range(3):
#             self.positionSplrep.append(interpolate.splrep(interpTime, self.position[:, i], k=1))
#             self.viewUpSplrep.append(interpolate.splrep(interpTime, self.viewUp[:, i], k=1))
#         self.parallelScaleSplrep = interpolate.splrep(interpTime, self.parallelScale)
#
#     def cameraPosition(self, t):
#         if (t < self.timeList[0]):
#             return self.position[0].tolist()
#         elif (t < self.timeList[-1]):
#             return [interpolate.splev(t, self.positionSplrep[0]), interpolate.splev(t, self.positionSplrep[1]),
#                     interpolate.splev(t, self.positionSplrep[2])]
#         else:
#             return self.position[-1].tolist()
#
#     def cameraViewUp(self, t):
#         if (t < self.timeList[0]):
#             return self.viewUp[0].tolist()
#         elif (t < self.timeList[-1]):
#             return [interpolate.splev(t, self.viewUpSplrep[0]), interpolate.splev(t, self.viewUpSplrep[1]),
#                     interpolate.splev(t, self.viewUpSplrep[2])]
#         else:
#             return self.viewUp[-1].tolist()
#
#     def cameraParallelScale(self, t):
#         if (t < self.timeList[0]):
#             return self.parallelScale[0]
#         elif (t < self.timeList[-1]):
#             return interpolate.splev(t, self.parallelScaleSplrep)
#         else:
#             return self.parallelScale[0]
#
#
# if __name__ == "__main__":
#     timeList = arange(0.3, 0.8, 0.005)
#     fileNames = ['camera1.pvcc', 'camera2.pvcc', 'camera3.pvcc', 'camera4.pvcc']
#     a = animateParaviewCamera(array([0.4, 0.6]), fileNames)
#     for i in range(size(timeList)):
#         print a.cameraPosition(timeList[i])


# current camera placement for renderView1
# renderView1.InteractionMode = '2D'
# renderView1.CameraPosition = [-199.2377805132849, -323.94508579821644, 584.5306993833535]
# renderView1.CameraFocalPoint = [-39.27677948151911, -138.17245103934732, 510.07681070226056]
# renderView1.CameraViewUp = [0.27201457316923106, 0.14692534371214605, 0.9510105232638747]
# renderView1.CameraParallelScale = 93.90978640184404