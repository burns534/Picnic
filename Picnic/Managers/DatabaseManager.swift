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
import MapKit

fileprivate let queryPrecision: Int = 7

final class DatabaseManager: NSObject {
    private let database = Firestore.firestore()
    private let storage: StorageReference
    init(storagePathURL: String) {
        storage = Storage.storage().reference(forURL: storagePathURL)
    }
    
    func store(picnic: Picnic, images: [UIImage], completion: @escaping () -> ()) {
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            let uploadGroup = DispatchGroup()
            uploadGroup.enter()
            
            guard let ref = try? self?.database.collection("Picnics").addDocument(from: picnic, completion: { _ in uploadGroup.leave() }) else { return }
            
            for (name, image) in zip(picnic.imageNames, images) {
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

    func image(forPicnic picnic: Picnic, index: Int = 0, maxSize: Int64 = 2 * 1024 * 1024, completion: ((UIImage?, Error?) -> ())? = nil) {
        guard let id = picnic.id else { return }
        storage.child(id).child(picnic.imageNames[index]).getData(maxSize: maxSize) { data, error in
            if let error = error {
                print("Error: DatabaseManager: image forPicnic: could not load image from firebase storage: \(error.localizedDescription)")
            }
            guard let data = data else { return }
            completion?(UIImage(data: data), error)
        }
    }
    
// MARK: Needs to be done with a cloud function if possible
    func updateRating(picnic: Picnic, newRating: Float, completion: @escaping () -> () = {}) {
        guard let id = picnic.id else { return }
        DispatchQueue.global().async { [weak self] in
            self?.database.collection("Picnics").document(id).getDocument { document, error in
                if let error = error { print(error.localizedDescription) }
                else if let ratingCount = document?.data()?["ratingCount"] as? Float,
                        let rating = document?.data()?["rating"] as? Float {
                    self?.database.collection("Picnics").document(id).updateData([
                        "rating": (rating * ratingCount + newRating) / (1.0 + ratingCount),
                        "ratingCount": Int(ratingCount + 1)
                    ]) { _ in completion() }
                }
            }
        }
    }
    
// MARK: query by location

    func query(byLocation loc: CLLocation, queryLimit: Int, precision: Int, completion: @escaping ([Picnic]) -> ()) {
        let hash = Region(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, precision: kDefaultPrecision).hash
        // messy
        let offset: String = String("000000000".dropLast(precision))
        let start = hash.dropLast(kDefaultPrecision - precision) + offset
        let criticalChar = (hash[precision - 1].cString(using: .ascii)?.first!)! + 1
        let modifiedChar = String(bytes: [UInt8(criticalChar)], encoding: .ascii)
        let end = hash.dropLast(kDefaultPrecision - precision + 1) + modifiedChar! + offset
        database.collection("Picnics").whereField("geohash", isGreaterThanOrEqualTo: start).whereField("geohash", isLessThan: end).limit(to: queryLimit).getDocuments { snapshot, error in
            if let error = error { print(error.localizedDescription) }
            else {
                completion(snapshot!.documents.compactMap {
                    try? $0.data(as: Picnic.self)
                })
            }
        }
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

