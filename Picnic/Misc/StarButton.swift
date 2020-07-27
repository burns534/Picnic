//
//  StarView.swift
//  Picnic
//
//  Created by Kyle Burns on 6/10/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class StarButton: UIButton {

    var full: UIImageView
    var empty: UIImageView
    var starSize: CGSize
    
    init(frame: CGRect, starSize: CGSize, color: UIColor) {
        let config = UIImage.SymbolConfiguration(scale: .large)
        let emptyStar = UIImage(systemName: "star", withConfiguration: config)!.withTintColor(color, renderingMode: .alwaysOriginal)
        
        let fullStar = UIImage(systemName: "star.fill", withConfiguration: config)!.withTintColor(color, renderingMode: .alwaysOriginal).withAlignmentRectInsets(.zero)
        
        self.empty = UIImageView(image: emptyStar)
        empty.translatesAutoresizingMaskIntoConstraints = false
        empty.contentMode = .scaleAspectFit
        self.full = UIImageView(image: fullStar)
        full.translatesAutoresizingMaskIntoConstraints = false
        full.contentMode = .scaleAspectFit
        self.starSize = starSize
        super.init(frame: frame)
        
        addSubview(full)
        addSubview(empty)
        
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
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func addMask(maskWidth: CGFloat) {
        self.full.isHidden = false
        self.empty.isHidden = false
        
        let maskLayer = CALayer()
        maskLayer.frame = .init(x: 0, y: 0, width: maskWidth, height: starSize.height)
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
