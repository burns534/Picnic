//
//  VisitButton.swift
//  Picnic
//
//  Created by Kyle Burns on 10/7/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class VisitButton: UIView {
    let button = UIButton()
    let label = UILabel()

    private var isActive: Bool = false
    
    func toggle() -> Bool{
        if isActive {
            button.setImage(UIImage(systemName: "plus"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "plus"), for: .normal)
        }
        isActive.toggle()
        return isActive
    }
    
    func configure(text: String) {
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(button)
        addSubview(label)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),
            
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)
        ])
    }
}

