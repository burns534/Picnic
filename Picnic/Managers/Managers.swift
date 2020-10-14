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
    let databaseManager = DatabaseManager()
    let locationManager = LocationManager()
    let auth = Auth.auth()
    private init() {
        databaseManager.configure()
        locationManager.configure()
        _ = Auth.auth().addStateDidChangeListener { _, user in
            if user != nil {
                self.databaseManager.configure()
            }
        }
    }
}

extension Auth {
    func shouldRequestLogin() -> Bool {
        currentUser == nil || currentUser!.isAnonymous
    }
}

