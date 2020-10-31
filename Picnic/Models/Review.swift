//
//  Review.swift
//  Picnic
//
//  Created by Kyle Burns on 10/8/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct Review: Codable, Identifiable {
    @DocumentID var id: String?
    var pid: String
    var uid: String
    var rating: Int64
    var content: String
    var userDisplayName: String?
    var userPhotoURL: URL?
    var timestamp: Timestamp
    var imageNames: [String]?
}

extension Review {
    var date: Date {
        timestamp.dateValue()
    }
}
