//
//  Rating.swift
//  Picnic
//
//  Created by Kyle Burns on 6/2/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

// will display rating and number of ratings with stars
class Rating: UIView {
    
    convenience init(frame: CGRect, rating: Double) {
        self.init(frame: frame)
        setup()
        configure(rating: rating)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    var overlay: UIStackView!
    var underlay: UIStackView!
    var overlayStars = [UIImageView]()
    var underlayStars = [UIImageView]()
    
    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 0..<5 {
            let star = UIImageView(frame: .zero)
            star.image = UIImage(systemName: "star")!.withTintColor(.yellow, renderingMode: .alwaysOriginal)
            star.contentMode = .scaleAspectFit
            star.translatesAutoresizingMaskIntoConstraints = false
            overlayStars.append(star)
            addSubview(star)
            
            let underlayStar = UIImageView(frame: .zero)
            underlayStar.image = UIImage(systemName: "star.fill")!.withTintColor(.yellow, renderingMode: .alwaysOriginal)
            underlayStar.contentMode = .scaleAspectFit
            underlayStar.translatesAutoresizingMaskIntoConstraints = false
            underlayStars.append(underlayStar)
            addSubview(underlayStar)
            
            NSLayoutConstraint.activate([
                star.widthAnchor.constraint(equalToConstant: 15),
                star.heightAnchor.constraint(equalToConstant: 15),
                star.leftAnchor.constraint(equalTo: self.leftAnchor, constant: CGFloat(16 * i)),
                underlayStar.widthAnchor.constraint(equalToConstant: 15),
                underlayStar.heightAnchor.constraint(equalToConstant: 15),
                underlayStar.leftAnchor.constraint(equalTo: self.leftAnchor, constant: CGFloat(16 * i))
            ])
        }
        
//        overlay = UIStackView(arrangedSubviews: overlayStars)
//        overlay.translatesAutoresizingMaskIntoConstraints = false
//        overlay.axis = .horizontal
//        overlay.spacing = 1
//        overlay.alignment = .firstBaseline
//        self.addSubview(overlay)
//
//        underlay = UIStackView(arrangedSubviews: underlayStars)
//        underlay.translatesAutoresizingMaskIntoConstraints = false
//        underlay.axis = .horizontal
//        underlay.spacing = 1
//        underlay.alignment = .firstBaseline
//        self.addSubview(underlay)
//
//        NSLayoutConstraint.activate([
//            overlay.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            underlay.centerXAnchor.constraint(equalTo: self.centerXAnchor)
//        ])
    }
   
    func configure(rating: Double) {
        for i in 0..<5 {
            // automatically show filled stars
            if Double(i + 1) <= rating {
                overlayStars[i].isHidden = true
                underlayStars[i].isHidden = false
            } else {
                overlayStars[i].isHidden = false
                underlayStars[i].isHidden = true
            }
        }
    }
}
