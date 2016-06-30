#### import the simple module from the paraview
from paraview.simple import *
#### disable automatic camera reset on 'Show'
paraview.simple._DisableFirstRenderCameraReset()



import os
os.getcwd()
print os.getcwd()

#### Variables, which will be read from text file
import example_settings

### THE ACTUAL CODE

# create a new 'Legacy VTK Reader'
Data = LegacyVTKReader(FileNames=[example_settings.VTK_Filenames])
RenameSource('Data', Data)

# get active view
renderView1 = GetActiveViewOrCreate('RenderView')

# show data in view
Data_Display_Background = Show(Data, renderView1)

# show color bar/color legend
Data_Display_Background.SetScalarBarVisibility(renderView1, True)

#### SET DEFAULT COLORMAPS AND STUFF

# get color transfer function/color map for 'u'
uLUT = GetColorTransferFunction(Cmap_name)
uLUT.RGBPoints = [-1, 0.231373, 0.298039, 0.752941, 0, 0.865003, 0.865003, 0.865003, 1, 0.705882, 0.0156863, 0.14902]
uLUT.ScalarRangeInitialized = 1.0

# get opacity transfer function/opacity map for 'u'
uPWF = GetOpacityTransferFunction(Cmap_name)
uPWF.Points = [-1, 0.0, 0.5, 0.0, 1, 1.0, 0.5, 0.0]
uPWF.ScalarRangeInitialized = 1

#### CHANGE SCALE TO DATA

# Rescale transfer function
uLUT.RescaleTransferFunction(Cmap_min, Cmap_max)

# Rescale transfer function
uPWF.RescaleTransferFunction(Cmap_min, Cmap_max)

### RENAME STUFF

# get color legend/bar for uLUT in view renderView1
uLUTColorBar = GetScalarBar(uLUT, renderView1)

# Properties modified on uLUTColorBar
uLUTColorBar.Title = Cmap_title

#### CREATE THRESHOLDS

if Do_Neg_Thres:

    # create a new 'Threshold'
    Negative_Threshold = Threshold(Input=Data)

    # Properties modified on threshold1
    Negative_Threshold.ThresholdRange = [Threshold_Neg_Min, Threshold_Neg_Max]

    # show data in view
    Negative_Threshold_Display = Show(Negative_Threshold, renderView1)

    # show color bar/color legend
    Negative_Threshold_Display.SetScalarBarVisibility(renderView1, True)

    #Rename it to something nicer
    RenameSource('Negative_Threshold', Negative_Threshold)


if Do_Pos_Thres:

    # create a new 'Threshold'
    Positive_Threshold = Threshold(Input=Data)

    # Properties modified on threshold1
    Positive_Threshold.ThresholdRange = [Threshold_Pos_Min, Threshold_Pos_Max]

    # show data in view
    Positive_Threshold_Display = Show(Positive_Threshold, renderView1)

    # show color bar/color legend
    Positive_Threshold_Display.SetScalarBarVisibility(renderView1, True)
    # Rename it to something nicer
    RenameSource('Positive_Threshold', Positive_Threshold)

### MAKE BACKGROUND TRANSPARENT

# turn off scalar coloring
ColorBy(Data_Display_Background, None)

# Properties modified on p_seq9_1_22vtkDisplay
Data_Display_Background.Opacity = Background_Opacity

# reset view to fit data
renderView1.ResetCamera()

Render()