//
//  Tab ControllerViewController.swift
//  Picnic
//
//  Created by Kyle Burns on 5/25/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
import FirebaseUI
import GoogleSignIn

//class AnonymousAuth: NSObject, FUIAuthProvider {
//    var providerID: String?
//
//    var shortName: String {
//        "Anonymous"
//    }
//
//    var signInLabel: String {
//        "Sign in anonymously"
//    }
//
//    var icon: UIImage {
//        UIImage(systemName: "person")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
//    }
//
//    var buttonBackgroundColor: UIColor = .gray
//
//    var buttonTextColor: UIColor =
//
//    var buttonAlignment: FUIButtonAlignment
//
//    func signIn(withEmail email: String?, presenting presentingViewController: UIViewController?, completion: FUIAuthProviderSignInCompletionBlock? = nil) {
//        <#code#>
//    }
//
//    func signIn(withDefaultValue defaultValue: String?, presenting presentingViewController: UIViewController?, completion: FUIAuthProviderSignInCompletionBlock? = nil) {
//        <#code#>
//    }
//
//    func signOut() {
//        <#code#>
//    }
//
//    var accessToken: String?
//}

class TabController: UITabBarController {
    
    let authUI = FUIAuth.defaultAuthUI()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let controllers = [Featured(), SearchController(), LocationSelector(), Profile(), SettingsController()]
        
        viewControllers = controllers.map { UINavigationController(rootViewController: $0) }
    
        let titles = ["Featured", "Search", "New", "Profile", "Settings"]
        let imageNames = ["star", "magnifyingglass", "plus.square", "person", "gear"]
        for (index, item) in tabBar.items!.enumerated() {
            item.image = UIImage(systemName: imageNames[index])
            item.title = titles[index]
        }
        
        selectedIndex = 0
        authUI.delegate = self
        authUI.providers = [
            FUIEmailAuth(),
            FUIGoogleAuth()
        ]
    }

    override func viewDidAppear(_ animated: Bool) {
        if Managers.shared.auth.shouldRequestLogin() {
            present(authUI.authViewController(), animated: true)
        }
    }
    
    @objc func cancelButton() {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        dismiss(animated: true)
    }
}

extension TabController: FUIAuthDelegate {
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let vc = FUIAuthPickerViewController(authUI: authUI)
        let skipButton = UIBarButtonItem()
        skipButton.title = "Skip"
        skipButton.target = self
        skipButton.action = #selector(cancelButton)
        vc.navigationItem.leftBarButtonItem = skipButton
        return vc
    }
}
