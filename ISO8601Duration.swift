//
//  ISO8601Duration.swift
//  ISO8601Duration
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Kevin Randrup
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

/*
 * This extension converts ISO 8601 duration strings with the format: P[n]Y[n]M[n]DT[n]H[n]M[n]S or P[n]W into date components.
 * Ex. PT12H = 12 hours
 * Ex. P3D = 3 days
 * Ex. P3DT12H = 3 days, 12 hours
 * Ex. P3Y6M4DT12H30M5S = 3 years, 6 months, 4 days, 12 hours, 30 minutes and 5 seconds
 * Ex. P10W = 70 days
 * For more information look here http://en.wikipedia.org/wiki/ISO_8601#Durations
 * WARNING: The specification allows decimal values which this category does not support. Pull requests are welcome.
 */
extension NSDateComponents {
    //Note: Does not handle decimal values or overflow values
    
    //Format: PnYnMnDTnHnMnS or PnW
    class func durationFrom8601String(durationString: String) -> NSDateComponents {
        let timeDesignator = NSCharacterSet(charactersInString:"HMS")
        let periodDesignator = NSCharacterSet(charactersInString:"YMD")
        
        var dateComponents = NSDateComponents()
        var mutableDurationString = durationString.mutableCopy() as NSMutableString
        
        let pRange = mutableDurationString.rangeOfString("P")
        if pRange.location == NSNotFound {
            self.logErrorMessage(durationString)
            return dateComponents;
        } else {
            mutableDurationString.deleteCharactersInRange(pRange)
        }
        
        
        if (durationString.rangeOfString("W") != nil) {
            var weekValues = componentsForString(mutableDurationString, designatorSet: NSCharacterSet(charactersInString: "W"))
            var weekValue: NSString? = weekValues["W"]
            if (weekValue != nil) {
                 //7 day week specified in ISO 8601 standard
                dateComponents.day = Int(weekValue!.doubleValue * 7.0)
            }
            return dateComponents
        }
        
        let tRange = mutableDurationString.rangeOfString("T", options: .LiteralSearch)
        var periodString = ""
        var timeString = ""
        if tRange.location == NSNotFound {
            periodString = mutableDurationString
            
        } else {
            periodString = mutableDurationString.substringToIndex(tRange.location)
            timeString = mutableDurationString.substringFromIndex(tRange.location + 1)
        }
        
        //DnMnYn
        var periodValues = componentsForString(periodString, designatorSet: periodDesignator)
        for (key, obj) in periodValues {
            var value = (obj as NSString).integerValue
            if key == "D" {
                dateComponents.day = value
            } else if key == "M" {
                dateComponents.month = value
            } else if key == "Y" {
                dateComponents.year = value
            }
        }
        
        //SnMnHn
        var timeValues = componentsForString(timeString, designatorSet: timeDesignator)
        for (key, obj) in timeValues {
            var value = (obj as NSString).integerValue
            if key == "S" {
                dateComponents.second = value
            } else if key == "M" {
                dateComponents.minute = value
            } else if key == "H" {
                dateComponents.hour = value
            }
        }
        return dateComponents
    }
    
    class func componentsForString(string: String, designatorSet: NSCharacterSet) -> Dictionary<String, String> {
        var str = string as NSString
        if countElements(string) == 0 {
            return Dictionary()
        }
        let numericalSet = NSCharacterSet.decimalDigitCharacterSet()
        string.componentsSeparatedByCharactersInSet(designatorSet)
        var componentValues = (string.componentsSeparatedByCharactersInSet(designatorSet) as NSArray).mutableCopy() as NSMutableArray
        var designatorValues = (string.componentsSeparatedByCharactersInSet(numericalSet) as NSArray).mutableCopy() as NSMutableArray
        componentValues.removeObject("")
        designatorValues.removeObject("")
        if componentValues.count == designatorValues.count {
            var dictionary = Dictionary<String, String>(minimumCapacity: componentValues.count)
            for (var i = 0; i < componentValues.count; i++) {
                var key = designatorValues[i] as String
                var value = componentValues[i] as String
                dictionary[key] = value
            }
            return dictionary
        } else {
            println("String: \(string) has an invalid formal.")
        }
        return Dictionary()
    }
    
    class func logErrorMessage(durationString: String) {
        println("String: \(durationString) has an invalid format.")
        println("The durationString must have a format of PnYnMnDTnHnMnS or PnW.")
    }
}