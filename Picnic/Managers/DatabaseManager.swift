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

final class PaginatedQuery {
    var query: Query
    private var currentPage: Int = -1
    private var documents: [DocumentSnapshot] = []
    
    public init(query: Query) {
        self.query = query
    }
    
    func pushDocument(_ doc: DocumentSnapshot) {
        documents.append(doc)
    }
    
    func next() -> Query {
        if documents.count == 0 { return query }
        if currentPage == documents.count - 1 {
            return query.start(afterDocument: documents[currentPage])
        }
        currentPage += 1
        return query.start(afterDocument: documents[currentPage])
    }
    
    func back() -> Query {
        if currentPage <= 1 { return query }
        currentPage -= 1
        return query.start(afterDocument: documents[currentPage])
    }
    
    func current() -> Query {
        if currentPage == -1 { return query }
        return query.start(afterDocument: documents[currentPage])
    }
    
    func goTo(index: Int) -> Query {
        currentPage = index
        return query.start(afterDocument: documents[index])
    }
    
    func first() -> Query {
        currentPage = -1
        return query
    }
    
    func reset() {
        currentPage = -1
        documents = []
    }
}

final class DatabaseManager: NSObject {
    private let picnics: CollectionReference = Firestore.firestore().collection("Picnics")
    private let users: CollectionReference = Firestore.firestore().collection("Users")
    private let reviews = Firestore.firestore().collection("Reviews")
    private let storage = Storage.storage().reference(withPath: "images")
    private var listeners = [Int: ListenerRegistration]()
    private var queries = [String: [PaginatedQuery]]()
    private var user: User = User()
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
        queries.removeValue(forKey: key)
    }

// MARK: UserManager
    func configure() {
// MARK: If this fails it means it's a new user
        guard let id = Auth.auth().currentUser?.uid else { return }
        user.id = id
        if listeners.count == 0 {
            listeners[0] = users.document(id).collection("saved").addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let snapshot = snapshot {
                    self?.user.saved = snapshot.documents.map { $0.documentID }
                }
            }
            listeners[1] = users.document(id).collection("rated").addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let snapshot = snapshot {
                    self?.user.rated = snapshot.documents.reduce(into: [String: Int64]()) {
                        $0[$1.documentID] = $1.data()?["value"] as? Int64
                    }
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
    
    func signIn() {
        if user.id == nil {
            configure()
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
        guard let id = picnic.id, let uid = user.id else { return }
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
        guard let id = picnic.id, let uid = user.id else { return }
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
        user.saved.contains(picnic.id ?? "")
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

    func image(forPicnic picnic: Picnic, index: Int = 0, maxSize: Int64 = 2 * 1024 * 1024, completion: @escaping (UIImage) -> ()) {
        guard let id = picnic.id, let imageNames = picnic.imageNames else { return }
        storage.child(id).child(imageNames[index]).getData(maxSize: maxSize) { data, error in
            if let error = error {
                print("Error: DatabaseManager: image forPicnic: could not load image from firebase storage: \(error.localizedDescription)")
            } else if let data = data, let image = UIImage(data: data) {
                completion(image)
            }
        }
    }
    
    func updateRating(picnic: Picnic, value: Int64, completion: (() -> ())? = nil) {
        guard let uid = user.id, let id = picnic.id else { return }
        let oldValue = user.rated[picnic.id ?? ""] ?? 0
        let taskGroup = DispatchGroup()
        taskGroup.enter()
        users.document(uid).collection("rated").document(id).updateData([
            "value": value
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                taskGroup.leave()
            }
        }
        taskGroup.enter()
        picnics.document(id).updateData([
            "totalRating": FieldValue.increment(value - oldValue),
            "ratingCount": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                taskGroup.leave()
            }
        }
        taskGroup.notify(queue: .main) {
            completion?()
        }
    }
    
// MARK: Picnic Queries
    
    func addPicnicQuery(location: CLLocation, limit: Int, radius: Double, key queryKey: String) {
        let region = Region(location: location, radius: radius)
        queries[queryKey] = [PaginatedQuery]()
        if let regions = region.queryRegions(location: location, radius: radius) {
            for region in regions {
                let query = picnics.whereField("geohash", isGreaterThanOrEqualTo: region.hash + "0").whereField("geohash", isLessThan: region.hash + "~").limit(to: limit / regions.count)
                queries[queryKey]?.append(PaginatedQuery(query: query))
            }
        }
    }
// MARK: This is BADDDD- there is a much simpler solution
//    private func generatePicnicQuery(region: Region, limit: Int) -> Query? {
//        guard let precision = region.precision else { return nil }
//        // messy
//        let offset = String("000000000".dropLast(precision.rawValue))
//        let start = region.hash.dropLast(kDefaultPrecision - precision.rawValue) + offset
//        let criticalChar = (region.hash[precision.rawValue - 1].cString(using: .ascii)?.first!)! + 1
//        let modifiedChar = String(bytes: [UInt8(criticalChar)], encoding: .ascii)
//        let end = region.hash.dropLast(kDefaultPrecision - precision.rawValue + 1) + modifiedChar! + offset
//        return picnics.whereField("geohash", isGreaterThanOrEqualTo: start).whereField("geohash", isLessThan: end).limit(to: limit)
//    }
    
    func refresh(forPicnicQueryKey queryKey: String, completion: (([Picnic]) -> ())?) {
        guard let queryGroup = queries[queryKey] else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            var result = [Picnic]()
            let taskGroup = DispatchGroup()
            for queryInfo in queryGroup {
                taskGroup.enter()
                queryInfo.current().getDocuments { snapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let picnics = snapshot?.documents.compactMap({ try? $0.data(as: Picnic.self) }) {
                        result.append(contentsOf: picnics)
                        taskGroup.leave()
                    }
                }
            }
            taskGroup.notify(qos: .userInitiated, flags: .enforceQoS, queue: .main) {
                completion?(result)
            }
        }
    }
    
    func nextPage(forPicnicQueryKey queryKey: String, completion: (([Picnic]) -> ())?) {
        guard let queryGroup = queries[queryKey] else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            var result = [Picnic]()
            let taskGroup = DispatchGroup()
            for (index, paginatedQuery) in queryGroup.enumerated() {
                taskGroup.enter()
                paginatedQuery.next().getDocuments { snapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let picnics = snapshot?.documents.compactMap({ try? $0.data(as: Picnic.self) }), let next = snapshot?.documents.last {
                        result.append(contentsOf: picnics)
                        self.queries[queryKey]?[index].pushDocument(next)
                        taskGroup.leave()
                    }
                }
            }
            taskGroup.notify(qos: .userInitiated, flags: .enforceQoS, queue: .main) {
                completion?(result)
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
    
    func addReviewQuery(for picnic: Picnic, limit: Int, queryKey: String) {
        guard let id = picnic.id else { return }
        let query = reviews.whereField("pid", isEqualTo: id).limit(to: limit)
        queries[queryKey] = [PaginatedQuery(query: query)]
    }
    
    func nextPage(for queryKey: String, completion: (([Review]) -> ())?) {
        guard let query = queries[queryKey]?[0].next() else { return }
        
        query.getDocuments { [weak self] snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let reviews = snapshot?.documents.compactMap({
                try? $0.data(as: Review.self)
            }), let next = snapshot?.documents.last {
                self?.queries[queryKey]?[0].pushDocument(next)
                completion?(reviews)
            }
        }
    }
    
    
}

