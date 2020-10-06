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

final class PicnicManager: NSObject {
    private let picnics: CollectionReference = Firestore.firestore().collection("Picnics")
    private let storage: StorageReference
    init(storagePathURL: String) {
        storage = Storage.storage().reference(forURL: storagePathURL)
    }
    
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

    func image(forPicnic picnic: Picnic, index: Int = 0, maxSize: Int64 = 2 * 1024 * 1024, completion: ((UIImage?, Error?) -> ())? = nil) {
        guard let id = picnic.id, let imageNames = picnic.imageNames else { return }
        storage.child(id).child(imageNames[index]).getData(maxSize: maxSize) { data, error in
            if let error = error {
                print("Error: DatabaseManager: image forPicnic: could not load image from firebase storage: \(error.localizedDescription)")
            }
            guard let data = data else { return }
            completion?(UIImage(data: data), error)
        }
    }
    
// MARK: Needs to be done with a cloud function if possible
    func updateRating(picnic: Picnic, value: Float, completion: @escaping () -> () = {}) {
        guard let id = picnic.id else { return }
        DispatchQueue.global().async { [weak self] in
            self?.picnics.document(id).getDocument { document, error in
                if let error = error { print(error.localizedDescription) }
                else if let ratingCount = document?.data()?["ratingCount"] as? Float,
                        let rating = document?.data()?["rating"] as? Float {
                    self?.picnics.document(id).updateData([
                        "rating": (rating * ratingCount + value) / (1.0 + ratingCount),
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
        DispatchQueue.global().async { [weak self] in
            self?.picnics.whereField("geohash", isGreaterThanOrEqualTo: start).whereField("geohash", isLessThan: end).limit(to: queryLimit).getDocuments { snapshot, error in
                if let error = error { print(error.localizedDescription) }
                else {
                    completion(snapshot!.documents.compactMap {
                        try? $0.data(as: Picnic.self)
                    })
                }
            }
        }
    }
}

