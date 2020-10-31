//
//  TagContainer.swift
//  Picnic
//
//  Created by Kyle Burns on 10/18/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation
/* This ended up being uneccessary because firestore has such weak querying. I couldn't create the necessary compound queries so the necessary filtering is now performed client-side when needed.
 Basically this could be replaced with an array
 */
struct TagContainer: Codable {
    var trail: Bool = false
    var waterfall: Bool = false
    var lake: Bool = false
    var river: Bool = false
    var kidFriendly: Bool = false
    var walking: Bool = false
    var hiking: Bool = false
    var running: Bool = false
    var forest: Bool = false
    var view: Bool = false
    var wheelchairAccessible: Bool = false
    var bugs: Bool = false
    var overgrown: Bool = false
    var wildflowers: Bool = false
    var wildlife: Bool = false
    var mountainBiking: Bool = false
    var rocky: Bool = false
    var paved: Bool = false
    var roadBiking: Bool = false
    var petFriendly: Bool = false
    var secluded: Bool = false
    var localSecret: Bool = false
    var park: Bool = false
    
    init(_ array: [PicnicTag]?) {
        array?.forEach { self[keyPath: $0.keyPath] = true }
    }

    var tags: [PicnicTag] {
        PicnicTag.allCases.compactMap {
            self[keyPath: $0.keyPath] ? $0 : nil
        }
    }
    
    func satisfies(_ tags: [PicnicTag]) -> Bool {
        for tag in tags {
            if !self[keyPath: tag.keyPath] {
                return false
            }
        }
        print("Returning true")
        return true
    }
}
