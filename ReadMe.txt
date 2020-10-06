Interferometry profile code


Compile

Calls upon the required combination of the following functions in one script




Data prep

There are 4 different types of data prep functions:
	- standard (data_prep)
	- line (data_prepLine)
	- ave (data_prepAve)
	- rad (data_prepRad)

The required version will depend on what format the lateral dimension vs intensity data is in. For the standard version, there should be only one x column for the lateral dimension with all remaining columns containing intensity data for different images. 

The other versions (line, ave, rad) assume each image has been processed separately and so each image needs an x and y set of values. The ave version applies a smoothing function. 

*** Line and rad seem to be exactly the same ***




Max min

Identifies the points of maxima and minima as well as the stationary point corresponding to the dimple 

There are 5 different type of max min functions:
	- standard
	- drain
	- ave
	- line
	- intensity 


Standard: 
This function identifies the points of maxima and minima in the intensity
vs lateral dimension data using the findpeaks function. Sometimes noise in 
the data around the centre of interference pattern (smaller radius over 
which to average the data can be mistaken as a genuine maximum or minimum.
THIS VERSION of the MAX MIN code plots all of the intensity spectra on one 
figure and asks the user for a universal "cutoff" point along the lateral 
dimension and then excludes data up to this value from being included in 
the findpeaks identification 

Drain:
THIS VERSION of the MAX MIN code plots each of the intensity spectra individually 
and asks the user to identify a specific "cutoff" point along the lateral 
dimension for each plot and then excludes data up to this value from being included in 
the findpeaks identification

Average: 
Automatically identifies maxima and minima as well as the stationary point
corresponding to the dimple. The dimple is identified by first finding the
average distance between the stationary points and then finding the first
distance greater than some threshold (g. 5%) above the average

Line:
Same cutoff feature as the drain version except set up for data in cell form, 
which would be valid in the data has been prepared with line, ave or rad data prep functions


Intensity:
Seems to be exactly the same as the drain version... maybe made to play around with the min peak prominence value. 








Film thickness

There are 7 different type of film thickness functions:
	- standard
	- ave
	- line
	- rad
	- high res
	- V2
	- Aug 19

standard:
Scatters the intensity profile with identified peaks if required and asks the user for three inputs: 'is dimple present?', 'Identify index of dimple', 'Apparent max?' Using this input information the code then allocates a height according to the interferometry equation for separation between points of maxima and minima


Average:
Seems to be written to work with the max min average code


Line:
Seems to be written to work with data prep and max min line functions, ie each image has its own x & y 

Rad:
Includes a different user input 'Have all correct max/min been identified? Y/N [Y]: ' which is used to calculate a percentage of correctly identified stationary points

High res:
Includes more elaborate interferometry equation to achieve a higher resolution of points. Still in development

V2:
Includes more elaborate interferometry equation to achieve a higher resolution of points. Still in development

Aug 19:
Amends some poorly written code in the standard version (although same code is in all versions). Basically it removes some unnecessary for loops. 






Plot profile 

 


