#### import the simple module from the paraview
from paraview.simple import *
#### disable automatic camera reset on 'Show'
paraview.simple._DisableFirstRenderCameraReset()

# create a new 'Legacy VTK Reader'
p_seq9_1_ = LegacyVTKReader(FileNames=['E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_1.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_2.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_3.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_4.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_5.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_6.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_7.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_8.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_9.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_10.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_11.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_12.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_13.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_14.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_15.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_16.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_17.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_18.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_19.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_20.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_21.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_22.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_23.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_24.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_25.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_26.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_27.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_28.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_29.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_30.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_31.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_32.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_33.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_34.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_35.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_36.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_37.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_38.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_39.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_40.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_41.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_42.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_43.vtk', 'E:\\Neonate2016\\Parallel\\Recon\\arm_new\\output\\p_seq9_1_44.vtk'])

# get active view
renderView1 = GetActiveViewOrCreate('RenderView')
# uncomment following to set a specific view size
# renderView1.ViewSize = [1027, 813]

# get color transfer function/color map for 'u'
uLUT = GetColorTransferFunction('u')
uLUT.RGBPoints = [-4.891801834106445, 0.231373, 0.298039, 0.752941, 0.6285815238952637, 0.865003, 0.865003, 0.865003, 6.148964881896973, 0.705882, 0.0156863, 0.14902]
uLUT.ScalarRangeInitialized = 1.0

# get opacity transfer function/opacity map for 'u'
uPWF = GetOpacityTransferFunction('u')
uPWF.Points = [-4.891801834106445, 0.0, 0.5, 0.0, 6.148964881896973, 1.0, 0.5, 0.0]
uPWF.ScalarRangeInitialized = 1

# get animation scene
animationScene1 = GetAnimationScene()

# update animation scene based on data timesteps
animationScene1.UpdateAnimationUsingDataTimeSteps()

# create a new 'Programmable Filter'
programmableFilter1 = ProgrammableFilter(Input=p_seq9_1_)
programmableFilter1.Script = '#Negative Range\n\nfrom vtk import vtkThreshold\n\ninput = self.GetInputDataObject(0, 0)\noutput = self.GetOutputDataObject(0)\n\n#Get min/max values\naa = inputs[0].CellData\nai = aa[0]\nRange = ai.GetRange(0)\n\n#Define threshold filter\nthresh = vtkThreshold()\n\nthresh.SetInputData(input)\n\nminthres= -10\n\ncurrent_thres = min(Range[0]/2,minthres)\n\n#Set threshold to half min\nthresh.ThresholdBetween(Range[0],min(Range[0]/2,-6))\nthresh.Update()\n\noutput.ShallowCopy(thresh.GetOutput())\n\nprint "current thres : " + str(current_thres)\n'
programmableFilter1.RequestInformationScript = ''
programmableFilter1.RequestUpdateExtentScript = ''
programmableFilter1.PythonPath = ''

# show data in view
programmableFilter1Display = Show(programmableFilter1, renderView1)
# trace defaults for the display properties.
programmableFilter1Display.ColorArrayName = [None, '']
programmableFilter1Display.GlyphType = 'Arrow'
programmableFilter1Display.SetScaleArray = [None, '']
programmableFilter1Display.ScaleTransferFunction = 'PiecewiseFunction'
programmableFilter1Display.OpacityArray = [None, '']
programmableFilter1Display.OpacityTransferFunction = 'PiecewiseFunction'

# hide data in view
Hide(p_seq9_1_, renderView1)

# set scalar coloring
ColorBy(programmableFilter1Display, ('CELLS', 'u'))

# rescale color and/or opacity maps used to include current data range
programmableFilter1Display.RescaleTransferFunctionToDataRange(True)

# show color bar/color legend
programmableFilter1Display.SetScalarBarVisibility(renderView1, True)

# Rescale transfer function
uLUT.RescaleTransferFunction(-90.0, 90.0)

# Rescale transfer function
uPWF.RescaleTransferFunction(-90.0, 90.0)

# set active source
SetActiveSource(p_seq9_1_)

# show data in view
p_seq9_1_Display = Show(p_seq9_1_, renderView1)
# trace defaults for the display properties.
p_seq9_1_Display.ColorArrayName = ['CELLS', 'u']
p_seq9_1_Display.LookupTable = uLUT
p_seq9_1_Display.GlyphType = 'Arrow'
p_seq9_1_Display.ScalarOpacityUnitDistance = 3.8536924687683096
p_seq9_1_Display.SetScaleArray = [None, '']
p_seq9_1_Display.ScaleTransferFunction = 'PiecewiseFunction'
p_seq9_1_Display.OpacityArray = [None, '']
p_seq9_1_Display.OpacityTransferFunction = 'PiecewiseFunction'

# show color bar/color legend
p_seq9_1_Display.SetScalarBarVisibility(renderView1, True)

# turn off scalar coloring
ColorBy(p_seq9_1_Display, None)

# Properties modified on p_seq9_1_Display
p_seq9_1_Display.Opacity = 0.5

# Properties modified on p_seq9_1_Display
p_seq9_1_Display.Opacity = 0.1

# set active source
SetActiveSource(p_seq9_1_)

# reset view to fit data
renderView1.ResetCamera()

# current camera placement for renderView1
renderView1.CameraPosition = [-27.2829288555997, -377.192507893986, 471.156165170165]
renderView1.CameraFocalPoint = [-29.4656162449247, -125.786722522305, 522.837938533767]
renderView1.CameraViewUp = [0.24377672090518004, -0.19325461544460407, 0.9503817990439822]
renderView1.CameraParallelScale = 97.0865603405332

# current camera placement for renderView1
renderView1.CameraPosition = [-27.2829288555997, -377.192507893986, 471.156165170165]
renderView1.CameraFocalPoint = [-29.4656162449247, -125.786722522305, 522.837938533767]
renderView1.CameraViewUp = [0.24377672090518004, -0.19325461544460407, 0.9503817990439822]
renderView1.CameraParallelScale = 97.0865603405332

# save animation images/movie
WriteAnimation('E:/Neonate2016/Parallel/Recon/arm_new/output/loveyou.png', Magnification=1, FrameRate=5.0, Compression=True)