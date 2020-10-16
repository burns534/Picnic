//
//  Picnic.swift
//  Picnic
//
//  Created by Kyle Burns on 5/22/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Picnic: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var name: String
    var userDescription: String
    var tags: [PicnicTag]?
    var imageNames: [String]?
    var totalRating: Double
    var ratingCount: Int
    var wouldVisit: Int
    var visitCount: Int
// MARK: Location Data
    var coordinates: GeoPoint
    var city: String?
    var state: String?
    var park: String?
    var geohash: String
}

extension Picnic {
    static var empty: Picnic {
        Picnic(id: nil, uid: "", name: "", userDescription: "", tags: nil, imageNames: nil, totalRating: 0, ratingCount: 0, wouldVisit: 0, visitCount: 0, coordinates: GeoPoint(latitude: 0, longitude: 0), city: nil, state: nil, park: nil, geohash: "")
    }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    
    var location: CLLocation {
        CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    
    var rating: Double {
        totalRating / Double(ratingCount)
    }
}
