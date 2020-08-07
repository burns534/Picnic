//
//  StarView.swift
//  Picnic
//
//  Created by Kyle Burns on 6/10/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class StarButton: UIButton {

    var full: UIImageView!
    var empty: UIImageView!
    var starSize: CGSize
    
    init(starSize: CGSize, color: UIColor) {
        self.starSize = starSize
        super.init(frame: .zero)
        setup(color: color)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setup(color: UIColor) {
        
        let config = UIImage.SymbolConfiguration(weight: .light)
        let emptyStar = UIImage(systemName: "star", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        
        let fullStar = UIImage(systemName: "star.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        
        empty = UIImageView(image: emptyStar)
        addSubview(empty)
        full = UIImageView(image: fullStar)
        addSubview(full)
        
        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.tintColor = color
        }
        
        NSLayoutConstraint.activate([
            empty.centerXAnchor.constraint(equalTo: centerXAnchor),
            empty.centerYAnchor.constraint(equalTo: centerYAnchor),
            empty.widthAnchor.constraint(equalToConstant: starSize.width),
            empty.heightAnchor.constraint(equalToConstant: starSize.height),
            
            full.centerXAnchor.constraint(equalTo: centerXAnchor),
            full.centerYAnchor.constraint(equalTo: centerYAnchor),
            full.widthAnchor.constraint(equalToConstant: starSize.width),
            full.heightAnchor.constraint(equalToConstant: starSize.height)
        ])
    }
    
    func addMask(maskWidth: CGFloat) {
        self.full.isHidden = false
        self.empty.isHidden = false
        
        let maskLayer = CALayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: maskWidth, height: starSize.height)
        // black mask color is odd but necessary
        maskLayer.backgroundColor = UIColor.black.cgColor
        self.full.layer.mask = maskLayer
    }
    
    func clearStar() {
        self.full.isHidden = false
        self.empty.isHidden = false
        self.full.layer.mask = nil
    }
    
    func fillStar() {
        self.full.isHidden = false
        self.full.layer.mask = nil
        self.empty.isHidden = true
    }

    func emptyStar() {
        self.full.isHidden = true
        self.empty.isHidden = false
    }
}
