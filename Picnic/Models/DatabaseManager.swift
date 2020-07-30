//
//  DatabaseManager.swift
//  Picnic
//
//  Created by Kyle Burns on 6/1/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseStorage
import FirebaseDatabase
import MapKit

fileprivate let defaultPrecision: Int = 7

class DatabaseManager {
    private static let storage = Storage.storage()
    private var storagePathURL: String
    private let ref = Database.database().reference()
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
        let imageRef = DatabaseManager.storage.reference(forURL: storagePathURL + forPicnic.id + "/\(forPicnic.imageNames[index])")
        
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
        let imageRef = DatabaseManager.storage.reference(forURL: storagePathURL + forPath)
        
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
        let imageRef = DatabaseManager.storage.reference().child("images/" + path)
        let _ = imageRef.putData(data, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                print("Error: DatabaseManager: storeImage: metadata nil")
                return
            }
            completion(metadata, error)
        }
        
    }
    
    func deleteImage(for path: String, completion: @escaping () -> ()) {
        DatabaseManager.storage.reference().child("images/" + path).delete { error in
            if let _ = error {
                print("Error: DatabaseManager: Could not delete image \(path)")
                return
            }
            completion()
        }
    }
    
    func removeAllObservers(picnic: Picnic) {
        ref.child("Picnics").child(picnic.id).removeAllObservers()
    }
    
    func createChild(path: String, value: Any) {
        ref.child(path).setValue(value)
    }
    
    func storePicnic(picnic: Picnic, completion: @escaping (Picnic, DatabaseReference) -> ()) {
        let hash = Region(latitude: picnic.location.latitude, longitude: picnic.location.longitude, precision: 9).hash
        let value : [String: Any] = [
            "name": picnic.name,
            "userDescription": picnic.userDescription,
            "category": picnic.category,
            "state": picnic.state,
            "latitude": picnic.location.latitude,
            "longitude": picnic.location.longitude,
            "imageNames": picnic.imageNames,
            "rating": picnic.rating,
            "hash": hash
            ]
        
        ref.child("Picnics").child(picnic.id).setValue(value, withCompletionBlock: { error, ref in
            if let _ = error {
                print("Error: error uploading picnic")
            } else {
                completion(picnic, ref)
            }
        })
    }
    
    func updateRating(picnic: Picnic, rating: Float, completion: @escaping ()->()) {
        let pRef = ref.child("Picnics").child(picnic.id)
        pRef.observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                print("Error: DatabaseManager: updateRating: Could not retrieve value from \(picnic.id)")
                return
            }
            guard let cRating = data["rating"] as? Float else {
                print("Error: DatabaseManager: updateRating: Could not retrieve rating from \(picnic.id)")
                return
            }
            guard let cCount = data["ratingCount"] as? Int else {
                print("Error: DatabaseManager: updateRating: Could not retrieve ratingCount from \(picnic.id)")
                return
            }
            let newRating = (cRating * Float(cCount) + rating) / Float(cCount + 1)
            pRef.updateChildValues([
                "rating": newRating,
                "ratingCount": cRating + 1
            ])
        }
    }
    
    func resetDatabase() {
        print("Enter yes to verify")
        let input = readLine()
        guard let confirm = input else { return }
        if !(confirm == "yes" || confirm == "Yes") { return }
        ref.child("Picnics").removeValue()
    }
    
    func picnicQuery(queryLimit: UInt, byKey: String, completion: @escaping ([Picnic]) -> ()) {
        ref.child("Picnics").queryLimited(toFirst: 100).observeSingleEvent(of: .value, with: { snapshot in
            guard let objects = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Error: DatabaseManager: picnic: Could not download objects from child Picnics")
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
        ref.child("Picnics").child(picnic.id).removeValue { error, ref in
            if let _ = error {
                print("Error: DatabaseManager: deletePicnic: Could not delete picnic \(picnic.name)")
                return
            }
            completion()
        }
    }
// MARK: query by location

    func query(byLocation loc: CLLocation, queryLimit: UInt, precision: Int, completion: @escaping ([Picnic]) -> ()) {
        let hash = Region(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, precision: defaultPrecision).hash
        // messy
        let offset: String = String("000000000".dropLast(precision))
        let start = hash.dropLast(defaultPrecision - precision) + offset
        let criticalChar = (hash[precision - 1].cString(using: .ascii)?.first!)! + 1
        let modifiedChar = String(bytes: [UInt8(criticalChar)], encoding: .ascii)
        let end = hash.dropLast(defaultPrecision - precision + 1) + modifiedChar! + offset
        ref.child("Picnics").queryOrdered(byChild: "hash").queryStarting(atValue: start).queryEnding(atValue: end).queryLimited(toFirst: queryLimit).observeSingleEvent(of: .value) { snapshot in
            guard let result = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Error: DatabaseManager: query byLocation: Cast failure, possibly no children")
                return
            }
            let picnics: [Picnic] = result.map { snapshot in
                guard var temp = snapshot.value as? [String: Any] else {
                    print("Error: DatabaseManager: query byLocation: Could not cast snapshot")
                    return Picnic()
                }
                temp["key"] = snapshot.key
                return Picnic(fromDictionary: temp)
            }
            completion(picnics)
        }
    }
    
    func query(byCoordinates loc: CLLocationCoordinate2D, queryLimit: Int, completion: @escaping ([Picnic]) -> ()) {
        loc.getPlacemark { placemark in
            self.ref.child("Picnics").queryOrdered(byChild: "state").queryEqual(toValue: "AR").observeSingleEvent(of: .value) { snapshot in
                guard let result = snapshot.children.allObjects as? [DataSnapshot] else {
                    print("Error: DatabaseManager: query byLocation: Cast failure, possibly no children")
                    return
                }
                let picnics: [Picnic] = result.map { snapshot in
                    guard let temp = snapshot.value as? [String: Any] else {
                        print("Error: DatabaseManager: query byLocation: Could not cast snapshot")
                        return Picnic()
                    }
                    return Picnic(fromDictionary: temp)
                }
                completion(picnics)
            }
        }
    }
    
    func addUser(uid: String) {
        ref.child("Users").child(uid).setValue(["posts": 0])
    }
}

//let dbManager = DatabaseManager(storagePathURL: "gs://picnic-1c64f.appspot.com/images/")

//let locationManager = LocationManager()
