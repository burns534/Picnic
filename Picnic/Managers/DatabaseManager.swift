//
//  DatabaseManager.swift
//  Picnic
//
//  Created by Kyle Burns on 6/1/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import MapKit

fileprivate let queryPrecision: Int = 7

enum QueryParameter {
    case radius, tags, rating, limit, location
}

final class DatabaseManager: NSObject {
    private let picnics: CollectionReference = Firestore.firestore().collection("Picnics")
    private let users: CollectionReference = Firestore.firestore().collection("Users")
    private let reviews = Firestore.firestore().collection("Reviews")
    private let storage = Storage.storage().reference(withPath: "images")
    private var listeners = [Int: ListenerRegistration]()
    private var picnicQueries = [String: PicnicQuery]()
    private var reviewQueries = [String: PaginatedQuery]()
    private var userData = UserData()
    deinit { listeners.values.forEach { $0.remove() } }

// MARK: General Functions
    func removeListeners(_ listeners: [AnyObject]) {
        listeners.forEach {
            self.listeners.removeValue(forKey: $0.hash)?.remove()
        }
    }
    
    func removeListener(_ listener: AnyObject) {
        listeners.removeValue(forKey: listener.hash)?.remove()
    }
    
    func removeQuery(_ key: String) {
        picnicQueries.removeValue(forKey: key)
        reviewQueries.removeValue(forKey: key)
    }
    
    func picnicQuery(_ key: String) -> PicnicQuery? {
        picnicQueries[key]
    }
    
// MARK: UserManager
    func configure() {
        guard let id = Auth.auth().currentUser?.uid else { return }
        listeners[0] = users.document(id).collection("saved").addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let snapshot = snapshot {
                self?.userData.saved = snapshot.documents.map { $0.documentID }
            }
        }
        listeners[1] = users.document(id).collection("rated").addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let snapshot = snapshot {
                self?.userData.rated = snapshot.documents.reduce(into: [String: Int64]()) {
                    $0[$1.documentID] = $1.data()?["value"] as? Int64
                }
            }
        }
    }
    
    func addSaveListener(picnic: Picnic, listener: AnyObject, executionBlock: @escaping (Bool) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid,
              let id = picnic.id else { return }
        listeners[listener.hash] = users.document(uid).collection("saved").document(id).addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let snapshot = snapshot {
                executionBlock(snapshot.exists)
            }
        }
    }

    func savePost(picnic: Picnic, completion: (() -> ())? = nil) {
        guard let id = picnic.id, let uid = Auth.auth().currentUser?.uid else { return }
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
        guard let id = picnic.id, let uid = Auth.auth().currentUser?.uid else { return }
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
    

// MARK: Picnic Manager
    func store(picnic: Picnic, images: [UIImage], completion: @escaping () -> ()) {
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            let uploadGroup = DispatchGroup()
            uploadGroup.enter()
            
            guard let ref = try? self?.picnics.addDocument(from: picnic, completion: { _ in uploadGroup.leave() }) else { return }
            guard let imageNames = picnic.imageNames else { return }
            for (name, image) in zip(imageNames, images) {
                uploadGroup.enter()
                if let data = image.jpegData(compressionQuality: 0.7) {
                    self?.storage.child(ref.documentID + "/\(name)").putData(data, metadata: StorageMetadata(dictionary: ["contentType": "image/jpeg"])) { metadata, error in
                        if let error = error { print(error.localizedDescription) }
                        uploadGroup.leave()
                    }
                } else { uploadGroup.leave() }
            }
            uploadGroup.notify(queue: .main) { completion() }
        }
    }
    
    private func storeImages(images: [UIImage], imageNames: [String], for pid: String, completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let uploadGroup = DispatchGroup()
            for (name, image) in zip(imageNames, images) {
                uploadGroup.enter()
                if let data = image.jpegData(compressionQuality: 0.7) {
                    self?.storage.child(pid + "/\(name)").putData(data, metadata: StorageMetadata(dictionary: ["contentType": "image/jpeg"])) { metadata, error in
                        if let error = error { print(error.localizedDescription) }
                        uploadGroup.leave()
                    }
                } else { uploadGroup.leave() }
            }
            
            uploadGroup.notify(queue: .main) {
                completion()
            }
        }
    }

    func image(forPicnic picnic: Picnic, index: Int = 0, maxSize: Int64 = 2 * 1024 * 1024, completion: @escaping (UIImage) -> ()) {
        guard let id = picnic.id,
              let imageNames = picnic.imageNames,
              imageNames.count > 0
        else { return }
        storage.child(id).child(imageNames[index]).getData(maxSize: maxSize) { data, error in
            if let error = error {
                print("Error: DatabaseManager: image forPicnic: could not load image from firebase storage: \(error.localizedDescription)")
            } else if let data = data, let image = UIImage(data: data) {
                completion(image)
            }
        }
    }
    
    func updateRating(pid: String, value: Int64, completion: (() -> ())? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let oldValue = userData.rated[pid] ?? 0
        let taskGroup = DispatchGroup()
        taskGroup.enter()
        users.document(uid).collection("rated").document(pid).setData([
            "value": value
        ], merge: true) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            taskGroup.leave()
        }
        taskGroup.enter()
        picnics.document(pid).updateData([
            "totalRating": FieldValue.increment(value - oldValue),
            "ratingCount": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            taskGroup.leave()
        }
        taskGroup.notify(queue: .main) {
            completion?()
        }
    }
    
