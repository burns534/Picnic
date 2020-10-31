//
//  ReviewManager.swift
//  Picnic
//
//  Created by Kyle Burns on 10/26/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseFirestore

class ReviewManager: DatabaseManager {
    static let `default` = ReviewManager(reference: Firestore.firestore().collection("Reviews"))
    func submitReview(review: Review, images: [UIImage]? = nil, completion: (() -> ())? = nil) {
        guard let images = images,
              let imageNames = review.imageNames
        else { return }
        let taskGroup = DispatchGroup()
        DispatchQueue.global(qos: .utility).async { [self] in
            taskGroup.enter()
            _ = try? reference.addDocument(from: review) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
                taskGroup.leave()
            }
        }
// FIXME: I don't think these need to be dispatched on the global queue since the actual network task is dispatched inside the function bodies. Couldn't find anything online
        taskGroup.enter()
        storeImages(images: images, imageNames: imageNames, for: review.pid) { _ in
            taskGroup.leave()
        }
        
        taskGroup.enter()
        UserManager.default.updateRating(for: review.pid, value: Int64(review.rating)) { _ in
            taskGroup.leave()
        }
        
        taskGroup.notify(queue: .main) {
            completion?()
        }
    }
    
    func addReviewQuery(for key: String, limit: Int, picnic: Picnic) {
        guard let id = picnic.id else { return }
        let query = reference.whereField("pid", isEqualTo: id)
        queries[key] = PaginatedQuery(query: query, limit: limit)
    }
    
    func nextPage(for key: String, completion: (([Review]) -> ())?) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            queries[key]?.next().getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let reviews = snapshot?.documents.compactMap({
                    try? $0.data(as: Review.self)
                }), let next = snapshot?.documents.last {
                    queries[key]?.pushDocument(next)
                    completion?(reviews)
                }
            }
        }
    }
    
    func refresh(for key: String, completion: (([Review]) -> ())?) {
        queries[key]?.next().getDocuments { snapshot, error in
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
