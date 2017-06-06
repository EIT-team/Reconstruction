import os
import csv
from paraview.simple import *
import xml.etree.ElementTree as ET


def ShowThresholdData(Data, ColourMapRange = None, NegativeThresholdValues = None, PositiveThresholdValues = None, ColourMapLegend = 'Sigma', BackgroundOpacityValue = 0.1, ScalarBarPos = None):

    ##### DEFAULTS
    DefaultColorMap = 0
    DefaultSclarBarPosition = 0

    # get data range, used in a few places
    DataRange = Data.CellData[0].GetRange(0)
    print "Data range : " + str(DataRange)

    # check if we should do negative or positive thresholds

    if NegativeThresholdValues is None:

        print "Using Default Negative Threshold"
        Do_Neg_Thres = True
        NegativeThresholdValues = [DataRange[0], DataRange[0]/2]
    else:
        Do_Neg_Thres = any(NegativeThresholdValues)

    if PositiveThresholdValues is None:

        print "Using Default Positive Threshold"
        Do_Pos_Thres = True
        PositiveThresholdValues = [DataRange[1]/2, DataRange[1]]
    else:
        Do_Pos_Thres = any(PositiveThresholdValues)


    #### CHECK INPUTS

    if ScalarBarPos == None:
        print "Using Default ScalarBar Position"
        DefaultSclarBarPosition = 1

    if ColourMapRange == None:
        DefaultColorMap = 1
        print "Using default colormaps"

        DataMax = round(max(abs(i) for i in DataRange))

        print "Data max : " + str(DataMax)

        ColourMapRange = [-DataMax, DataMax]

    ### ACTUAL CODE

    #### disable automatic camera reset on 'Show'
    paraview.simple._DisableFirstRenderCameraReset()

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

    if not DefaultSclarBarPosition:
        scalarbar = GetScalarBar(uLUT)
        scalarbar.Position = ScalarBarPos

    # reset view to fit data
    renderView1.ResetCamera()

    # Make it create the scene
    Render()

    # Get the animation time steps - this does nothing if only 1 file loaded

    # get animation scene
    animationScene1 = GetAnimationScene()

    # update animation scene based on data timesteps
    animationScene1.UpdateAnimationUsingDataTimeSteps()


def ShowSliceData(Data, DirectionString, Centre = None, ColourMapRange = None, ColourMapLegend = 'SigmaProbably', ScalarBarPos = None):

    #### DEFAULTS

    DefaultCentre = 0
    DefaultColorMap = 0
    DefaultSclarBarPosition = 0
    SliceNormal = [0.0, 0.0, 0.0]

    #### CHECK INPUTS

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

    if ScalarBarPos == None:
        print "Using Default ScalarBar Position"
        DefaultSclarBarPosition = 1



    ###### CODE STARTS HERE

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

    ### RENAME STUFF

    print "Setting colourmap legend text to : " + ColourMapLegend

    # reset view to fit data
    renderView1.ResetCamera()

    # show color bar/color legend
    Data_Display.SetScalarBarVisibility(renderView1, True)

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

    if DefaultColorMap == 1:

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


    # get color legend/bar for uLUT in view renderView1
    uLUTColorBar = GetScalarBar(uLUT, renderView1)

    # Properties modified on uLUTColorBar
    uLUTColorBar.Title = ColourMapLegend

    if not DefaultSclarBarPosition:
        scalarbar = GetScalarBar(uLUT)
        scalarbar.Position = ScalarBarPos


    # reset view to fit data
    renderView1.ResetCamera()
    Render()
    # Get the animation time steps - this does nothing if only 1 file loaded

    # get animation scene
    animationScene1 = GetAnimationScene()
    # update animation scene based on data timesteps
    animationScene1.UpdateAnimationUsingDataTimeSteps()


def ShowSphere(Centre, Radius = None, Name = 'ExPosition'):

    if Radius is None:
        Radius = 5

    sphere1 = Sphere()
    sphere1.Center = Centre
    sphere1.Radius = Radius

    # Properties modified on sphere1
    sphere1.ThetaResolution = 16
    sphere1.PhiResolution = 16

    RenameSource(Name, sphere1)

    renderView1 = GetActiveViewOrCreate('RenderView')
    # show data in view
    sphere1Display = Show(sphere1, renderView1)
    # reset view to fit data
    renderView1.ResetCamera()

    Render()


def ShowSphereCSV(CSVfile, Radius = None, TimePoint = None, Name_prefix = None):
    # show a spehere based on position in a csv file
    # convert to absolute path
    CSVfile = os.path.abspath(CSVfile)


    if TimePoint is None:
        animationScene1 = GetAnimationScene()
        TimePoint = int(animationScene1.AnimationTime)
        print "Timepoint from Animation step value is: " + str(TimePoint)
    else:
        print "User Set timepoint " + str(TimePoint)

    if Name_prefix is None:
        Name_prefix = 'ExPos_'

    # read the specific line from the csv file
    Centre = [0.0, 0.0, 0.0]
    count = 0
    with open(CSVfile) as f:
        r = csv.reader(f)
        for row in r:
            #print "Current row :" + str(row)
            if count == TimePoint:
                #print "found it"
                Centre = [float(i) for i in row]
                break
            count += 1

    print "Pos is now : " + str(Centre)

    # make sphere with this centre
    ShowSphere(Centre, Radius, Name_prefix + str(TimePoint))


