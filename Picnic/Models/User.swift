//
//  User.swift
//  Picnic
//
//  Created by Kyle Burns on 10/3/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation
struct User: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        isAnonymous = try container.decode(Bool.self, forKey: .isAnonymous)
    }
    
    init(uid: String?, isAnonymous: Bool) {
        self.uid = uid
        self.isAnonymous = isAnonymous
    }
    
    var uid: String?
    var isAnonymous: Bool
    var rated: [String] = []
    var saved: [String] = []

    enum CodingKeys: String, CodingKey {
        case uid, isAnonymous
    }
}

extension User: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(isAnonymous, forKey: .isAnonymous)
    }
}
