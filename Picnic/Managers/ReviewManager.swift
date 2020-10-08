//
//  ReviewManager.swift
//  Picnic
//
//  Created by Kyle Burns on 10/7/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ReviewManager {
    private let reviews = Firestore.firestore().collection("Reviews")
    private let storage = Storage.storage().reference(withPath: "images")
}
