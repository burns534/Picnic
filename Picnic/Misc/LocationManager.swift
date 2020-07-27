//
//  LocationManager.swift
//  Picnic
//
//  Created by Kyle Burns on 7/27/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

class LocationManager: CLLocationManager {
    override init() {
        super.init()
        setup()
    }
    
    func setup() {
        requestAlwaysAuthorization()
        startUpdatingLocation()
        desiredAccuracy = kCLLocationAccuracyBest
    }
}

