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
    var user: User? = nil
    private var listeners = [Int: ListenerRegistration]()
    deinit { listeners.values.forEach { $0.remove() } }
    
    func configure() {
// MARK: If this fails it means it's a new user
        guard let id = Auth.auth().currentUser?.uid else { return }
        user = User()
        user?.id = id
        if listeners.count == 0 {
            listeners[0] = users.document(id).collection("saved").addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let snapshot = snapshot {
                    self?.user?.saved = snapshot.documents.map { $0.documentID }
                }
            }
            listeners[1] = users.document(id).collection("rated").addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let snapshot = snapshot {
                    self?.user?.rated = snapshot.documents.map { $0.documentID }
                }
            }
        }
    }
    
    func addSaveListener(picnic: Picnic, listener: HeartButton) {
        guard let uid = Auth.auth().currentUser?.uid,
              let id = picnic.id else { return }
        listeners[listener.hash] = users.document(uid).collection("saved").document(id).addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let snapshot = snapshot {
                listener.setActive(isActive: snapshot.exists)
            }
        }
    }
    
    func removeSaveListener(_ listener: HeartButton) {
        listeners.removeValue(forKey: listener.hash)?.remove()
    }
    
    func signIn() {
        if user == nil {
            guard let id = Auth.auth().currentUser?.uid else { return }
            users.document(id).setData([
                "rated": [],
                "saved": []
            ]) { [weak self] error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self?.configure()
                }
            }
        }
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
    
    func savePost(picnic: Picnic, completion: (() -> ())? = nil) {
        guard let id = picnic.id, let uid = user?.id else { return }
        DispatchQueue.global().async { [weak self] in
            self?.users.document(uid).collection("saved").document(id).setData(["isSaved": true]) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    completion?()
                }
            }
        }
    }
    
    func unsavePost(picnic: Picnic, completion: (() -> ())? = nil) {
        guard let id = picnic.id, let uid = user?.id else { return }
        DispatchQueue.global().async { [weak self] in
            self?.users.document(uid).collection("saved").document(id).delete { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    completion?()
                }
            }
        }
    }
    
    func isSaved(picnic: Picnic) -> Bool {
        guard let id = picnic.id, let saved = user?.saved else { return false }
        return saved.contains(id)
    }
    
    func rateRequest(picnic: Picnic, completion: ((Bool) -> ())? = nil) {
        guard let id = picnic.id, let uid = user?.id, let rated = user?.rated else { return }
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
