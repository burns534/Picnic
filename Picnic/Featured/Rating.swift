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
        for i in 0..<5 {
            let star = UIImageView(frame: .zero)
            star.image = UIImage(systemName: "star")!.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
            star.contentMode = .scaleAspectFit
            star.translatesAutoresizingMaskIntoConstraints = false
            overlayStars.append(star)
            addSubview(star)
            
            let underlayStar = UIImageView(frame: .zero)
            underlayStar.image = UIImage(systemName: "star.fill")!.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
            underlayStar.contentMode = .scaleAspectFit
            underlayStar.translatesAutoresizingMaskIntoConstraints = false
            underlayStars.append(underlayStar)
            addSubview(underlayStar)
            
            NSLayoutConstraint.activate([
                star.widthAnchor.constraint(equalToConstant: 15),
                star.heightAnchor.constraint(equalToConstant: 15),
                star.leftAnchor.constraint(equalTo: self.leftAnchor, constant: CGFloat(16 * i)),
                star.topAnchor.constraint(equalTo: self.topAnchor),
                
                underlayStar.widthAnchor.constraint(equalToConstant: 15),
                underlayStar.heightAnchor.constraint(equalToConstant: 15),
                underlayStar.leftAnchor.constraint(equalTo: self.leftAnchor, constant: CGFloat(16 * i)),
                underlayStar.topAnchor.constraint(equalTo: self.topAnchor)
            ])
        }
    }
   
    func configure(rating: Double) {
        for i in 0..<5 {
            // automatically show filled stars
            if Double(i + 1) <= rating {
                overlayStars[i].isHidden = true
                underlayStars[i].isHidden = false
                // partial fill case
            } else if Double(i + 1) > rating && Double(i) < rating {
                let maskLayer = CALayer()
                /* the star imageView is width 15 but the actual width of the star is approximately 10, centered at 7.5. The mask also is applied backwards hence the 1 - (i + 1 - rating)*/
                let maskWidth = CGFloat(1 - Double(i + 1) + rating) * 10 + 2.5
                maskLayer.frame = .init(x: 0, y: 0, width: maskWidth, height: 15)
                maskLayer.backgroundColor = UIColor.black.cgColor
                underlayStars[i].layer.mask = maskLayer
                underlayStars[i].isHidden = false
                overlayStars[i].isHidden = false
            } else {
                overlayStars[i].isHidden = false
                underlayStars[i].isHidden = true
            }
        }
    }
}
