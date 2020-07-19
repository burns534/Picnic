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
    var state: String
    var imageNames: [String]
    var rating: Float
    var id: String
    var isFeatured: Bool
    var isLiked: Bool
    var isFavorite: Bool
    var park: String
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    fileprivate var coordinates: Coordinates
    
    init() {
        self.init(name: "loading", userDescription: "", category: "", state: "", coordinates: .init(latitude: 0, longitude: 0), isFeatured: false, isLiked: false, isFavorite: false, park: "", imageNames: ["loading"], rating: 5.0)
    }
    
    init(fromDictionary dict: [String: Any]) {
        let safeName = dict["name"] as? String ?? ""
        let safeUserDescription = dict["userDescription"] as? String ?? ""
        let safeCategory = dict["category"] as? String ?? ""
        let safeState = dict["state"] as? String ?? ""
        let safeLat = dict["latitude"] as? Double ?? 0.0
        let safeLong = dict["longitude"] as? Double ?? 0.0
        let safeImageNames = dict["imageNames"] as? [String] ?? ["loading"]
        let id = dict["key"] as? String ?? ""
        let safeRating = (dict["rating"] as? NSNumber)?.floatValue ?? 0.0
        
        let safeCoordinates = Coordinates(latitude: safeLat, longitude: safeLong)
        self.init(name: safeName, userDescription: safeUserDescription, category: safeCategory, state: safeState, coordinates: safeCoordinates, isFeatured: false, isLiked: false, isFavorite: false, park: "", imageNames: safeImageNames, rating: safeRating, id: id)
    }
    
    init(name: String, userDescription: String, category: String, state: String, coordinates: Coordinates, isFeatured: Bool, isLiked: Bool, isFavorite: Bool, park: String, imageNames: [String], rating: Float, id: String? = nil) {
        self.name = name
        self.userDescription = userDescription
        self.category = category
        self.state = state
        self.coordinates = coordinates
        if let id = id {
            self.id = id
        } else {
            self.id = UUID().uuidString
        }
        self.isFeatured = isFeatured
        self.isLiked = isLiked
        self.isFavorite = isFavorite
        self.park = park
        self.imageNames = imageNames
        self.rating = rating
    }
}


struct Coordinates: Hashable, Codable {
    var latitude: Double
    var longitude: Double
}
