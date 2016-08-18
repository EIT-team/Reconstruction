# Using this library

*ADD THE PARAVIEW FOLDER AND THIS FOLDER TO THE PATH*.

Tested with Matlab 2015 and Paraview >4.3

Examples of what the path variable in windows should look like can be found in the **docs** folder.

You should be able to call `paraview` from the command line. Sort that out first

## Errors...
I find the best way to view the errors, is not through the initial window which paraview pops up, but through the python shell. I have tried to make the output verbose enough to see whats going on.

Things are a little hard to debug as I couldnt get a normal python IDE to find all of the libraries which paraview can find, specifically `LegacyVTKReader`. So I could only run the code through invoking paraview from the command line as below.


## Example scripts
The scripts in this folder are designed to be called from the command line in the following
manner.

`paraview --script="load_test_single.py"  &`

Each of them show a different element of the python library, e.g. showing thresholds,
slices and placing spheres in the ideal locations

## Extending these
From these functions it should be possible to create recipes to do more complicated things,
like use a finer mesh as the background, show slices in different viewports etc.
