//
//  AuthManager.swift
//  Picnic
//
//  Created by Kyle Burns on 7/30/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseUI
import GoogleSignIn


//protocol AuthManagerDelegate: AnyObject {
//    func didSignIn()
//}
// // TODO: Need to add phone, facebook, and apple auth
//final class AuthManager: NSObject {
//
//    weak var delegate: AuthManagerDelegate?
//
//    func configure() {
//        let authUI = FUIAuth.defaultAuthUI()
//        authUI?.delegate = self
//        authUI?.providers = [
//            FUIEmailAuth(),
//            FUIGoogleAuth()
//        ]
//    }
//}
//
//extension AuthManager: FUIAuthDelegate {
//    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
//        if let error = error {
//            print("Error: TabController: authUI didSignInWith: \(error.localizedDescription)")
//        } else {
//            Managers.shared.databaseManager.signIn()
//        }
//    }
//
//    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
//        AuthPicker(authUI: authUI)
//    }
//}

