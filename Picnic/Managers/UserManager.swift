//
//  UserManager.swift
//  Picnic
//
//  Created by Kyle Burns on 10/3/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseDatabase

final class UserManager {
    private var userRef: DatabaseReference?
    private var user: User = User(uid: nil, isAnonymous: false)
    init() {
        if let userInfo = UserDefaults.standard.data(forKey: "userInfo"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: userInfo) {
            user = decodedUser
            guard let uid = decodedUser.uid else { return }
            userRef = Database.database().reference(withPath: "Users/\(uid)")
            DispatchQueue.global().async { [weak self] in
                self?.userRef?.observeSingleEvent(of: .value) { snapshot in
                    if let snapshotData = snapshot.value as? [String: Any],
                       let rated = snapshotData["rated"] as? [String],
                       let saved = snapshotData["saved"] as? [String] {
                        self?.user.rated = rated
                        self?.user.saved = saved
                    }
                }
            }
        }
    }
    
    deinit {
        updateDefaults()
        DispatchQueue.global().async { [weak self] in
            guard let this = self else { return }
            this.userRef?.updateChildValues([
                "rated": this.user.rated,
                "saved": this.user.saved
            ])
        }
    }
    
    func login(uid: String?, isAnonymous: Bool) {
        user = User(uid: uid, isAnonymous: isAnonymous)
        updateDefaults()
        guard let uid = uid else { return }
        userRef = Database.database().reference(withPath: "Users/\(uid)")
    }
    
    func logout() {
        user = User(uid: nil, isAnonymous: false)
        updateDefaults()
    }
    
    func shouldRequestLogin() -> Bool { user.isAnonymous || (user.uid == nil) }
    
    func updateDefaults() {
        do {
            let userInfo = try JSONEncoder().encode(user)
            UserDefaults.standard.set(userInfo, forKey: "userInfo")
        } catch {
            print("Could not decode user data \(error.localizedDescription)")
        }
    }
    /**
            Sets post to rated in user entry in database if not already set. Executes completion block only if user has not already rated the post.
     */
    func rateRequest(picnic: Picnic, completion: @escaping () -> ()) {
        guard let uid = user.uid else { return }
        if user.rated.contains(uid) { return }
        DispatchQueue.global().async { [weak self] in
            self?.userRef?.child("rated").child(uid).setValue(true)
            self?.user.rated.append(uid)
            completion()
        }
    }
    
    func ratePost(picnic: Picnic) {
        guard let uid = user.uid else { return }
        DispatchQueue.global().async { [weak self] in
            self?.userRef?.child("rated").child(uid).setValue(true)
        }
    }
    
    func savePost(picnic: Picnic) {
        guard let uid = user.uid else { return }
        DispatchQueue.global().async { [weak self] in
            self?.userRef?.child("saved").child(uid).setValue(true)
        }
    }
    
    func unsavePost(picnic: Picnic) {
        guard let uid = user.uid else { return }
        DispatchQueue.global().async { [weak self] in
            self?.userRef?.child("saved").child(uid).removeValue()
        }
    }
    
    func isSaved(picnic: Picnic) -> Bool {
        guard let id = picnic.id else { return false }
        return user.saved.contains(id)
    }
}
