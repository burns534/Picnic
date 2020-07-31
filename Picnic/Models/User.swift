//
//  User.swift
//  Picnic
//
//  Created by Kyle Burns on 7/30/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class User: NSObject {
    
    private let database = Database.database().reference()
    private var ref: DatabaseReference!
    
// MARK: User Data
    var uid: String!
    var posts: [String]! // probably fine
    var isAnonymous: Bool!
    
    func configureUser(uid: String, isAnonymous: Bool) {
        self.uid = uid
        self.isAnonymous = isAnonymous
        ref = database.child("Users").child(uid)
    }
    
    func likePost(id: String, completion: @escaping (Error?) -> () = {_ in}) {
        guard let _ = ref else { return }
        ref.child("likedPosts").updateChildValues([id: true]) { error, _ in
            completion(error)
        }
    }
}
