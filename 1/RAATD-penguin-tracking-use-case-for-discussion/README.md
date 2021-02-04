This is a use case on how to convert the RAATD dataset (here a subset of 29 individuals) to Darwin Core Event core with Occurrence extension. An event was defined as the capture and following of an individual. Occurrences are the actual data points of the track. In the Event core file, we added a polygon (footprintWKT) based on one location per day to show a rough outline of the track.

The `RAATD_to_EventCore.R` file contains the code used to format the data into the files here shown. All details on how exactly the data was formatted can be found there.

Full dataset derived from the raw data (not included here) can be found at https://ipt.biodiversity.aq/resource?r=scar_raatd_trackingdata
