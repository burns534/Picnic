//
//  HeartButton.swift
//  Picnic
//
//  Created by Kyle Burns on 7/31/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class HeartButton: UIButton {
    
    var isLiked: Bool
    let config = UIImage.SymbolConfiguration(weight: .light)
    
    init(isLiked: Bool, frame: CGRect) {
        self.isLiked = isLiked
        super.init(frame: frame)
        let heart = UIImage(systemName: isLiked ? "heart.fill" : "heart", withConfiguration: config)?.withTintColor(isLiked ? .red : .lightGray, renderingMode: .alwaysOriginal)
        setImage(heart, for: .normal)
        imageView!.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView!.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView!.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView!.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            imageView!.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func toggle() {
        isLiked.toggle()
        let heart = UIImage(systemName: isLiked ? "heart.fill" : "heart", withConfiguration: config)?.withTintColor(isLiked ? .red : .lightGray, renderingMode: .alwaysOriginal)
        setImage(heart, for: .normal)
    }
}
