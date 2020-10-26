//
//  UserPostQuery.swift
//  Picnic
//
//  Created by Kyle Burns on 10/25/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseFirestore

final class UserPostQuery: PaginatedQuery {
    init(collection: CollectionReference, limit: Int) {
        super.init(query: collection.order(by: "timestamp"), limit: limit)
    }
}
