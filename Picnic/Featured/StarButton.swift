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
    
    init(frame: CGRect, starSize: CGSize) {
        let emptyStar = UIImage(systemName: "star")!.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        
        let fullStar = UIImage(systemName: "star.fill")!.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        
        self.empty = UIImageView(image: emptyStar)
        empty.translatesAutoresizingMaskIntoConstraints = false
        empty.contentMode = .scaleAspectFit
        self.full = UIImageView(image: fullStar)
        full.translatesAutoresizingMaskIntoConstraints = false
        full.contentMode = .scaleAspectFit
        self.starSize = starSize
        super.init(frame: frame)
        
        self.addSubview(full)
        self.addSubview(empty)
        
        NSLayoutConstraint.activate([
            empty.widthAnchor.constraint(equalToConstant: starSize.width),
            empty.heightAnchor.constraint(equalToConstant: starSize.height),
            
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
