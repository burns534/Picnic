//
//  PaginatedQuery.swift
//  Picnic
//
//  Created by Kyle Burns on 10/13/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

open class PaginatedQuery {
    open var query: Query
    private var currentPage: Int = -1
    private var documents: [DocumentSnapshot] = []
    
    public init(query: Query, limit: Int) {
        self.query = query.limit(to: limit)
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
    }
}
