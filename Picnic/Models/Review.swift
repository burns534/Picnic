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
    var rating: Float
    var content: String
    var userDisplayName: String?
    var userPhotoURL: URL?
// MARK: This might be bad
//    var date: Timestamp
    var images: [String]?
}
