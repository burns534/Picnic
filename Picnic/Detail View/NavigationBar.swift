//
//  NavigationBar.swift
//  Picnic
//
//  Created by Kyle Burns on 8/1/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class NavigationBar: UIView {
    
    private(set) var leftBarButton: UIButton?
    private(set) var rightBarButton: UIButton?
    private(set) var centerView: UIView?
    private(set) var title: UILabel?
    
    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setRightButtonPadding(amount: CGFloat) {
        rightBarButton?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -amount).isActive = true
    }
    
    func setLeftButtonPadding(amount: CGFloat) {
        leftBarButton?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: amount).isActive = true
    }
    
    func setCenterView(view: UIView) {
        centerView?.removeFromSuperview()
        title?.removeFromSuperview()
        centerView = view
        addSubview(centerView!)
        
        NSLayoutConstraint.activate([
            centerView!.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerView!.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func setTitle(text: String) {
        title?.removeFromSuperview()
        centerView?.removeFromSuperview()
        title = UILabel()
        title!.text = text
        title!.textAlignment = .center
        title?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title!)
        
        NSLayoutConstraint.activate([
            title!.centerYAnchor.constraint(equalTo: centerYAnchor),
            title!.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    func setLeftBarButton(image: UIImage?, target: Any?, action: Selector) {
        leftBarButton?.removeFromSuperview()
        leftBarButton = UIButton()
        leftBarButton!.translatesAutoresizingMaskIntoConstraints = false
        leftBarButton!.setImage(image, for: .normal)
        leftBarButton!.addTarget(target, action: action, for: .touchUpInside)
        addSubview(leftBarButton!)
        NSLayoutConstraint.activate([
            leftBarButton!.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftBarButton!.trailingAnchor.constraint(lessThanOrEqualTo: centerXAnchor),
            leftBarButton!.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            leftBarButton!.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
        ])
    }
    
    func setLeftBarButton(title: String, target: Any?, action: Selector) {
        leftBarButton?.removeFromSuperview()
        leftBarButton = UIButton()
        leftBarButton!.translatesAutoresizingMaskIntoConstraints = false
        leftBarButton!.setTitle(title, for: .normal)
        leftBarButton!.addTarget(target, action: action, for: .touchUpInside)
        addSubview(leftBarButton!)
        NSLayoutConstraint.activate([
            leftBarButton!.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftBarButton!.trailingAnchor.constraint(lessThanOrEqualTo: centerXAnchor),
            leftBarButton!.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            leftBarButton!.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
        ])

    }
    
    func setRightBarButton(image: UIImage?, target: Any?, action: Selector) {
        rightBarButton?.removeFromSuperview()
        rightBarButton = UIButton()
        rightBarButton!.translatesAutoresizingMaskIntoConstraints = false
        rightBarButton!.setImage(image, for: .normal)
        rightBarButton!.addTarget(target, action: action, for: .touchUpInside)
        addSubview(rightBarButton!)
        NSLayoutConstraint.activate([
            rightBarButton!.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightBarButton!.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            rightBarButton!.leadingAnchor.constraint(greaterThanOrEqualTo: centerXAnchor),
            rightBarButton!.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
        ])

    }
    
    func setRightBarButton(title: String, target: Any?, action: Selector) {
        rightBarButton?.removeFromSuperview()
        rightBarButton = UIButton()
        rightBarButton!.translatesAutoresizingMaskIntoConstraints = false
        rightBarButton!.setTitle(title, for: .normal)
        rightBarButton!.addTarget(target, action: action, for: .touchUpInside)
        addSubview(rightBarButton!)
        NSLayoutConstraint.activate([
            rightBarButton!.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightBarButton!.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            rightBarButton!.leadingAnchor.constraint(greaterThanOrEqualTo: centerXAnchor),
            rightBarButton!.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
        ])
    }
}

