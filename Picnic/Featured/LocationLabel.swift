//
//  LocationLabel.swift
//  Picnic
//
//  Created by Kyle Burns on 5/30/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
import CoreLocation

class LocationLabel: UILabel {
    
    var location: CLLocationCoordinate2D!
    
    convenience init(location: CLLocationCoordinate2D) {
        self.init(frame: .zero)
        self.location = location
    }
    
    func configure() {
        let lat = location.latitude
        let long = location.longitude
        text = "\(lat), \(long)"
        self.textColor = .black
    }
    
    func configure(location: CLLocationCoordinate2D) {
        let lat = location.latitude
        let long = location.longitude
        text = String(format: "%.5f, %.5f", lat, long)
        self.textColor = .black
    }
    
}
