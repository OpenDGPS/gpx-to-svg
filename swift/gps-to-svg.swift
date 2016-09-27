//
//  main.swift
//  gpx-to-svg
//
//  Created by OpenDGPS on 27.09.16.
//  Copyright © 2016 OpenDGPS.
//

import Foundation

let y_width = 19900.0 as Float32
let x_width = 13500.0 as Float32


/**
Get the scaled values for lat and lon
 
 - Parameter el    : XMLElement of a trackpoint
 - Returns : a tuple of two Float32.
 */
func appendPoint(el : XMLElement) -> String {
    let latitude = (el.attr("lat")! as NSString).floatValue
    let longitude = (el.attr("lon")! as NSString).floatValue
    return "\(latitude) \(longitude),"
}

func mappedLatitude(lat : Float32) -> Float32 {
    return (((180 - (lat + 90)) / 180) * y_width);
}

func mappedLongitude(lon : Float32) -> Float32 {
    if (lon < 0) {
        return (((180 + (180 - abs(lon))) / 360) * x_width);
    } else {
        return ((lon / 360) * x_width);
    }
};

let filePath = ((#file as NSString).stringByDeletingLastPathComponent as NSString).stringByAppendingPathComponent("1k.gpx")
do {
    var path = "M"

    let latitude_root = 46.9877911 as Float32
    let longitude_root = 7.131336 as Float32

    let mappedLatRoot = mappedLatitude(latitude_root)
    let mappedLonRoot = mappedLongitude(longitude_root)

    let data = NSData(contentsOfFile: filePath)!
    let document = try XMLDocument(data: data)
    if let root = document.root {
        // instead of simple //trkpt because Fuzzi doesn't know emptry prefixes
        var xpath = "//*[name() = 'trkpt']";
        var lastMappedLatitude = mappedLatitude((document.xpath(xpath)[0]!.attr("lat")! as NSString).floatValue)
        var lastMappedLongitude = mappedLongitude((document.xpath(xpath)[0]!.attr("lon")! as NSString).floatValue)
        path = path + "l\(lastMappedLongitude - mappedLonRoot),\(lastMappedLatitude - mappedLatRoot)"
        for element in document.xpath(xpath) {
            path =
                path
                + "l\(mappedLongitude((element.attr("lon")! as NSString).floatValue) - lastMappedLongitude),"
                + "\(mappedLatitude((element.attr("lat")! as NSString).floatValue) - lastMappedLatitude)"
            lastMappedLatitude = mappedLatitude((element.attr("lat")! as NSString).floatValue)
            lastMappedLongitude = mappedLongitude((element.attr("lon")! as NSString).floatValue)
        }
        print(path + "\n")
    }
} catch let error as XMLError {
    switch error {
    case .NoError: print("wth this should not appear")
    case .ParserFailure, .InvalidData: print(error)
    case .LibXMLError(let code, let message):
        print("libxml error code: \(code), message: \(message)")
    }
}
