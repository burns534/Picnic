//
//  SignInButton.swift
//  Picnic
//
//  Created by Kyle Burns on 7/30/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import FirebaseUI

/** @var kCornerRadius
    @brief Corner radius of the button.
 */
fileprivate let kCornerRadius: CGFloat = 2.0

/** @var kDropShadowAlpha
    @brief Opacity of the drop shadow of the button.
 */
fileprivate let kDropShadowAlpha: Float = 0.24

/** @var kDropShadowRadius
    @brief Radius of the drop shadow of the button.
 */
fileprivate let kDropShadowRadius: CGFloat = 2.0

/** @var kDropShadowYOffset
    @brief Vertical offset of the drop shadow of the button.
 */
fileprivate let kDropShadowYOffset: CGFloat = 2.0

/** @var kFontSize
    @brief Button text font size.
 */
fileprivate let kFontSize: CGFloat = 12.0

// MARK: Could be improved
/* This wasn't done the best way. I could have taken advantage of builtin image and title attributes and applied constraints to them the same way I did here. */

class SignInButton: UIButton {
    
    var icon: UIImageView!
    var label: UILabel!
    var provider: FUIAuthProvider!
    
    init(provider: FUIAuthProvider, target: Any?, action: Selector, for event: UIControl.Event) {
        super.init(frame: .zero)
        self.provider = provider
        
        icon = UIImageView(image: provider.icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        
        label = UILabel()
        label.text = provider.signInLabel
        label.textColor = provider.buttonTextColor
        label.font = UIFont.boldSystemFont(ofSize: kFontSize)
        label.lineBreakMode = .byCharWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        backgroundColor = provider.buttonBackgroundColor
        addTarget(target, action: action, for: event)
        
        layer.cornerRadius = kCornerRadius
        layer.setShadow(radius: kDropShadowRadius, color: .black, opacity: kDropShadowAlpha, offset: CGSize(width: 0, height: kDropShadowYOffset))
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            icon.widthAnchor.constraint(equalToConstant: 2 * kFontSize),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            label.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}
