import os
from paraview.simple import *
import xml.etree.ElementTree as ET

def ShowThresholdData(Data, ColourMapRange, NegativeThresholdValues, PositiveThresholdValues,ColourMapLegend = 'SigmaIGuess',BackgroundOpacityValue = 0.1):

    #### disable automatic camera reset on 'Show'
    paraview.simple._DisableFirstRenderCameraReset()

    # check if we should do negative or positive thresholds

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

    # find the name of the array
    CellData = Data.CellData[0]
    ColourMapName = CellData.Name

    #### SET DEFAULT COLORMAPS AND STUFF

    print "Setting colourmap for data name: " + ColourMapName

    # get color transfer function/color map for ColourMapName
    # THIS IS THE DEFAULT PARAVIEW COLOURSCHEME WE KNOW AND LOVE
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

    ### DISPLAY DATA IN SCENE WITH TIMESTEPS

    # reset view to fit data
    renderView1.ResetCamera()

    # Make it create the scene
    Render()

    # Get the animation time steps - this does nothing if only 1 file loaded

    # get animation scene
    animationScene1 = GetAnimationScene()

    # update animation scene based on data timesteps
    animationScene1.UpdateAnimationUsingDataTimeSteps()


def ShowSliceData(Data, DirectionString, Centre = None, ColourMapRange = None):

    DefaultCentre = 0
    DefaultColorMap = 0
    SliceNormal = [0.0, 0.0, 0.0]

    if Centre == None:
        print "Using Default Centre"
        DefaultCentre = 1

    if ColourMapRange == None:
        DefaultColorMap = 1
        print "Using default colormaps"
        DataRange = Data.CellData[0].GetRange(0)

        print "Data range : " + str(DataRange)

        DataMax = round(max(abs(i) for i in DataRange))

        print "Data max : " + str(DataMax)

        ColourMapRange = [-DataMax, DataMax]

    LegitStrings = ['x', 'y', 'z']
    camDirection = 1

    DirectionString = DirectionString.lower()

    if DirectionString.startswith('-'):
        camDirection = -1
        DirectionString = DirectionString[1]
        #print "negative direction"

    if DirectionString in LegitStrings:
        dimIdx = LegitStrings.index(DirectionString)
        SliceNormal[dimIdx] = 1.0
    else:
        print "DONT UNDERSTAND INPUT"
        return

    # create a new 'Rename the Source something useful'
    RenameSource('Data', Data)

    # get active view
    renderView1 = GetActiveViewOrCreate('RenderView')

    # show data in view
    Data_Display = Show(Data, renderView1)
    Render()

    # find the name of the array
    CellData = Data.CellData[0]
    ColourMapName = CellData.Name

    print "ColourMapName data is: " + ColourMapName

    uLUT = GetColorTransferFunction(ColourMapName)
    uLUT.RGBPoints = [-1, 0.231373, 0.298039, 0.752941, 0, 0.865003, 0.865003, 0.865003, 1, 0.705882, 0.0156863,
                      0.14902]
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

    if DefaultCentre == 1:

        bounds = Data.GetDataInformation().GetBounds()

        bounds_dx = bounds[1] - bounds[0]
        bounds_dy = bounds[3] - bounds[2]
        bounds_dz = bounds[5] - bounds[4]
        bounds_cx = (bounds[0] + bounds[1]) / 2.0
        bounds_cy = (bounds[2] + bounds[3]) / 2.0
        bounds_cz = (bounds[4] + bounds[5]) / 2.0

        Centre = [bounds_cx, bounds_cy, bounds_cz]

    print "Centre of Slice :" + str(Centre)

    # create a new 'Slice'
    slice1 = Slice(Input=Data)
    slice1.SliceType = 'Plane'
    slice1.SliceOffsetValues = [0.0]

    # init the 'Plane' selected for 'SliceType'
    slice1.SliceType.Origin = Centre

    print "Slice Normal : " + str(SliceNormal)

    # set direction of slice
    slice1.SliceType.Normal = SliceNormal

    # # show data in view
    slice1Display = Show(slice1, renderView1)
    # # trace defaults for the display properties.
    slice1Display.ColorArrayName = ['CELLS', ColourMapName]
    slice1Display.LookupTable = uLUT

    # hide data in view
    Hide(Data, renderView1)

    # set active source to get rid of the stuff in the
    SetActiveSource(Data)

    if camDirection == -1:
        DirectionString  = '-' + DirectionString

    SetCamera(Data, DirectionString)

    if DefaultColorMap ==1:

        SliceRange = slice1.CellData[0].GetRange(0)

        print "Slice range : " + str(SliceRange)

        SliceMax = round(max(abs(i) for i in SliceRange))

        print "Slice max : " + str(SliceMax)

        uLUT.RescaleTransferFunction(-SliceMax, SliceMax)
        uPWF.RescaleTransferFunction(-SliceMax, SliceMax)
    else:
        # Rescale transfer function
        uLUT.RescaleTransferFunction(ColourMapRange[0], ColourMapRange[1])
        # Rescale transfer function
        uPWF.RescaleTransferFunction(ColourMapRange[0], ColourMapRange[1])

    # reset view to fit data
    renderView1.ResetCamera()
    Render()




