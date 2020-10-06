//
//  Picnic.swift
//  Picnic
//
//  Created by Kyle Burns on 5/22/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit
import FirebaseFirestoreSwift

enum PicnicTag: String, Codable {
    case empty
}

// MARK: Probably ought to store its own images.... or in a manager class
struct Picnic: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String = ""
    var userDescription: String = ""
    var tags: [PicnicTag] = []
    var imageNames: [String] = ["loading"]
    var rating: Float = 0.0
    var ratingCount: Int = 0
    var wouldVisit: Int = 0
    var visitCount: Int = 0
    var locationData: LocationData?
// MARK: Had to store outside location info for querying
    var geohash: String = ""

//    init(fromDictionary dict: [String: Any]) {
//        name = dict["name"] as? String ?? ""
//        userDescription = dict["userDescription"] as? String ?? ""
//        tags = dict["tags"] as? [PicnicTag] ?? []
//        imageNames = dict["imageNames"] as? [String] ?? ["loading"]
//        uid = dict["key"] as? String ?? ""
//        rating = (dict["rating"] as? NSNumber)?.floatValue ?? 0.0
//        ratingCount = dict["ratingCount"] as? Int ?? 0
//        wouldVisit = dict["wouldVisit"] as? Int ?? 0 // probably won't use this
//        visitCount = dict["didVisit"] as? Int ?? 0
//        let city = dict["city"] as? String
//        let state = dict["state"] as? String
//        let lat = dict["latitude"] as? Double ?? 0.0
//        let long = dict["longitude"] as? Double ?? 0.0
//        locationData = LocationData(latitude: lat, longitude: long, city: city, state: state)
//    }
    
    init(name: String, userDescription: String, tags: [PicnicTag], imageNames: [String], rating: Float, didVisit: Bool, locationData: LocationData) {
        self.name = name
        self.userDescription = userDescription
        self.tags = tags
        self.imageNames = imageNames
        self.rating = rating
        ratingCount = 1
        self.visitCount = didVisit ? 1 : 0
        self.locationData = locationData
        geohash = locationData.hash
    }
    
    init() {}
}

struct LocationData: Codable {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var city: String?
    var state: String?
    var park: String?
}

extension LocationData {
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var hash: String {
        Region(latitude: latitude, longitude: longitude, precision: kDefaultPrecision).hash
    }
}
