//
//  UserManager.swift
//  Picnic
//
//  Created by Kyle Burns on 10/3/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

final class UserManager {
    private let users: CollectionReference = Firestore.firestore().collection("Users")
    var userData: User? = nil
    var listener: ListenerRegistration?
    
    deinit { listener?.remove() }
    
    func configure() {
// MARK: If this fails it means it's a new user
        guard let id = Auth.auth().currentUser?.uid else { return }
// MARK: This is probably bad
        if userData == nil {
            users.document(id).getDocument { [weak self] document, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let document = document {
                    self?.userData = try? document.data(as: User.self)
                }
            }
        }
        if listener == nil {
            listener = users.document(id).addSnapshotListener { [weak self] document, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let document = document {
                    self?.userData = try? document.data(as: User.self)
                }
            }
        }
    }
    
    func signIn() {
        if userData == nil { configure() }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    func shouldRequestLogin() -> Bool {
        Auth.auth().currentUser == nil || Auth.auth().currentUser!.isAnonymous
    }
    
    func savePost(picnic: Picnic, completion: @escaping () -> ()) {
        guard let id = picnic.id, let uid = userData?.id else { return }
        DispatchQueue.global().async { [weak self] in
            self?.users.document(uid).collection("saved").document(id).setData(["isSaved": true]) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    completion()
                }
            }
        }
    }
    
    func unsavePost(picnic: Picnic, completion: @escaping () -> ()) {
        guard let id = picnic.id, let uid = userData?.id else { return }
        DispatchQueue.global().async { [weak self] in
            self?.users.document(uid).collection("saved").document(id).delete { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    completion()
                }
            }
        }
    }
    
    func isSaved(picnic: Picnic) -> Bool {
        guard let id = picnic.id, let saved = userData?.saved else { return false }
        return saved.contains(id)
    }
    
    func rateRequest(picnic: Picnic, completion: ((Bool) -> ())? = nil) {
        guard let id = picnic.id, let uid = userData?.id, let rated = userData?.rated else { return }
        if !rated.contains(id) {
            DispatchQueue.global().async { [weak self] in
                self?.users.document(uid).collection("rated").document(id).setData(["isRated": true]) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        completion?(true)
                    }
                }
            }
        } else {
            completion?(false)
        }
    }
}
