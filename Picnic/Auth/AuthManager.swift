//
//  AuthManager.swift
//  Picnic
//
//  Created by Kyle Burns on 7/30/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseUI


class AuthManager: NSObject {
    
    let authUI = FUIAuth.defaultAuthUI()
    
    override init() {
        super.init()
        let providers: [FUIAuthProvider] = [
            FUIEmailAuth(),
            FUIPhoneAuth(authUI: authUI!),
            FUIAnonymousAuth(authUI: authUI!)
        ]
        authUI?.delegate = self
        authUI?.providers = providers
        authUI?.shouldHideCancelButton = true
    }
}

extension AuthManager: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            print("Error: TabController: authUI didSignInWith: \(error.localizedDescription)")
            return
        }
        if let data = authDataResult {
            if let _ = data.additionalUserInfo?.isNewUser {
                Shared.shared.databaseManager.addUser(uid: data.user.uid)
            }
        }
        UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return AuthPicker(authUI: authUI)
    }
}
