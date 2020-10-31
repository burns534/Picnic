//
//  PicnicManager.swift
//  Picnic
//
//  Created by Kyle Burns on 10/26/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseFirestore

class PicnicManager: DatabaseManager {
    static let `default` = PicnicManager(reference: Firestore.firestore().collection("Picnics"))
        
    func picnicQuery(_ key: String) -> PicnicQuery? {
        queries[key] as? PicnicQuery
    }
    
    func store(picnic: Picnic, images: [UIImage], completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .default).async { [self] in
            let uploadGroup = DispatchGroup()
            uploadGroup.enter()
            guard let ref = try? reference.addDocument(from: picnic, completion: { _ in uploadGroup.leave() }),
                  let imageNames = picnic.imageNames
            else { return }
            uploadGroup.enter()
            storeImages(images: images, imageNames: imageNames, for: ref.documentID) { _ in
                uploadGroup.leave()
            }
            uploadGroup.notify(queue: .main) { completion() }
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

    func updateRating(pid: String, value: Int64, completion: ((Error?) -> ())? = nil) {
        var error: Error? = nil
        let taskGroup = DispatchGroup()
        taskGroup.enter()
        UserManager.default.updateRating(for: pid, value: value) {
            if let err = $0 {
                error = err
            }
            taskGroup.leave()
        }
        let oldValue = UserManager.default.userData.getRating(for: pid)
        DispatchQueue.global(qos: .utility).async { [self] in
            taskGroup.enter()
            reference.document(pid).updateData([
                "totalRating": FieldValue.increment(value - oldValue),
                "ratingCount": FieldValue.increment(Int64(1))
            ]) {
                error = $0
                taskGroup.leave()
            }
        }
        taskGroup.notify(queue: .main) {
            completion?(error)
        }
    }
    
// MARK: Query Methods
// TODO: Change this to return the first page after query is added
    func addPicnicQuery(params: [QueryParameter: Any], key queryKey: String) {
        queries[queryKey] = PicnicQuery(collection: reference, params: params)
    }
    
    func refreshPage(for key: String, completion: (([Picnic]) -> ())?) {
        guard let query = queries[key] as? PicnicQuery else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            query.current.getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let picnics = snapshot?.documents.compactMap({ try? $0.data(as: Picnic.self) }) {
                    completion?(picnics.compactMap {
                        if let tags = query.tags {
                            if $0.tags == nil { return nil }
                            if let container = $0.tags,
                               !container.satisfies(tags) {
                                return nil
                            }
                        }
                        return $0.location.distance(from: query.location) > query.radius * 1000 ? nil : $0
                    })
                }
            }
        }
    }
    
    func nextPage(for key: String, completion: (([Picnic]) -> ())?) {
        guard let query = queries[key] as? PicnicQuery else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            query.next().getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let picnics = snapshot?.documents.compactMap({ try? $0.data(as: Picnic.self) }), let next = snapshot?.documents.last {
                    query.pushDocument(next)
                    completion?(picnics.compactMap {
                        if let tags = query.tags {
                            if $0.tags == nil { return nil }
                            if let container = $0.tags,
                               !container.satisfies(tags) {
                                return nil
                            }
                        }
                        return $0.location.distance(from: query.location) > query.radius * 1000 ? nil : $0
                    })
                }
            }
        }
    }
    
    func query(byName name: String, completion: (([Picnic]) -> ())?) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            reference.whereField("name", isEqualTo: name).getDocuments { snapshot, error in
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
    
    
}
