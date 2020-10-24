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
    internal init(uid: String, name: String, userDescription: String, tags: TagContainer? = nil, imageNames: [String]? = nil, totalRating: Int, ratingCount: Int, wouldVisit: Int, visitCount: Int, coordinate: CLLocationCoordinate2D, city: String? = nil, state: String? = nil, park: String? = nil) {
        self.uid = uid
        self.name = name
        self.userDescription = userDescription
        self.tags = tags
        self.imageNames = imageNames
        self.totalRating = totalRating
        self.ratingCount = ratingCount
        self.rating = Double(totalRating) / Double(ratingCount)
        self.wouldVisit = wouldVisit
        self.visitCount = visitCount
        self.coordinates = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.city = city
        self.state = state
        self.park = park
        self.geohash = Region(coordinate: coordinate).hash
    }
    
    @DocumentID var id: String?
    var uid: String
    var name: String
    var userDescription: String
    var tags: TagContainer?
    var imageNames: [String]?
    var totalRating: Int
    var ratingCount: Int
    var rating: Double
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
        Picnic(uid: "", name: "", userDescription: "", totalRating: 0, ratingCount: 0, wouldVisit: 0, visitCount: 0, coordinate: CLLocationCoordinate2D())
    }
    var coordinate: CLLocationCoordinate2D {
        get {
            CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        }
        set {
            coordinates = GeoPoint(latitude: newValue.latitude, longitude: newValue.longitude)
            geohash = Region(coordinate: coordinate).hash
        }
    }
    
    var location: CLLocation {
        CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
}
