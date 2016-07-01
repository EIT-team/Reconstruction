
from paraview.simple import *

def ShowThresholdData(Data,ColourMapRange,NegativeThresholdValues,PositiveThresholdValues,ColourMapName,ColourMapLegend,BackgroundOpacityValue):
    #### disable automatic camera reset on 'Show'
    paraview.simple._DisableFirstRenderCameraReset()
    #check if we should do negative or positive thresholds

    Do_Neg_Thres = any(NegativeThresholdValues)
    Do_Pos_Thres = any(PositiveThresholdValues)

    # create a new 'Legacy VTK Reader'
    RenameSource('Data', Data)

    # get active view
    renderView1 = GetActiveViewOrCreate('RenderView')

    # show data in view
    Data_Display_Background = Show(Data, renderView1)

    # show color bar/color legend
    Data_Display_Background.SetScalarBarVisibility(renderView1, True)

    #### SET DEFAULT COLORMAPS AND STUFF

    print "Setting colourmap for data name: " + ColourMapName

    # get color transfer function/color map for 'u'
    uLUT = GetColorTransferFunction(ColourMapName)
    uLUT.RGBPoints = [-1, 0.231373, 0.298039, 0.752941, 0, 0.865003, 0.865003, 0.865003, 1, 0.705882, 0.0156863, 0.14902]
    uLUT.ScalarRangeInitialized = 1.0

    # get opacity transfer function/opacity map for 'u'
    uPWF = GetOpacityTransferFunction(ColourMapName)
    uPWF.Points = [-1, 0.0, 0.5, 0.0, 1, 1.0, 0.5, 0.0]
    uPWF.ScalarRangeInitialized = 1

    #### CHANGE SCALE TO DATA

    # Rescale transfer function
    uLUT.RescaleTransferFunction(ColourMapRange[0], ColourMapRange[1])

    # Rescale transfer function
    uPWF.RescaleTransferFunction(ColourMapRange[0], ColourMapRange[1])

    ### RENAME STUFF

    print "Setting colourmap legend text to : " + ColourMapLegend

    # get color legend/bar for uLUT in view renderView1
    uLUTColorBar = GetScalarBar(uLUT, renderView1)

    # Properties modified on uLUTColorBar
    uLUTColorBar.Title = ColourMapLegend

    #### CREATE THRESHOLDS

    if Do_Neg_Thres:

        print "Showing negative threshold with range :" + str(NegativeThresholdValues)

        # create a new 'Threshold'
        Negative_Threshold = Threshold(Input=Data)

        # Properties modified on threshold1
        Negative_Threshold.ThresholdRange = NegativeThresholdValues

        # show data in view
        Negative_Threshold_Display = Show(Negative_Threshold, renderView1)

        # show color bar/color legend
        Negative_Threshold_Display.SetScalarBarVisibility(renderView1, True)

        #Rename it to something nicer
        RenameSource('Negative_Threshold', Negative_Threshold)


    if Do_Pos_Thres:

        print "Showing positive threshold with range :" + str(PositiveThresholdValues)

        # create a new 'Threshold'
        Positive_Threshold = Threshold(Input=Data)

        # Properties modified on threshold1
        Positive_Threshold.ThresholdRange = PositiveThresholdValues

        # show data in view
        Positive_Threshold_Display = Show(Positive_Threshold, renderView1)

        # show color bar/color legend
        Positive_Threshold_Display.SetScalarBarVisibility(renderView1, True)
        # Rename it to something nicer
        RenameSource('Positive_Threshold', Positive_Threshold)

    ### MAKE BACKGROUND TRANSPARENT

    print "Showing background with opacity : " + str(BackgroundOpacityValue)

    # turn off scalar coloring
    ColorBy(Data_Display_Background, None)

    # Properties modified on p_seq9_1_22vtkDisplay
    Data_Display_Background.Opacity = BackgroundOpacityValue

    # reset view to fit data
    renderView1.ResetCamera()

    Render()