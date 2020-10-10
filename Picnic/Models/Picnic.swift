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

enum PicnicTag: String, Codable {
    case empty
}

struct Picnic: Codable, Identifiable {
    init(name: String = "", userDescription: String = "", tags: [PicnicTag]? = nil, imageNames: [String]? = nil, totalRating: Double = 0.0, ratingCount: Int = 0, wouldVisit: Int = 0, visitCount: Int = 0, reviews: [DocumentReference]? = nil, latitude: Double = 0.0, longitude: Double = 0.0, city: String? = nil, state: String? = nil, park: String? = nil) {
        self.name = name
        self.userDescription = userDescription
        self.tags = tags
        self.imageNames = imageNames
        self.totalRating = totalRating
        self.ratingCount = ratingCount
        self.wouldVisit = wouldVisit
        self.visitCount = visitCount
        self.reviews = reviews
        self.coordinates = GeoPoint(latitude: latitude, longitude: longitude)
        self.city = city
        self.state = state
        self.park = park
        self.geohash = Region(latitude: latitude, longitude: longitude, precision: kDefaultPrecision).hash
    }
    
    @DocumentID var id: String?
    var name: String = ""
    var userDescription: String = ""
    var tags: [PicnicTag]?
    var imageNames: [String]?
    var totalRating: Double = 0.0
    var ratingCount: Int = 0
    var wouldVisit: Int = 0
    var visitCount: Int = 0
    var reviews: [DocumentReference]?
// MARK: Location Data
    var coordinates: GeoPoint
    var city: String?
    var state: String?
    var park: String?
    var geohash: String = Region(latitude: 0, longitude: 0, precision: kDefaultPrecision).hash
}
