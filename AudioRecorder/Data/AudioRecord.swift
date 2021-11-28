//
//  AudioRecord.swift
//  AudioRecorder
//
//  Created by Igoryok on 29.09.2021.
//

import Foundation
import CoreLocation

struct AudioRecord: Codable {
    var NIL_COORDINATE: Double = -22222
    
    
    var filePath: String
    var createdAt: Date
    var locationLatitude: Double
    var locationLongitude: Double
    
    init(fileURL: URL, createdAt: Date, location: CLLocation?){
        self.filePath = fileURL.lastPathComponent
        self.createdAt = createdAt
        if let certainLocation = location {
            self.locationLatitude = certainLocation.coordinate.latitude
            self.locationLongitude = certainLocation.coordinate.longitude
        } else {
            self.locationLatitude = NIL_COORDINATE
            self.locationLongitude = NIL_COORDINATE
        }
    }
    
    var fileURL: URL {
        FileManager.getDocumentsDirectory().appendingPathComponent("AudioRecords").appendingPathComponent(filePath)
    }
    var location: CLLocation?  {
        CLLocation(latitude: locationLatitude, longitude: locationLongitude)
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.location {
            let geocoder = CLGeocoder()
                
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                 // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
}
