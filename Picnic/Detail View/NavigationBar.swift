//
//  NavigationBar.swift
//  Picnic
//
//  Created by Kyle Burns on 8/1/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

let kNavigationBarBezelOffset: CGFloat = 44.0

class NavigationBar: UIView {
    
    private(set) var leftBarButton: UIButton?
    private(set) var rightBarButton: UIButton?
    private(set) var centerView: UIView?
    private(set) var title: UILabel?
 
    private var leading: NSLayoutConstraint?
    private var trailing: NSLayoutConstraint?
    
    func defaultConfiguration(left: Bool = false, right: Bool = false) {
        backgroundColor = .white
        if left {
            leftBarButton = UIButton(frame: .zero)
            leftBarButton!.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .thin))?.withRenderingMode(.alwaysTemplate), for: .normal)
            leftBarButton!.translatesAutoresizingMaskIntoConstraints = false
            addSubview(leftBarButton!)
            leading = NSLayoutConstraint(item: leftBarButton!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 10.0)
            leftBarButton?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            leading?.isActive = true
        }
        if right {
            rightBarButton = UIButton(frame: .zero)
            rightBarButton!.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .thin))?.withRenderingMode(.alwaysTemplate), for: .normal)
            rightBarButton!.translatesAutoresizingMaskIntoConstraints = false
            addSubview(rightBarButton!)
            trailing = NSLayoutConstraint(item: rightBarButton!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -10.0)
            rightBarButton?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            trailing?.isActive = true
        }
    }

    func setRightButtonPadding(amount: CGFloat) { trailing?.constant = -amount }
    func setLeftButtonPadding(amount: CGFloat) { leading?.constant = amount }
    
    func setRightBarButton(button: UIButton) {
        rightBarButton = button
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        trailing = NSLayoutConstraint(item: rightBarButton!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        rightBarButton?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        trailing?.isActive = true
    }
    
    func setLeftBarButton(button: UIButton) {
        leftBarButton = button
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        leading = NSLayoutConstraint(item: leftBarButton!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        leftBarButton?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        leading?.isActive = true
    }
    
    func setCenterView(view: UIView) {
        centerView?.removeFromSuperview()
        title?.removeFromSuperview()
        centerView = view
        centerView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerView!)
        centerView?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        centerView?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    func setTitle(text: String) {
        title?.removeFromSuperview()
        centerView?.removeFromSuperview()
        title = UILabel()
        title?.text = text
        title?.textAlignment = .center
        title?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title!)
        title?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        title?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}

