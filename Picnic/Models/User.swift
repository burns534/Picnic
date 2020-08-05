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
    var uid: String! {
        didSet {
            UserDefaults.standard.setValue(uid, forKey: "uid")
        }
    }
    var isAnonymous: Bool!
    
    override init() {
        if let id = UserDefaults.standard.value(forKey: "uid") as? String {
            uid = id
            ref = database.child("Users").child(uid)
        }
    }
    
    func configureUser(uid: String, isAnonymous: Bool) {
        self.uid = uid
        self.isAnonymous = isAnonymous
        ref = database.child("Users").child(uid)
    }
    
    func likePost(id: String, value: Bool, completion: @escaping (Error?) -> () = {_ in}) {
        guard let _ = ref else { return }
        ref.child("likedPosts").updateChildValues([id: value]) { error, _ in
            completion(error)
        }
    }
    
    func isLiked(post id: String, completion: @escaping (Bool) -> ()) {
        guard let _ = ref else { return }
        ref.child("likedPosts").child(id).observeSingleEvent(of: .value) { snapshot in
            if let liked = snapshot.value as? Bool {
                completion(liked)
            } else {
                completion(false)
            }
        }
    }
    
    func ratePost(id: String, completion: @escaping (Error?) -> () = {_ in}) {
        guard let _ = ref else { return }
        ref.child("ratedPosts").updateChildValues([id: true]) { error, _ in
            completion(error)
        }
    }
    
    func isRated(post id: String, completion: @escaping (Bool) -> ()) {
        guard let _ = ref else { return }
        ref.child("ratedPosts").child(id).observeSingleEvent(of: .value) { snapshot in
            if let rated = snapshot.value as? Bool {
                completion(rated)
            } else {
                completion(false)
            }
        }
    }
    
    
}
