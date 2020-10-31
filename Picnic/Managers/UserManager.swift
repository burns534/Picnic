//
//  UserManager.swift
//  Picnic
//
//  Created by Kyle Burns on 10/26/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseFirestore
import FirebaseAuth

final class UserManager: DatabaseManager {
    static let `default` = UserManager()
    let userData = UserData()
    private var handle: AuthStateDidChangeListenerHandle!
    var uid: String? { Auth.auth().currentUser?.uid }
    var picnicReference: CollectionReference = Firestore.firestore().collection("Picnics")
    private init() {
        super.init(reference: Firestore.firestore().collection("Users"))
        handle = Auth.auth().addStateDidChangeListener {[self] _, _ in
            configure()
        }
    }
    deinit {
        removeSnapshotListeners(for: ["saved", "rated"])
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    func configure() {
        guard let id = Auth.auth().currentUser?.uid else { return }
        let ratedListener = reference.document(id).collection("rated").addSnapshotListener { [unowned self] snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let snapshot = snapshot {
                let rated = snapshot.documents.reduce(into: [String: Int64]()) {
                    $0[$1.documentID] = $1.data()?["value"] as? Int64
                }
                userData.setRated(rated)
            }
        }
        addSnapshotListener(ratedListener, for: "rated")
    }

    func addSaveListener(picnic: Picnic, listener: AnyObject, executionBlock: @escaping (Bool) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid,
              let id = picnic.id else { return }
        let saveListener = reference.document(uid).collection("saved").document(id).addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let snapshot = snapshot {
                executionBlock(snapshot.exists)
            }
        }
        addSnapshotListener(saveListener, for: listener.hash)
    }
    
    func removeSaveListener(listener: AnyObject) {
        removeSnapshotListener(for: listener.hash)
    }

    func savePost(picnic: Picnic, completion: (() -> ())? = nil) {
        guard let id = picnic.id, let uid = Auth.auth().currentUser?.uid else { return }
        DispatchQueue.global().async { [self] in
            reference.document(uid).collection("saved").document(id).setData(["timestamp": Timestamp(date: Date())]) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    completion?()
                }
            }
        }
    }
    
    func unsavePost(picnic: Picnic, completion: (() -> ())? = nil) {
        guard let id = picnic.id, let uid = Auth.auth().currentUser?.uid else { return }
        DispatchQueue.global().async { [self] in
            reference.document(uid).collection("saved").document(id).delete { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    completion?()
                }
            }
        }
    }
    
    func getProfileImage(completion: @escaping (UIImage?) -> ()){
        if userData.profileImage == nil {
            DispatchQueue.global(qos: .userInteractive).async { [self] in
                if let url = Auth.auth().currentUser?.photoURL,
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                    userData.profileImage = image
                }
            }
        } else {
            completion(userData.profileImage)
        }
    }
    
    func getUserBio(completion: @escaping (String?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if userData.userBio == nil {
            DispatchQueue.global(qos: .userInitiated).async {
                self.reference.document(uid).getDocument { snapshot, err in
                    if let err = err {
                        print(err.localizedDescription)
                    } else if let userBio = snapshot?.data()?["userBio"] as? String {
                        self.userData.userBio = userBio
                        completion(userBio)
                    }
                }
            }
        } else {
            completion(userData.userBio)
        }
    }
// TODO: I might not want to do this custom error thing
    func updateRating(for pid: String, value: Int64, completion: @escaping (Error?) -> ()) {
        guard let uid = uid else {
            let userInfo = [NSLocalizedDescriptionKey: "Found nil when unwrapping user id"]
            completion(NSError(domain: "", code: 0, userInfo: userInfo))
            return
        }
        DispatchQueue.global(qos: .utility).async { [self] in
            reference.document(uid).collection("rated").document(pid).setData(["value" : value], merge: true) {
                completion($0)
            }
        }
    }
// MARK: Queries
    /**
     Add query for saved posts
     */
    func addSavedPostQuery(for key: String, completion: (([Picnic]) ->())? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        queries[key] = SavedPostQuery(collection: reference.document(uid).collection("saved"), limit: 10)
        if let completion = completion {
            nextPage(forSavedQuery: key, completion: completion)
        }
    }
/**
     Due to firestore limitations, a page can only be 10 documents at a time
*/
    func nextPage(forSavedQuery key: String, completion: @escaping ([Picnic]) -> ()) {
        guard let query = queries[key] as? SavedPostQuery else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            query.next().getDocuments { snapshot, err in
                if let err = err {
                    print(err.localizedDescription)
                } else if let idList = snapshot?.documents.map({ $0.documentID }) {
                    self.picnicReference.whereField(FieldPath.documentID(), in: idList).getDocuments {
                        if let err = $1 {
                            print(err.localizedDescription)
                        } else if let picnics = $0?.documents.compactMap({
                            try? $0.data(as: Picnic.self)
                        }) {
                            completion(picnics)
                        }
                    }
                }
            }
        }
    }
    
    func refreshQuery(forSavedQuery key: String, completion: @escaping ([Picnic]) -> ()) {
        guard let query = queries[key] as? SavedPostQuery else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            query.current.getDocuments { snapshot, err in
                if let err = err {
                    print(err.localizedDescription)
                } else if let idList = snapshot?.documents.map({ $0.documentID }) {
                    self.picnicReference.whereField(FieldPath.documentID(), in: idList).getDocuments {
                        if let err = $1 {
                            print(err.localizedDescription)
                        } else if let picnics = $0?.documents.compactMap({
                            try? $0.data(as: Picnic.self)
                        }) {
                            completion(picnics)
                        }
                    }
                }
            }
        }
    }
    
    func addUserPostQuery(for key: String, completion: (([Picnic]) ->())? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        queries[key] = PaginatedQuery(query: picnicReference.whereField("uid", isEqualTo: uid), limit: kDefaultQueryLimit)
        if let completion = completion {
            nextPage(forSavedQuery: "userPosts", completion: completion)
        }
    }
    
    func nextPage(forUserPostQuery key: String, completion: @escaping ([Picnic]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.queries[key]?.next().getDocuments { snapshot, err in
                if let err = err {
                    print(err.localizedDescription)
                } else if let picnics = snapshot?.documents.compactMap({
                    try? $0.data(as: Picnic.self)
                }) {
                    completion(picnics)
                }
            }
        }
    }
    
    func refreshQuery(forUserPostQuery key: String, completion: @escaping ([Picnic]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.queries[key]?.current.getDocuments { snapshot, err in
                if let err = err {
                    print(err.localizedDescription)
                } else if let picnics = snapshot?.documents.compactMap({
                    try? $0.data(as: Picnic.self)
                }) {
                    completion(picnics)
                }
            }
        }
    }
}
