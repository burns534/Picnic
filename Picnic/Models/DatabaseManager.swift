//
//  DatabaseManager.swift
//  Picnic
//
//  Created by Kyle Burns on 6/1/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseStorage
import FirebaseDatabase

class DatabaseManager {
    private let storage = Storage.storage()
    private var storagePathURL: String
    private let db = Database.database().reference()
    init(storagePathURL: String) {
        self.storagePathURL = storagePathURL
    }
    
    func store(picnic: Picnic, images: [UIImage], picnicCompletion: @escaping (Picnic, DatabaseReference) -> () = {_,_ in}, imageCompletion: @escaping () -> () = {}, completion: @escaping () -> () = {} ) {
        
        let taskGroup = DispatchGroup()
        // store picnic
        taskGroup.enter()
        storePicnic(picnic: picnic) { picnic, ref in
            picnicCompletion(picnic, ref)
            taskGroup.leave()
        }
        
        // store images for picnic
        taskGroup.enter()
        storeBatchImages(path: picnic.id, idList: picnic.imageNames, images: images) {
            imageCompletion()
            taskGroup.leave()
        }
        
        taskGroup.notify(queue: .main) {
            completion()
        }
    }
    
    func storeBatchImages(path: String, idList: [String], images: [UIImage], completion: @escaping () -> () = { } ) {
        let taskGroup = DispatchGroup()
        
        for (index, image) in images.enumerated() {
            taskGroup.enter()
            storeImage(for: path + "/\(idList[index])", image: image) { metadata, error in
                taskGroup.leave()
            }
        }
        taskGroup.notify(queue: .main) {
            completion()
        }
    }
    func image(forPicnic: Picnic, index: Int = 0, maxSize: Int64 = 2 * 1024 * 1024, completion: @escaping (UIImage?, Error?) -> () = {_,_ in}) {
        let imageRef = storage.reference(forURL: storagePathURL + forPicnic.id + "/\(forPicnic.imageNames[index])")
        
        imageRef.getData(maxSize: maxSize) { data, error in
            if let error = error {
                print("Error: DatabaseManager: image forPicnic: could not load image from firebase storage: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }
            completion(UIImage(data: data), error)
        }
    }
    
    func image(forPath: String, completion: @escaping (UIImage?, Error?) -> () = {_, _ in}) {
        let imageRef = storage.reference(forURL: storagePathURL + forPath)
        
        imageRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error: DatabaseManager: image forPath: could not load image from firebase storage: \(error.localizedDescription)")
                return
            }
            completion(UIImage(data: data!), error)
        }
    }
    func storeImage(for path: String, image: UIImage, completion: @escaping (StorageMetadata?, Error?) -> () = {_, _ in}) {
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            print("Error: DatabaseManager: storeImage: could not extract png data from image \"\(path)\"")
            return
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imageRef = storage.reference().child("images/" + path)
        let _ = imageRef.putData(data, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                print("Error: DatabaseManager: storeImage: metadata nil")
                return
            }
            completion(metadata, error)
        }
        
    }
    
    func deleteImage(for path: String, completion: @escaping () -> ()) {
        storage.reference().child("images/" + path).delete { error in
            if let _ = error {
                print("Error: DatabaseManager: Could not delete image \(path)")
                return
            }
            completion()
        }
    }
    
    func removeAllObservers(picnic: Picnic) {
        db.child("Picnics").child(picnic.id).removeAllObservers()
    }
    
    func createChild(path: String, value: Any) {
        db.child(path).setValue(value)
    }
    
    func storePicnic(picnic: Picnic, completion: @escaping (Picnic, DatabaseReference) -> ()) {
        let value : [String: Any] = [
            "name": picnic.name,
            "userDescription": picnic.userDescription,
            "category": picnic.category,
            "state": picnic.state,
            "latitude": picnic.location.latitude,
            "longitude": picnic.location.longitude,
            "imageNames": picnic.imageNames,
            "rating": picnic.rating
            ]
        
        db.child("Picnics").child(picnic.id).setValue(value, withCompletionBlock: { error, ref in
            if let _ = error {
                print("Error: error uploading picnic")
            } else {
                completion(picnic, ref)
            }
        })
    }
    
    func picnic(completion: @escaping ([Picnic]) -> ()) {
        db.child("Picnics").queryLimited(toFirst: 100).observeSingleEvent(of: .value, with: { snapshot in
            guard let objects = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Error: DatabaseManager: picnic: Could not download objects from child \"Picnics\"")
                return
            }
            let dict: [[String: Any]] = objects.map { snapshot in
                guard var temp = snapshot.value as? [String: Any] else {
                    print("Error: DatabaseManager: picnic: Could not cast")
                    return ["" : ""]
                }
                // add id value to dictionary
                temp["key"] = snapshot.key
                // return complete dictionary entry from map
                return temp
            }
            
            let locations : [Picnic] = dict.map { dictionary in
                Picnic(fromDictionary: dictionary)
            }
            completion(locations)
        })
    }

    func deletePicnic(picnic: Picnic, completion: @escaping () -> ()) {
        db.child("Picnics").child(picnic.id).removeValue { error, ref in
            if let _ = error {
                print("Error: DatabaseManager: deletePicnic: Could not delete picnic \(picnic.name)")
                return
            }
            completion()
        }
    }
    
}

let dbManager = DatabaseManager(storagePathURL: "gs://picnic-1c64f.appspot.com/images/")

let locationManager = LocationManager()
