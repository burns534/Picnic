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
    var skipButton: UIButton!

    init(authUI: FUIAuth) {
        super.init(nibName: nil, bundle: nil, authUI: authUI)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        if (!authUI.shouldHideCancelButton) {
            let cancelButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skipButtonHandler))
            cancelButton.tintColor = .olive
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
        
        let count = CGFloat(authUI.providers.count)
        
        NSLayoutConstraint.activate([
            buttonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonView.heightAnchor.constraint(lessThanOrEqualToConstant: kSignInButtonVerticalMargin * (1 + count * kSignInButtonHeight)),
            buttonView.widthAnchor.constraint(equalToConstant: kSignInButtonWidth)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        return
    }
    
    @objc func skipButtonHandler(_ sender: UIBarButtonItem) {
        Shared.shared.user.isAnonymous = true
        dismiss(animated: true)
    }
}
