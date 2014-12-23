ISO8601Duration
===============


This category converts ISO 8601 duration strings with the format: P[n]Y[n]M[n]DT[n]H[n]M[n]S or P[n]W into date components.  
Ex. PT12H = 12 hours  
Ex. P3D = 3 days  
Ex. P3DT12H = 3 days, 12 hours  
Ex. P3Y6M4DT12H30M5S = 3 years, 6 months, 4 days, 12 hours, 30 minutes and 5 seconds  
Ex. P10W = 70 days  
For more information look here http://en.wikipedia.org/wiki/ISO_8601#Durations  
WARNING: The specification allows decimal values which this category does not support. Pull requests are welcome.  

Usage
=====
Objective-C  
```Objective-C
NSString *durationString = @"P3Y6M4DT12H30M5S";
NSDateComponents *components = [NSDateComponents durationFrom8601String:durationString];
```

Swift  
```Swift
var durationString = "P3Y6M4DT12H30M5S"
var components = NSDateComponents.durationFrom8601String(durationString)
```
