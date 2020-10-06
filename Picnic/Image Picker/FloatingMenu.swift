//
//  FloatingMenu.swift
//  Picnic
//
//  Created by Kyle Burns on 7/18/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class FloatingMenu: UIView {
    
    // would like to make this a sliding menu eventually probably
    
    // could be more general and make a list of buttons but...
    var cameraButton: UIButton!
    var extraButton: UIButton!
    
    private enum CurrentSource {
        case library, camera
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    func configure() {
        backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        
        cameraButton = UIButton()
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        let cameraImage = UIImage(systemName: "camera")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        cameraButton.setImage(cameraImage, for: .normal)
        addSubview(cameraButton)
        
        extraButton = UIButton()
        let photoImage = UIImage(systemName: "photo")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        extraButton.setImage(photoImage, for: .normal)
        extraButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(extraButton)
        
        
        
        NSLayoutConstraint.activate([
            cameraButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            cameraButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            cameraButton.heightAnchor.constraint(equalToConstant: 40),
            
            extraButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            extraButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            extraButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func addCameraButtonTarget(target: Any?, action: Selector, for event: UIControl.Event) {
        cameraButton.addTarget(target, action: action, for: event)
    }
}

