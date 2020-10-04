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

fileprivate let queryPrecision: Int = 7

final class DatabaseManager: NSObject {
    private let database = Database.database().reference()
    private let storageRef: StorageReference
    init(storagePathURL: String) {
        storageRef = Storage.storage().reference(forURL: storagePathURL)
    }
    
    func store(picnic: Picnic, images: [UIImage], completion: @escaping () -> () = {} ) {
        let taskGroup = DispatchGroup()
        // store picnic
        taskGroup.enter()
        storePicnic(picnic: picnic) { taskGroup.leave() }
        
        // store images for picnic
        taskGroup.enter()
        storeBatchImages(picnic: picnic, images: images) {
            taskGroup.leave()
        }
        
        taskGroup.notify(queue: .main) { completion() }
    }
    
    private func storeBatchImages(picnic: Picnic, images: [UIImage], completion: @escaping () -> ()) {
        let taskGroup = DispatchGroup()
        for (index, image) in images.enumerated() {
            taskGroup.enter()
            storeImage(forPicnic: picnic, withImageName: picnic.imageNames[index], image: image) {
                taskGroup.leave()
            }
        }
        taskGroup.notify(queue: .main) {
            completion()
        }
    }
    
    func image(forPicnic picnic: Picnic, index: Int = 0, maxSize: Int64 = 2 * 1024 * 1024, completion: ((UIImage?, Error?) -> ())? = nil) {
        let ref = storageRef.child(picnic.uid + "/\(picnic.imageNames[index])")
        ref.getData(maxSize: maxSize) { data, error in
            if let error = error {
                print("Error: DatabaseManager: image forPicnic: could not load image from firebase storage: \(error.localizedDescription)")
            }
            guard let data = data else { return }
            completion?(UIImage(data: data), error)
        }
    }
    
    private func storeImage(forPicnic picnic: Picnic, withImageName name: String, image: UIImage, completion: @escaping () -> ()) {
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            print("Error: DatabaseManager: storeImage: could not extract png data from image \(name)")
            return
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let ref = storageRef.child(picnic.uid + "/\(name)")
        
        let _ = ref.putData(data, metadata: metadata) { _, _ in
            completion()
        }
    }
/*
    func deleteImage(for path: String, completion: @escaping () -> ()) {
        DatabaseManager.storage.reference().child("images/" + path).delete { error in
            if let _ = error {
                print("Error: DatabaseManager: Could not delete image \(path)")
                return
            }
            completion()
        }
    }
*/
    
//    func removeAllObservers(picnic: Picnic) {
//        ref.child("Picnics").child(picnic.id).removeAllObservers()
//    }
    
    func createChild(path: String, value: Any) {
        database.child(path).setValue(value)
    }
// MARK: Needs to be tested
    private func storePicnic(picnic: Picnic, completion: @escaping () -> ()) {
//        let value : [String: Any] = [
//            "name": picnic.name,
//            "userDescription": picnic.userDescription,
//            "category": picnic.category,
//            "state": picnic.state,
//            "latitude": picnic.location.latitude,
//            "longitude": picnic.location.longitude,
//            "imageNames": picnic.imageNames,
//            "rating": picnic.rating,
//            "ratingCount": 1,
//            "hash": picnic.locationData?.hash,
//            "city": picnic.city
//            ]
//
        if let picnicData = try? JSONEncoder().encode(picnic),
           let picnicJSON = try? JSONSerialization.jsonObject(with: picnicData) as? [String: Any] {
            database.child("Picnics/\(picnic.uid)").setValue(picnicJSON) { _, _ in
                completion()
            }
        }
    }
// MARK: Needs to be done with a cloud function if possible
    func updateRating(picnic: Picnic, rating: Float, increment: Bool, completion: @escaping () -> () = {}) {
        let ref = database.child("Picnics").child(picnic.uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                print("Error: DatabaseManager: updateRating: 1: Could not retrieve value from \(picnic.uid)")
                return
            }
            guard let cRating = data["rating"] as? Float else {
                print("Error: DatabaseManager: updateRating: 2: Could not retrieve rating from \(picnic.uid)")
                return
            }
            guard let cCount = data["ratingCount"] as? Int else {
                print("Error: DatabaseManager: updateRating: 3: Could not retrieve ratingCount from \(picnic.uid)")
                return
            }
            let inc = increment ? 1 : 0
            let adjustment = increment ? 0 : cRating
            let newRating = (cRating * Float(cCount) + rating - adjustment) / Float(cCount + inc)
            ref.updateChildValues([
                "rating": newRating,
                "ratingCount": cCount + inc
            ])
            completion()
        }
    }
    
    func resetDatabase() {
        print("Enter yes to verify")
        let input = readLine()
        guard let confirm = input else { return }
        if !(confirm == "yes" || confirm == "Yes") { return }
        database.child("Picnics").removeValue()
    }
    
    func picnicQuery(queryLimit: UInt, byKey: String, completion: @escaping ([Picnic]) -> ()) {
        database.child("Picnics").queryLimited(toFirst: 100).observeSingleEvent(of: .value, with: { snapshot in
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
/*
    func deletePicnic(picnic: Picnic, completion: @escaping () -> ()) {
        ref.child("Picnics").child(picnic.id).removeValue { error, ref in
            if let _ = error {
                print("Error: DatabaseManager: deletePicnic: Could not delete picnic \(picnic.name)")
                return
            }
            completion()
        }
    }
 */
// MARK: query by location

    func query(byLocation loc: CLLocation, queryLimit: UInt, precision: Int, completion: @escaping ([Picnic]) -> ()) {
        let hash = Region(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, precision: kDefaultPrecision).hash
        // messy
        let offset: String = String("000000000".dropLast(precision))
        let start = hash.dropLast(kDefaultPrecision - precision) + offset
        let criticalChar = (hash[precision - 1].cString(using: .ascii)?.first!)! + 1
        let modifiedChar = String(bytes: [UInt8(criticalChar)], encoding: .ascii)
        let end = hash.dropLast(kDefaultPrecision - precision + 1) + modifiedChar! + offset
        database.child("Picnics").queryOrdered(byChild: "hash").queryStarting(atValue: start).queryEnding(atValue: end).queryLimited(toFirst: queryLimit).observeSingleEvent(of: .value) { snapshot in
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
    
    func query(coordinate loc: CLLocationCoordinate2D, queryLimit: Int, radius: Float, completion: @escaping ([Picnic]) -> ()) {
        
    }
    
//@available(iOS, unavailable, message: "Does not support geohashing")
//    func query(byCoordinates loc: CLLocationCoordinate2D, queryLimit: Int, completion: @escaping ([Picnic]) -> ()) {
//        loc.getPlacemark { placemark in
//            self.ref.child("Picnics").queryOrdered(byChild: "state").queryEqual(toValue: "AR").observeSingleEvent(of: .value) { snapshot in
//                guard let result = snapshot.children.allObjects as? [DataSnapshot] else {
//                    print("Error: DatabaseManager: query byLocation: Cast failure, possibly no children")
//                    return
//                }
//                let picnics: [Picnic] = result.map { snapshot in
//                    guard let temp = snapshot.value as? [String: Any] else {
//                        print("Error: DatabaseManager: query byLocation: Could not cast snapshot")
//                        return Picnic()
//                    }
//                    return Picnic(fromDictionary: temp)
//                }
//                completion(picnics)
//            }
//        }
//    }
}

