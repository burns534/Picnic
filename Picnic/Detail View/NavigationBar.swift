//
//  NavigationBar.swift
//  Picnic
//
//  Created by Kyle Burns on 8/1/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class NavigationBar: UIView {
    
    let leftBarButton: UIButton
    let rightBarButton: UIButton
    var centerView: UIView?
    var title: UILabel?
    
    private let defaultLeftButtonImage: UIImage?
    private let defaultRightButtonImage: UIImage?
    
    override init(frame: CGRect) {
        leftBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.height, height: frame.height))
        rightBarButton = UIButton(frame: CGRect(x: frame.width - frame.height, y: 0, width: frame.height, height: frame.height))
        defaultLeftButtonImage = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: frame.height, weight: .thin))?.withRenderingMode(.alwaysTemplate)
        defaultRightButtonImage = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: frame.height, weight: .thin))?.withRenderingMode(.alwaysTemplate)
        leftBarButton.setImage(defaultLeftButtonImage, for: .normal)
        rightBarButton.setImage(defaultRightButtonImage, for: .normal)
        super.init(frame: frame)
        addSubview(leftBarButton)
        addSubview(rightBarButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRightButtonPadding(amount: CGFloat) {
        rightBarButton.frame = rightBarButton.frame.offsetBy(dx: -amount, dy: 0)
    }
    
    func setLeftButtonPadding(amount: CGFloat) {
        leftBarButton.frame = leftBarButton.frame.offsetBy(dx: amount, dy: 0)
    }
    
    func setCenterView(view: UIView) {
        centerView?.removeFromSuperview()
        title?.removeFromSuperview()
        centerView = view
        centerView?.center = center
        addSubview(centerView!)
    }
    
    func setTitle(text: String) {
        title?.removeFromSuperview()
        centerView?.removeFromSuperview()
        title = UILabel()
        title?.text = text
        title?.textAlignment = .center
        title?.center = center
        addSubview(title!)
    }
    
    func setContentColor(_ color: UIColor) {
        subviews.forEach { $0.tintColor = color }
    }
}

