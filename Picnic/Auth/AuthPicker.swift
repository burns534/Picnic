//
//  AuthPicker.swift
//  Picnic
//
//  Created by Kyle Burns on 7/29/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseUI

class AuthPicker: FUIAuthPickerViewController {
    
    var buttonView: ButtonView!

    init(authUI: FUIAuth) {
        super.init(nibName: nil, bundle: nil, authUI: authUI)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
//        super.viewDidLoad()
        view.backgroundColor = .white
        
        if (!authUI.shouldHideCancelButton) {
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            navigationItem.leftBarButtonItem = cancelButton
        }
        
        if #available(iOS 13, *) {
            if (!authUI.isInteractiveDismissEnabled) {
                self.isModalInPresentation = true
            }
        }
        
        buttonView = ButtonView(sender: self)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonView)
        
        NSLayoutConstraint.activate([
            buttonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
// MARK: Fix
// height should be a function of number of sign-in options
            buttonView.heightAnchor.constraint(equalToConstant: 400),
            buttonView.widthAnchor.constraint(equalToConstant: kSignInButtonWidth)
        ])
    }
    
    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
        return
    }
    
    @objc func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
        
    }
}
