//
//  DatabaseManager.swift
//  Picnic
//
//  Created by Kyle Burns on 6/1/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseStorage
import FirebaseFirestore
fileprivate let queryPrecision: Int = 7

enum QueryParameter {
    case radius, tags, rating, limit, location
}
// TODO: This could be rewritten with each type of manager inheriting from a base class probably. It's getting pretty long
open class DatabaseManager: NSObject {
    open var reference: CollectionReference
    open var queries: [String: PaginatedQuery] = [:]
    let storage = Storage.storage().reference(withPath: "images")
    private var listeners = [Int: ListenerRegistration]()
    
    public init(reference: CollectionReference) {
        self.reference = reference
    }
    
    deinit { listeners.values.forEach { $0.remove() } }

// MARK: General Functions
    func removeSnapshotListeners(_ listeners: [ListenerRegistration]) {
        listeners.forEach {
            self.listeners.removeValue(forKey: $0.hash)?.remove()
        }
    }
    
    func removeSnapshotListener(_ listener: ListenerRegistration) {
        listeners.removeValue(forKey: listener.hash)?.remove()
    }
    
    func removeSnapshotListener(_ listener: ListenerRegistration, for key: String) {
        listeners.removeValue(forKey: key.hash)?.remove()
    }
    
    func removeSnapshotListeners(for keys: [String]) {
        keys.forEach {
            listeners.removeValue(forKey: $0.hash)?.remove()
        }
    }
    
    func removeSnapshotListener(for key: Int) {
        listeners.removeValue(forKey: key)?.remove()
    }
    
    func addSnapshotListener(_ listener: ListenerRegistration) {
        listeners[listener.hash] = listener
    }
    
    func addSnapshotListener(_ listener: ListenerRegistration, for key: String) {
        listeners[key.hash] = listener
    }
    
    func addSnapshotListeners(_ listeners: [ListenerRegistration]) {
        listeners.forEach { self.listeners[$0.hash] = $0 }
    }
    
    func addSnapshotListener(_ listener: ListenerRegistration, for key: Int) {
        listeners[key] = listener
    }
    
    func removeQuery(_ key: String) {
        queries.removeValue(forKey: key)
    }
    
    func storeImages(images: [UIImage], imageNames: [String], for pid: String, completion: @escaping (Error?) -> ()) {
        var error: Error? = nil
        let uploadGroup = DispatchGroup()
        for (name, image) in zip(imageNames, images) {
            DispatchQueue.global(qos: .utility).async { [self] in
                uploadGroup.enter()
                if let data = image.jpegData(compressionQuality: 0.7) {
                    storage.child(pid + "/\(name)").putData(data, metadata: StorageMetadata(dictionary: ["contentType": "image/jpeg"])) {
                        error = $1
                        uploadGroup.leave()
                    }
                } else { uploadGroup.leave() }
            }
        }
        uploadGroup.notify(queue: .main) {
            completion(error)
        }
    }
}