def ShowSphereCSVClip(Data,CSVfile, Radius = None, Name = None):

    CSVfile = ConvertFilenames(CSVfile)

    CSVfile = CSVfile.replace('\\', '/')

    print "filename is " + str(CSVfile)

    if Radius is None:
        Radius = 5

    if Name is None:
        Name = 'IdealPosition'

    # create a new 'Programmable Filter'
    programmableFilter1 = ProgrammableFilter(Input=Data)
    RenameSource(Name, programmableFilter1)
    programmableFilter1.RequestInformationScript = ''
    programmableFilter1.RequestUpdateExtentScript = ''
    programmableFilter1.PythonPath = ''

    # Properties modified on programmableFilter1
    programmableFilter1.Script = 'csvfilename = \'' + CSVfile + '\'\nimport vtk\nimport csv\ninput = self.GetInputDataObject(0, 0)\noutput = self.GetOutputDataObject(0)\n\nt = self.GetInputDataObject(0,0).GetInformation().Get(vtk.vtkDataObject.DATA_TIME_STEP())\nTimePoint  = int(t)\n    # read the specific line from the csv file\nCentre = [0.0, 0.0, 0.0]\ncount = 0\n\nwith open(csvfilename) as f:\n    r = csv.reader(f)\n    for row in r:\n    #print "Current row :" + str(row)\n        if count == TimePoint:\n    #    print "found it"\n            Centre = [float(i) for i in row]\n            break\n        count += 1\n\n    #print "Pos is now : " + str(Centre)\n\n\ns = vtk.vtkSphere()\ns.SetCenter(Centre)\ns.SetRadius(' + str(Radius) + ')\n\nclip = vtk.vtkClipDataSet()\nclip.SetInputDataObject(input)\nclip.SetClipFunction(s)\nclip.SetValue(0.0)\nclip.InsideOutOn()\nclip.Update()\n#print clip\n\noutput.ShallowCopy(clip.GetOutputDataObject(0))\n'

    # get active view
    renderView1 = GetActiveViewOrCreate('RenderView')
    # show data in view
    programmableFilter1Display = Show(programmableFilter1, renderView1)

    # turn off scalar coloring
    ColorBy(programmableFilter1Display, None)

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
    # for fine tuning, not having this as input at the moment as there is already too many
    config_camZoom = 1.0
    cam = GetActiveCamera()
    cam.Zoom(config_camZoom)
    print "Position after camera reset : " + str(camPos)


def ConvertFilenames(Filenames_input):

    if type(Filenames_input) == list:
        full_filenames = Filenames_input
        for iName in range(len(Filenames_input)):
            # print iName
            full_filenames[iName] = os.path.abspath(Filenames_input[iName])
        print full_filenames
    else:
        full_filenames = os.path.abspath(Filenames_input)

    return full_filenames


def SaveAnimation(OutputFilename, FrameRateVal, MagnificationVal = 1.0, OrientationAxisVisible = 0):
    # Ensure output in correct format

    view = GetRenderView()
    view.OrientationAxesVisibility = OrientationAxisVisible
    Render()

    OutputFilename=ConvertFilenames(OutputFilename)
    # Create file based on magnification and FrameRate
    WriteAnimation(OutputFilename, Magnification=MagnificationVal, FrameRate=FrameRateVal, Compression=True)
    view.ResetCamera()
    Render()
    # Make it create the scene
    Render()

def SaveGif(PngName, FrameRate):

    # graphicsmagick uses "ticks" of 10ms when making gif, so we need to convert from frame rate to this
    gif_delay = int(round((1.0 / FrameRate) * 100.0, 0))  # rounding to nearest int

    # get the full path of where the pngs have been saved
    fullpath_out = ConvertFilenames(PngName)

    path_out = os.path.dirname(fullpath_out)

    filename = os.path.splitext(os.path.basename(fullpath_out))[0]

    # paraview names all the files like example.0001.png etc. so we need the glob string to get this: example*.png

    glob_string = os.path.join(path_out, filename) + "*.png"

    gif_string =  os.path.join(path_out, filename) + ".gif"

    # create string
    graphicsmagick_string = "gm convert -delay " + str(gif_delay) + " " + glob_string + " " + gif_string

    print "Making Gif using string: "
    print graphicsmagick_string
    os.system(graphicsmagick_string)  # make the .gif

def SaveVideo(PngName, FrameRate):

    # get the full path of where the pngs have been saved
    fullpath_out = ConvertFilenames(PngName)

    path_out = os.path.dirname(fullpath_out)

    filename = os.path.splitext(os.path.basename(fullpath_out))[0]

    # paraview names all the files like example.0001.png etc. ffmpeg needs a c-like formatting like example.0%3d.png as globbing only works on linux

    list_string = os.path.join(path_out, filename) + ".%4d.png"

    mp4_string = os.path.join(path_out, filename) + ".mp4"

    # -c:v libx264 makes sure it works on older players
    # -vf \"fps=25,format=yuv420p\" specifies a 25fps frame rate anyway - this makes it smooth for slower frame rates and fixes bugs with first frames and stuff
    # -y auto yesses to overwritting files etc.


    ffmpeg_string = "ffmpeg -framerate " + str(FrameRate) + " -i " + list_string + " -c:v libx264 -vf \"fps=25,format=yuv420p\" " + " " + mp4_string + " -y"
    print "Making Video using string: "
    print ffmpeg_string
    os.system(ffmpeg_string)
