This is a use case on how to convert the RAATD dataset (here a subset of 29 individuals) to DarwinCore EventCore wth occurrence extension. An event was defined as the capture and following of an individual. Occurrences are the actual data points of the track. In the EventCore file, we added a polygon (footprintWKT) based on one location per day to show a rough outline of the track.

The RAATD_to_EventCore.R file contains the code used to format the data into the files here shown.
