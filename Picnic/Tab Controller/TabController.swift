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

class TabController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
        
        let controllers = [Featured(collectionViewLayout: CustomFlowLayout()), Profile(), SettingsController()]
        
        viewControllers = controllers.map {
            UINavigationController(rootViewController: $0)
        }
        
        selectedIndex = 0
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    // Must be presented in viewDidAppear because window hierarchy is established between viewWillAppear and viewDidAppear.
    override func viewDidAppear(_ animated: Bool) {
        guard let vc = Shared.shared.authManager.authUI?.authViewController() else {
            print("Error: TabController: viewDidAppear: viewController nil")
            return
        }
        vc.isModalInPresentation = true
        
        if !UserDefaults.standard.bool(forKey: "isLoggedIn") {
            present(vc, animated: true)
        }
    }
}

