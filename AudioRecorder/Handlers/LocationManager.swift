//
//  LocationManager.swift
//  AudioRecorder
//
//  Created by Igoryok on 27.11.2021.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    var lastRequestedLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lastRequestedLocation = location
            print("Requested location: \(location)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastRequestedLocation = nil
        print("Failed to find user's location: \(error)")
    }
}
