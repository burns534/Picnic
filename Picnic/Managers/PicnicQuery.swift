//
//  PicnicQuery.swift
//  Picnic
//
//  Created by Kyle Burns on 10/20/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import MapKit

class PicnicQuery: PaginatedQuery {
    private var baseQuery: Query
    private var params: [QueryParameter: Any] = [:]
    private var currentPage: Int = -1
    private var documents: [DocumentSnapshot] = []
    
    var radius: Double {
        params[.radius] as? Double ?? kDefaultQueryRadius
    }
    
    var location: CLLocation {
        params[.location] as? CLLocation ?? CLLocation()
    }
    
    var tags: [PicnicTag]? {
        params[.tags] as? [PicnicTag]
    }
    
    init(collection: CollectionReference, params: [QueryParameter: Any]) {
        self.params = params
        baseQuery = collection.order(by: "geohash")
        let limit = params[.limit] as? Int ?? kDefaultQueryLimit
        super.init(query: baseQuery, limit: limit)
        configureQuery()
    }
    
    func setRadius(radius: Double) {
        params[.radius] = radius
        let location = params[.location] as? CLLocation ?? CLLocation()
        let hash = Region.hashForRadius(location: location, radius: radius)
        query = query.start(at: [hash + "0"]).end(at: [hash + "~"])
    }
    
    func setTags(tags: [PicnicTag]) {
        params[.tags] = tags
    }
    
    func setRating(rating: Double) {
        params[.rating] = rating
        query = query.whereField("rating", isEqualTo: rating)
    }
    
    private func configureQuery() {
        let radius = params[.radius] as? Double ?? kDefaultQueryRadius
        let location = params[.location] as? CLLocation ?? CLLocation()
        let hash = Region.hashForRadius(location: location, radius: radius)
        query = baseQuery.start(at: [hash + "0"]).end(at: [hash + "~"])
        if let rating = params[.rating] {
            query = query.whereField("rating", isEqualTo: rating)
        }
    }
    
    override func reset() {
        super.reset()
        params[.radius] = kDefaultQueryRadius
        params[.rating] = nil
        params[.tags] = nil
        configureQuery()
    }
}

