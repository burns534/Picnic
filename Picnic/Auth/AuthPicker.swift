////
////  AuthPicker.swift
////  Picnic
////
////  Created by Kyle Burns on 7/29/20.
////  Copyright © 2020 Kyle Burns. All rights reserved.
////
//
//import FirebaseUI
//
//class AuthPicker: FUIAuthPickerViewController {
//    
//    var buttonView: ButtonView!
//    var skipButton: UIButton!
//
//    init(authUI: FUIAuth) {
//        super.init(nibName: nil, bundle: nil, authUI: authUI)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("NSCoding not supported")
//    }
//    
//    override func viewDidLoad() {
//        view.backgroundColor = .white
//        
//        if (!authUI.shouldHideCancelButton) {
//            let cancelButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skipButtonHandler))
//            cancelButton.tintColor = .olive
//            navigationItem.leftBarButtonItem = cancelButton
//        }
//        
//        if #available(iOS 13, *) {
//            if (!authUI.isInteractiveDismissEnabled) {
//                self.isModalInPresentation = true
//            }
//        }
//        
//        buttonView = ButtonView(sender: self)
//        buttonView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(buttonView)
//        
//        let count = CGFloat(authUI.providers.count)
//        
//        NSLayoutConstraint.activate([
//            buttonView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
//            buttonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            buttonView.heightAnchor.constraint(lessThanOrEqualToConstant: kSignInButtonVerticalMargin * (1 + count * kSignInButtonHeight)),
//            buttonView.widthAnchor.constraint(equalToConstant: kSignInButtonWidth)
//        ])
//    }
//    
//    @objc func skipButtonHandler(_ sender: UIBarButtonItem) {
//        Auth.auth().signInAnonymously { _, error in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//        }
//        dismiss(animated: true)
//    }
//}
