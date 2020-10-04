//
//  AuthManager.swift
//  Picnic
//
//  Created by Kyle Burns on 7/30/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseUI
import GoogleSignIn


protocol AuthManagerDelegate: AnyObject {
    func didSignIn()
}

final class AuthManager: NSObject {
    
    let authUI = FUIAuth.defaultAuthUI()
    
    weak var delegate: AuthManagerDelegate?
    
    override init() {
        super.init()
        let providers: [FUIAuthProvider] = [
            FUIEmailAuth(),
            FUIPhoneAuth(authUI: authUI!),
            FUIGoogleAuth()
        ]
        authUI?.delegate = self
        authUI?.providers = providers
    }
    
}

extension AuthManager: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            print("Error: TabController: authUI didSignInWith: \(error.localizedDescription)")
            return
        }
        if let data = authDataResult {
            Shared.shared.userManager.login(uid: data.user.uid, isAnonymous: data.user.isAnonymous)
        }
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        delegate?.didSignIn()
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return AuthPicker(authUI: authUI)
    }
}

