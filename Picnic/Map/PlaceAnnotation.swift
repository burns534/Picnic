//
//  PlaceAnnotation.swift
//  Picnic
//
//  Created by Kyle Burns on 6/10/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    
    @objc dynamic var coordinate: CLLocationCoordinate2D // ??
    
    var title: String?
    var url: URL?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
