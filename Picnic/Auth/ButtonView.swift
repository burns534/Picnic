//
//  ButtonView.swift
//  Picnic
//
//  Created by Kyle Burns on 7/30/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseUI

///** @var kSignInButtonWidth
//    @brief The width of the sign in buttons.
// */
//let kSignInButtonWidth: CGFloat = 220.0
//
///** @var kSignInButtonHeight
//    @brief The height of the sign in buttons.
// */
//let kSignInButtonHeight: CGFloat = 40.0
//
///** @var kSignInButtonVerticalMargin
//    @brief The vertical margin between sign in buttons.
// */
//let kSignInButtonVerticalMargin: CGFloat = 24.0
//
///** @var kButtonContainerBottomMargin
//    @brief The magin between sign in buttons and the bottom of the content view.
// */
//fileprivate let kButtonContainerBottomMargin: CGFloat = 48.0
//
///** @var kButtonContainerTopMargin
//    @brief The margin between sign in buttons and the top of the content view.
// */
//fileprivate let kButtonContainerTopMargin: CGFloat = 16.0
//
//class ButtonView: UIView {
//
//    var sender: AuthPicker
//
//    init(sender: AuthPicker) {
//        self.sender = sender
//        super.init(frame: .zero)
//        guard let providers = Managers.shared.authManager.authUI?.providers else {
//            print("Error: ButtonView: init: authUI returned nil for providers")
//            return
//        }
//        var count: CGFloat = 0.0
//        for provider in providers {
//            let button = SignInButton(provider: provider, target: self, action: #selector(didTapSignInButton), for: .touchUpInside)
//            button.translatesAutoresizingMaskIntoConstraints = false
//            addSubview(button)
//
//            let margin = count == 0 ? 2 * kSignInButtonVerticalMargin : kSignInButtonVerticalMargin
//// MARK: Incomplete
//            NSLayoutConstraint.activate([
//                button.topAnchor.constraint(equalTo: topAnchor, constant: count * (kSignInButtonHeight + margin)),
//                button.centerXAnchor.constraint(equalTo: centerXAnchor),
//                button.widthAnchor.constraint(equalToConstant: kSignInButtonWidth),
//                button.heightAnchor.constraint(equalToConstant: kSignInButtonHeight)
//            ])
//            count += 1
//        }
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("NSCoding not supported")
//    }
//
//    @objc func didTapSignInButton(_ sender: SignInButton) {
//        Managers.shared.authManager.authUI?.signIn(withProviderUI: sender.provider, presenting: self.sender, defaultValue: nil)
//    }
//}
//
