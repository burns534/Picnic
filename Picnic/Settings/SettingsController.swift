//
//  SettingsController.swift
//  Picnic
//
//  Created by Kyle Burns on 7/29/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseUI

class SettingsController: UIViewController {
    
    var logoutButton: UIButton!
    var authUI: FUIAuth
    
    init(auth: FUIAuth) {
        authUI = auth
        super.init(nibName: nil, bundle: nil)
        title = "Settings"
        tabBarItem.image = UIImage(systemName: "gear")
    }
    
    init() {
        authUI = FUIAuth.defaultAuthUI()!
        super.init(nibName: nil, bundle: nil)
        title = "Settings"
        tabBarItem.image = UIImage(systemName: "gear")
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        
        logoutButton = UIButton()
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.red, for: .normal)
        logoutButton.isSpringLoaded = true
        logoutButton.showsTouchWhenHighlighted = true
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 60),
            logoutButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc func logout(_ sender: UIButton) {
        do {
            try authUI.signOut()
        } catch {
            print("Error: SettingsController: logout: Could not sign out user")
            return
        }
        UserDefaults.standard.setValue(false, forKey: "isLoggedIn")
        tabBarController?.selectedIndex = 0
        let vc = authUI.authViewController()
        vc.isModalInPresentation = true
        present(vc, animated: true)
    }
}
