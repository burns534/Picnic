//
//  Picnic.swift
//  Picnic
//
//  Created by Kyle Burns on 5/22/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation
import MapKit

// working object
struct Picnic: Identifiable, Codable {
    var name: String
    var userDescription: String
    var category: String
    var city: String
    var state: String
    var imageNames: [String]
    var rating: Float
    var ratingCount: Int
    var id: String
    var park: String!
    var wouldVisit: Int
    var didVisit: Int
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    fileprivate var coordinates: Coordinates
    
    init() {
        self.init(name: "loading", userDescription: "", category: "", state: "", coordinates: .init(latitude: 0, longitude: 0), isFeatured: false, isLiked: false, isFavorite: false, park: "", imageNames: ["loading"], rating: 5.0, ratingCount: 0, city: "", didVisit: 0, wouldVisit: 0)
    }
    
    init(fromDictionary dict: [String: Any]) {
        name = dict["name"] as? String ?? ""
        userDescription = dict["userDescription"] as? String ?? ""
        category = dict["category"] as? String ?? ""
        state = dict["state"] as? String ?? ""
        imageNames = dict["imageNames"] as? [String] ?? ["loading"]
        id = dict["key"] as? String ?? ""
        rating = (dict["rating"] as? NSNumber)?.floatValue ?? 0.0
        ratingCount = dict["ratingCount"] as? Int ?? 0
        let safeLat = dict["latitude"] as? Double ?? 0.0
        let safeLong = dict["longitude"] as? Double ?? 0.0
        coordinates = Coordinates(latitude: safeLat, longitude: safeLong)
        park = ""
        wouldVisit = dict["wouldVisit"] as? Int ?? 0 // probably won't use this
        didVisit = dict["didVisit"] as? Int ?? 0
        city = dict["city"] as? String ?? ""
    }
    
    init(name: String, userDescription: String, category: String, state: String, coordinates: CLLocationCoordinate2D, isFeatured: Bool, isLiked: Bool, isFavorite: Bool, park: String, imageNames: [String], rating: Float, ratingCount: Int, city: String, didVisit: Int = 0, wouldVisit: Int = 0, id: String = UUID().uuidString) {
        self.name = name
        self.userDescription = userDescription
        self.category = category
        self.state = state
        self.coordinates = Coordinates(latitude: coordinates.latitude, longitude: coordinates.longitude)
        self.id = id
        self.park = park
        self.imageNames = imageNames
        self.rating = rating
        self.ratingCount = ratingCount
        self.didVisit = didVisit
        self.wouldVisit = wouldVisit
        self.city = city
    }
}


struct Coordinates: Hashable, Codable {
    var latitude: Double
    var longitude: Double
}
