//
//  User.swift
//  Picnic
//
//  Created by Kyle Burns on 10/3/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class UserData {
    var rated = [String: Int64]()
    var saved = [String]()
    var profileImage: UIImage?
}

extension UserData {
    static let empty: UserData = UserData()
}


