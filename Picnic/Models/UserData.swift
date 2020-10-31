//
//  User.swift
//  Picnic
//
//  Created by Kyle Burns on 10/3/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class UserData {
    private var rated = [String: Int64]()
//    private var saved = [String]()
    var profileImage: UIImage?
    var userBio: String?
    
    func getRating(for key: String) -> Int64 {
        rated[key] ?? 0
    }
    
    func setRated(_ dictionary: [String: Int64]) {
        rated = dictionary
    }
//
//    func getSaved(for key: String) -> Bool {
//        saved[key] != nil
//    }
}

extension UserData {
    static let empty: UserData = UserData()
}