// MARK: Picnic Queries
    
    /**
     - parameters:
        - radius: radius in Kilometers
     */
    func addPicnicQuery(params: [QueryParameter: Any], key queryKey: String) {
        picnicQueries[queryKey] = PicnicQuery(collection: picnics, params: params)
    }
    
    func refresh(forPicnicQueryKey queryKey: String, completion: (([Picnic]) -> ())?) {
        guard let query = picnicQueries[queryKey] else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            query.current.getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let picnics = snapshot?.documents.compactMap({ try? $0.data(as: Picnic.self) }) {
                    completion?(picnics.compactMap {
                        $0.location.distance(from: query.location) > query.radius * 1000 ? nil : $0
                    })
                }
            }
        }
    }
    
    func nextPage(forPicnicQueryKey queryKey: String, completion: (([Picnic]) -> ())?) {
        guard let query = picnicQueries[queryKey]
        else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            query.next().getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let picnics = snapshot?.documents.compactMap({ try? $0.data(as: Picnic.self) }), let next = snapshot?.documents.last {
                    self.picnicQueries[queryKey]?.pushDocument(next)
                    completion?(picnics.compactMap {
                        $0.location.distance(from: query.location) > query.radius * 1000 ? nil : $0
                    })
                }
            }
        }
    }
    
    func query(name: String, completion: (([Picnic]) -> ())?) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.picnics.whereField("name", isEqualTo: name).getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let documents = snapshot?.documents {
                    completion?(documents.compactMap {
                        try? $0.data(as: Picnic.self)
                    })
                }
            }
        }
    }
    
    func addVisitedListener(picnic: Picnic, listener: AnyObject, executionBlock: @escaping (Int) -> ()) {
        guard let id = picnic.id else { return }
        listeners[listener.hash] = picnics.document(id).addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let visited = snapshot?.data()?["visitCount"] as? Int {
                executionBlock(visited)
            }
        }
    }
    
    func addWouldVisitListener(picnic: Picnic, listener: AnyObject, executionBlock: @escaping (Int) -> ()) {
        guard let id = picnic.id else { return }
        listeners[listener.hash] = picnics.document(id).addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let wouldVisit = snapshot?.data()?["wouldVisit"] as? Int {
                executionBlock(wouldVisit)
            }
        }
    }
    
    func updateWouldVisit(picnic: Picnic, value: Int64) {
        guard let id = picnic.id else { return }
        picnics.document(id).updateData(["wouldVisit": FieldValue.increment(value)])
    }
    
    func updateVisited(picnic: Picnic, value: Int64) {
        guard let id = picnic.id else { return }
        picnics.document(id).updateData(["visitCount": FieldValue.increment(value)])
    }
    
// MARK: ReviewManager
    
    func submitReview(review: Review, images: [UIImage]? = nil, completion: ((DocumentReference?) -> ())? = nil) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let taskGroup = DispatchGroup()
            taskGroup.enter()
            let ref = try? self?.reviews.addDocument(from: review) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
                taskGroup.leave()
            }
            
            if let images = images, let imageNames = review.images {
                taskGroup.enter()
                self?.storeImages(images: images, imageNames: imageNames, for: review.pid) {
                    taskGroup.leave()
                }
            }
            
            taskGroup.enter()
            self?.updateRating(pid: review.pid, value: Int64(review.rating)) {
                taskGroup.leave()
            }
            
            taskGroup.notify(queue: .main) {
                completion?(ref)
            }
        }
    }
    
    func addReviewQuery(for picnic: Picnic, limit: Int, queryKey: String) {
        guard let id = picnic.id else { return }
        let query = reviews.whereField("pid", isEqualTo: id).limit(to: limit)
        reviewQueries[queryKey] = PaginatedQuery(query: query)
    }
    
    func nextPage(forReviewQueryKey queryKey: String, completion: (([Review]) -> ())?) {
        guard let query = reviewQueries[queryKey]?.next() else { return }
        
        query.getDocuments { [weak self] snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let reviews = snapshot?.documents.compactMap({
                try? $0.data(as: Review.self)
            }), let next = snapshot?.documents.last {
                self?.reviewQueries[queryKey]?.pushDocument(next)
                completion?(reviews)
            }
        }
    }
    
    func refresh(forReviewQueryKey queryKey: String, completion: (([Review]) -> ())?) {
        guard let query = reviewQueries[queryKey]?.next() else { return }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let reviews = snapshot?.documents.compactMap({
                try? $0.data(as: Review.self)
            }){
                completion?(reviews)
            }
        }
    }
    
}