def LoadCameraFile(CameraFilename):
    # heavily based on the code posted here https://www.mail-archive.com/paraview@paraview.org/msg20341.html

    # convert file name to absolute path in linuxy format
    CameraFileNameAbs = os.path.abspath(CameraFilename)

    print "Loading camera file : " + CameraFileNameAbs

    # initialise variables
    CamPosition = [0.0, 0.0, 0.0]
    CamFocus = [0.0, 0.0, 0.0]
    CamViewUp = [0.0, 0.0, 0.0]
    CamParallelScale = 0.0
    CamCentreofRot = [0.0, 0.0, 0.0]
    CamViewAngle = 0

    # use XML parser to read attributes in file
    tree = ET.parse(CameraFileNameAbs)
    root = tree.getroot()
    # get the attributes stored in the file
    for child in root[0]:
        if child.attrib['name'] == 'CameraPosition':
            for subChild in child:
                CamPosition[int(subChild.attrib['index'])] = float(subChild.attrib['value'])
        if child.attrib['name'] == 'CameraViewUp':
            for subChild in child:
                CamViewUp[int(subChild.attrib['index'])] = float(subChild.attrib['value'])
        if child.attrib['name'] == 'CameraParallelScale':
            CamParallelScale = float(child[0].attrib['value'])
        if child.attrib['name'] == 'CameraFocalPoint':
            for subChild in child:
                CamFocus[int(subChild.attrib['index'])] = float(subChild.attrib['value'])
        if child.attrib['name'] == 'CenterOfRotation':
            for subChild in child:
                CamCentreofRot[int(subChild.attrib['index'])] = float(subChild.attrib['value'])
        if child.attrib['name'] == 'CameraViewAngle':
            CamViewAngle = float(child[0].attrib['value'])

    print "CameraPosition is now: " + str(CamPosition)
    print "CameraViewUp is now: " + str(CamViewUp)
    print "CameraFocus: " + str(CamFocus)
    print "CameraParallelScale is now: " + str(CamParallelScale)
    print "CameraCentreOfRotation is now: " + str(CamCentreofRot)
    print "CameraViewAngle is now: " + str(CamViewAngle)

    # set the positions
    view = GetRenderView()
    view.CameraViewUp = CamViewUp
    view.CameraPosition = CamPosition
    view.CameraFocalPoint = CamFocus
    view.CameraParallelScale = CamParallelScale
    view.CenterOfRotation = CamCentreofRot
    view.CameraViewAngle = CamViewAngle


def SetCamera(Data, DirectionString):
    # This code is heavily influenced by (stolen from) http://comments.gmane.org/gmane.comp.science.paraview.user/15091

    LegitStrings = ['x', 'y', 'z']
    camDirection = 1

    DirectionString = DirectionString.lower()

    if DirectionString.startswith('-'):
        camDirection = -1
        DirectionString = DirectionString[1]
        print "negative direction"

    if DirectionString in LegitStrings:
        dimMode = LegitStrings.index(DirectionString)
    else:
        print "DONT UNDERSTAND INPUT"
        return

    bounds = Data.GetDataInformation().GetBounds()

    bounds_dx = bounds[1] - bounds[0]
    bounds_dy = bounds[3] - bounds[2]
    bounds_dz = bounds[5] - bounds[4]
    bounds_cx = (bounds[0] + bounds[1]) / 2.0
    bounds_cy = (bounds[2] + bounds[3]) / 2.0
    bounds_cz = (bounds[4] + bounds[5]) / 2.0


    #weird things were happening when the camera was still inside the mesh


    if dimMode == 2:
        # xy Z equivalent
        camUp = [0.0, 1.0, 0.0]
        #pos = max(bounds_dx, bounds_dy)
        pos = bounds_cz + camDirection * bounds_dz
        camPos = [bounds_cx, bounds_cy, pos]
        camFoc = [bounds_cx, bounds_cy, bounds_cz]

    elif dimMode == 1:
        # xz Y equivalent
        camUp = [0.0, 0.0, 1.0]
        # pos = 2* max(bounds_dx, bounds_dz) #make it twice as far away to ensure we are
        pos = bounds_cy + camDirection * bounds_dy
        camPos = [bounds_cx, pos, bounds_cz]
        camFoc = [bounds_cx, bounds_cy, bounds_cz]

    elif dimMode == 0:
        # yz - X equivalent
        camUp = [0.0, 0.0, 1.0]
        #pos = max(bounds_dy, bounds_dz)
        pos = bounds_cx + camDirection * bounds_dx
        camPos = [pos, bounds_cy, bounds_cz] # changed to match the GUI buttons
        camFoc = [bounds_cx, bounds_cy, bounds_cz]

    else:
        print "What?"

    # configure the view
    # width = 1024
    # height = int(width*aspect)
    print "Position set! : " + str(camPos)

    view = GetRenderView()
    view.CameraViewUp = camUp
    view.CameraPosition = camPos
    view.CameraFocalPoint = camFoc
    # view.UseOffscreenRenderingForScreenshots = 0
    # view.CenterAxesVisibility = 0
    # view.OrientationAxesVisibility = 0
    # view.ViewSize = [width, height]
    Render()
    view.ResetCamera()
    ResetCamera()
    # for fine tuning
    config_camZoom = 1.0
    cam = GetActiveCamera()
    cam.Zoom(config_camZoom)
    print "Position after camera reset : " + str(camPos)


def ConvertFilenames(Filenames_input):

    if type(Filenames_input) == list:
        VTK_Filenames = Filenames_input
        for iName in range(len(Filenames_input)):
            # print iName
            VTK_Filenames[iName] = os.path.abspath(Filenames_input[iName])
        print VTK_Filenames
    else:
        VTK_Filenames = os.path.abspath(Filenames_input)

    return VTK_Filenames


def SaveAnimation(OutputFilename,FrameRateVal,MagnificationVal = 1.0):
    # Ensure output in correct format
    OutputFilename=ConvertFilenames(OutputFilename)
    # Create file based on magnification and FrameRate
    WriteAnimation(OutputFilename, Magnification=MagnificationVal, FrameRate=FrameRateVal, Compression=True)