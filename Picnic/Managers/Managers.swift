//
//  Shared.swift
//  Picnic
//
//  Created by Kyle Burns on 7/31/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//



final class Managers {
    static let shared = Managers()
    let databaseManager = DatabaseManager()
    let locationManager = LocationManager()
    let authManager = AuthManager()
    
    private init() {
        databaseManager.configure()
        locationManager.configure()
    }
}

