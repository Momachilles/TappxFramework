//
//  TappxLocationManager.swift
//  TappxFramework
//
//  Created by David Alarcon on 27/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import UIKit
import CoreLocation

class TappxLocationManager: NSObject {
    var manager: CLLocationManager = CLLocationManager()
    var lastPosition: (latitude: Double, longitude: Double)?
    var lastPositionDate: NSDate?
    
    func startLocation() {
        self.manager.delegate = self
    }
    
    deinit {
        self.manager.stopMonitoringSignificantLocationChanges()
    }
    
}

extension TappxLocationManager: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if CLLocationManager.locationServicesEnabled() {
            switch status {
            case .NotDetermined, .Restricted, .Denied:
                print("Location Manager not accessible)")
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                self.manager.startMonitoringSignificantLocationChanges()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location : \(locations.last)")
        
        if let location = locations.last {
            self.lastPosition = (latitude: Double(location.coordinate.latitude), longitude: Double(location.coordinate.longitude))
            self.lastPositionDate = NSDate()
        }
    }
    
}
