//
//  Shared.swift
//  Picnic
//
//  Created by Kyle Burns on 7/31/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation


final class Shared {
    static let shared = Shared()
    let databaseManager = DatabaseManager(storagePathURL: "gs://picnic-1c64f.appspot.com/images")
    let locationManager = LocationManager()
    let authManager: AuthManager
    let userManager: UserManager
    
    private init() {
        authManager = AuthManager()
        userManager = UserManager()
    }
}

