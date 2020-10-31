//
//  Shared.swift
//  Picnic
//
//  Created by Kyle Burns on 7/31/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseAuth

final class Managers {
    static let shared = Managers()
    let locationManager = LocationManager()
    let auth = Auth.auth()
}

extension Auth {
    func shouldRequestLogin() -> Bool {
        currentUser == nil || currentUser!.isAnonymous
    }
}

