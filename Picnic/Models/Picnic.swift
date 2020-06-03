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
    var imageName: String
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
        self.init(name: "loading", userDescription: "", category: "", state: "", coordinates: .init(latitude: 0, longitude: 0), isFeatured: false, isLiked: false, isFavorite: false, park: "", imageName: "loading", rating: 5.0)
    }
    
    init(fromDictionary dict: [String: Any]) {
        if let safeName = dict["name"] as? String,
            let safeUserDescription = dict["userDescription"] as? String,
            let safeCategory = dict["category"] as? String,
            let safeState = dict["state"] as? String,
            let safeLat = dict["latitude"] as? Double,
            let safeLong = dict["longitude"] as? Double,
            let safeImageName = dict["imageName"] as? String,
            let id = dict["key"] as? String,
            let safeRating = (dict["rating"] as? NSNumber)?.floatValue {
            
            let safeCoordinates = Coordinates(latitude: safeLat, longitude: safeLong)
            self.init(name: safeName, userDescription: safeUserDescription, category: safeCategory, state: safeState, coordinates: safeCoordinates, isFeatured: false, isLiked: false, isFavorite: false, park: "", imageName: safeImageName, rating: safeRating, id: id)
        } else {
            print("Error: Picnic: init: fromDictionary: Could not initialize")
            self.init()
        }
    }
    
    init(name: String, userDescription: String, category: String, state: String, coordinates: Coordinates, isFeatured: Bool, isLiked: Bool, isFavorite: Bool, park: String, imageName: String, rating: Float, id: String? = nil) {
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
        self.imageName = imageName
        self.rating = rating
    }
}


struct Coordinates: Hashable, Codable {
    var latitude: Double
    var longitude: Double
}
