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
    
    func image(for title: String, completion: @escaping (UIImage?, Error?) -> ()) {
        let imageRef = storage.reference(forURL: storagePathURL + title + ".jpg")
//        let imageRef = storage.reference().child("images/" + title + ".jpg")
        imageRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error: DatabaseManager: image: could not load image from firebase storage: \(error.localizedDescription)")
                return
            }
            print(UIImage(data: data!)!.size)
            completion(UIImage(data: data!), error)
        }
    }
    func storeImage(for title: String, image: UIImage, completion: @escaping () -> ()) {
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            print("Error: DatabaseManager: storeImage: could not extract png data from image \"\(title)\"")
            return
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imageRef = storage.reference().child("images/" + title + ".jpg")
        let _ = imageRef.putData(data, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                print("Error: DatabaseManager: storeImage: metadata nil")
                return
            }
            
            completion()
        }
        
    }
    
    func removeAllObservers(picnic: Picnic) {
        db.child("Picnics").child(picnic.id).removeAllObservers()
    }
    
    func storePicnic(picnic: Picnic, completion: @escaping (Picnic, DatabaseReference) -> ()) {
        let value : [String: Any] = [
            "name": picnic.name,
            "userDescription": picnic.userDescription,
            "category": picnic.category,
            "state": picnic.state,
            "latitude": picnic.location.latitude,
            "longitude": picnic.location.longitude,
            "imageName": picnic.imageName
            ]
        
        db.child("Picnics").child(picnic.id).setValue(value, withCompletionBlock: { error, ref in
            if let _ = error {
                print("Error: error uploading picnic")
            } else {
                print("DatabaseManager: storePicnic: Successfully reached completion closure with picnic \(picnic.name)")
                completion(picnic, ref)
            }
        })
    }
    
    // will need rework.. definitely
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
            print("DatabaseManager: picnic: Successfully reached completion closure with locations count \(locations.count)")
            completion(locations)
        })
    }
}

let dbManager = DatabaseManager(storagePathURL: "gs://picnic-1c64f.appspot.com/images/")

