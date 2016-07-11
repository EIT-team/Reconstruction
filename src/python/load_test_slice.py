#### import the simple module from the paraview

import os
from paraview.simple import *
from ParaviewLoad import ShowData

ColourMapName = 'u'
Cmap_title = 'The stuff'

ColourMapRange = [-10, 10]
Thr_Neg = [-100, -50]
Thr_Pos = [20, 40]
Bkg_Op = 0.1

VTKnames = ['../../resources/vtk/nn1.vtk']
#VTKnames = ['E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_1.vtk']


VTK_Filenames = ShowData.ConvertFilenames(VTKnames)

Data = LegacyVTKReader(FileNames=VTK_Filenames)

#ShowData.ShowThresholdData(Data, Cmap, Thr_Neg, Thr_Pos, Cmap_name, Cmap_title, Bkg_Op)

# create a new 'Legacy VTK Reader'
RenameSource('Data', Data)

# get active view
renderView1 = GetActiveViewOrCreate('RenderView')

# get color transfer function/color map for 'u'
# uLUT = GetColorTransferFunction('u')

# show data in view
Data_Display = Show(Data, renderView1)
Render()

uLUT = GetColorTransferFunction(ColourMapName)
uLUT.RGBPoints = [-1, 0.231373, 0.298039, 0.752941, 0, 0.865003, 0.865003, 0.865003, 1, 0.705882, 0.0156863, 0.14902]
uLUT.ScalarRangeInitialized = 1.0

# get opacity transfer function/opacity map for ColourMapName
uPWF = GetOpacityTransferFunction(ColourMapName)
uPWF.Points = [-1, 0.0, 0.5, 0.0, 1, 1.0, 0.5, 0.0]
uPWF.ScalarRangeInitialized = 1

#### CHANGE SCALE TO DATA

# Rescale transfer function
uLUT.RescaleTransferFunction(ColourMapRange[0], ColourMapRange[1])

# Rescale transfer function
uPWF.RescaleTransferFunction(ColourMapRange[0], ColourMapRange[1])

# reset view to fit data
renderView1.ResetCamera()

# show color bar/color legend
Data_Display.SetScalarBarVisibility(renderView1, True)

# get opacity transfer function/opacity map for 'u'
uPWF = GetOpacityTransferFunction(ColourMapName)

bounds = Data.GetDataInformation().GetBounds()

print str(bounds)

bounds_dx = bounds[1] - bounds[0]
bounds_dy = bounds[3] - bounds[2]
bounds_dz = bounds[5] - bounds[4]
bounds_cx = (bounds[0] + bounds[1]) / 2.0
bounds_cy = (bounds[2] + bounds[3]) / 2.0
bounds_cz = (bounds[4] + bounds[5]) / 2.0

print str(bounds_cx) + str(bounds_cy) + str(bounds_cz)

# create a new 'Slice'
slice1 = Slice(Input=Data)
slice1.SliceType = 'Plane'
slice1.SliceOffsetValues = [0.0]

# init the 'Plane' selected for 'SliceType'
slice1.SliceType.Origin = [bounds_cx, bounds_cy, bounds_cz]

print str(slice1.SliceType.Origin)

#
# # Properties modified on slice1.SliceType
slice1.SliceType.Normal = [0.0, 0.0, 1.0]
#
# # show data in view
slice1Display = Show(slice1, renderView1)
# # trace defaults for the display properties.
slice1Display.ColorArrayName = ['CELLS', ColourMapName]
slice1Display.LookupTable = uLUT
# # slice1Display.GlyphType = 'Arrow'
# # slice1Display.SetScaleArray = [None, '']
# # slice1Display.ScaleTransferFunction = 'PiecewiseFunction'
# slice1Display.OpacityArray = [None, '']
# slice1Display.OpacityTransferFunction = 'PiecewiseFunction'

# hide data in view
Hide(Data, renderView1)

# set active source to get rid of the stuff in the
SetActiveSource(Data)
ShowData.SetCamera(Data, 'z')

# Rescale transfer function
#uLUT.RescaleTransferFunction(ColourMapRange[0], ColourMapRange[1])
# Rescale transfer function
#uPWF.RescaleTransferFunction(ColourMapRange[0], ColourMapRange[1])

SliceRange = slice1.CellData[0].GetRange(0)

print "Data range : " + str(SliceRange)

SliceMax = round(max(abs(i) for i in SliceRange))

print "Data max : " + str(SliceMax)

uLUT.RescaleTransferFunction(-SliceMax, SliceMax)
uPWF.RescaleTransferFunction(-SliceMax, SliceMax)


# reset view to fit data
renderView1.ResetCamera()
Render()