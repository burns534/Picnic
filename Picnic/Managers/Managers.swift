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
    private var handle: AuthStateDidChangeListenerHandle!
    private var profileImage: UIImage?
    private init() {
        databaseManager.configure()
        locationManager.configure()
        handle = Auth.auth().addStateDidChangeListener { _, user in
            if user != nil {
                self.databaseManager.configure()
            }
        }
    }
    
    deinit { Auth.auth().removeStateDidChangeListener(handle) }
    
    func getProfileImage(completion: @escaping (UIImage?) -> ()){
        if profileImage == nil {
            DispatchQueue.global(qos: .default).async { [self] in
                if let url = Auth.auth().currentUser?.photoURL,
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                    profileImage = image
                }
            }
        } else {
            completion(self.profileImage)
        }
    }
}

extension Auth {
    func shouldRequestLogin() -> Bool {
        currentUser == nil || currentUser!.isAnonymous
    }
}

