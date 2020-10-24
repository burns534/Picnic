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

class PicnicQuery {
    private var baseQuery: Query
    private var params: [QueryParameter: Any] = [:]
    private var currentPage: Int = -1
    private var documents: [DocumentSnapshot] = []
    private var query: Query
    
    var radius: Double {
        params[.radius] as? Double ?? kDefaultQueryRadius
    }
    
    var location: CLLocation {
        params[.location] as? CLLocation ?? CLLocation()
    }
    
    init(collection: CollectionReference, params: [QueryParameter: Any]) {
        self.params = params
        baseQuery = collection.order(by: "geohash")
        query = baseQuery
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
        configureQuery()
    }
    
    func setRating(rating: Double) {
        params[.rating] = rating
        query = query.whereField("rating", isEqualTo: rating)
    }
    
    private func configureQuery() {
        let radius = params[.radius] as? Double ?? kDefaultQueryRadius
        let location = params[.location] as? CLLocation ?? CLLocation()
        let hash = Region.hashForRadius(location: location, radius: radius)
        let limit = params[.limit] as? Int ?? kDefaultQueryLimit
        query = baseQuery.start(at: [hash + "0"]).end(at: [hash + "~"]).limit(to: limit)
        if let rating = params[.rating] {
            query = query.whereField("rating", isEqualTo: rating)
        }
        if let tags = params[.tags] as? [PicnicTag] {
            for tag in tags {
                query = query.whereField("tags." + tag.rawValue, isEqualTo: true)
            }
        }
    }
    
    var current: Query {
        if currentPage == -1 { return query }
        return query.start(afterDocument: documents[currentPage])
    }
    
    func pushDocument(_ doc: DocumentSnapshot) {
        documents.append(doc)
    }
    
    func next() -> Query {
        if documents.count == 0 { return query }
        if currentPage == documents.count - 1 {
            return query.start(afterDocument: documents[currentPage])
        }
        currentPage += 1
        return query.start(afterDocument: documents[currentPage])
    }
    
    func back() -> Query {
        if currentPage <= 1 { return query }
        currentPage -= 1
        return query.start(afterDocument: documents[currentPage])
    }
    
    func goTo(index: Int) -> Query {
        currentPage = index
        return query.start(afterDocument: documents[index])
    }
    
    func first() -> Query {
        currentPage = -1
        return query
    }
    
    func reset() {
        currentPage = -1
        documents = []
        params[.radius] = kDefaultQueryRadius
        params[.rating] = nil
        params[.tags] = nil
    }
}

