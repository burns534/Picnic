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

    var overlay: UIStackView!
    var underlay: UIStackView!
    var stars = [StarButton]()
    
    var starSize: CGSize
    var spacing: CGFloat
    var rating: CGFloat
    
    var width: CGFloat
    
    init(frame: CGRect, starSize: CGSize, spacing: CGFloat, rating: CGFloat) {
        self.starSize = starSize
        self.spacing = spacing
        self.rating = rating
        self.width = 5 * starSize.width + 4 * spacing
        super.init(frame: frame)
        setup()
        configureFloat(rating: rating)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    @objc func starPress(_ sender: UIButton) {
        self.rating = CGFloat(sender.tag + 1)
        refresh(rating: self.rating)
    }
    
    func setup() {
        
        self.isUserInteractionEnabled = false

        for i in 0..<5 {

            let starButton = StarButton(frame: .zero, starSize: self.starSize, color: .systemYellow)
            starButton.translatesAutoresizingMaskIntoConstraints = false
            starButton.addTarget(self, action: #selector(starPress), for: .touchUpInside)
            starButton.tag = i
            stars.append(starButton)

            addSubview(starButton)

            NSLayoutConstraint.activate([
                starButton.widthAnchor.constraint(equalToConstant: starSize.width),
                starButton.heightAnchor.constraint(equalToConstant: starSize.height),
                starButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: (starSize.width + spacing) * CGFloat(i)),
                starButton.topAnchor.constraint(equalTo: self.topAnchor)
            ])
        }
    }
    
    func refresh(rating: CGFloat) {
        self.rating = rating
        for i in 0..<5 {
            if CGFloat(i) < rating {
                stars[i].fillStar()
            } else {
                stars[i].emptyStar()
            }
        }
    }
    // for use with floating point rating
    func configureFloat(rating: CGFloat) {
        self.rating = rating
        for i in 0..<5 {
            // automatically show filled stars
            if CGFloat(i + 1) <= rating {
                stars[i].fillStar()
                // partial fill case
            } else if CGFloat(i + 1) > rating && CGFloat(i) < rating {
                /* the star imageView is width 15 but the actual width of the star is approximately 10, centered at 7.5. The mask also is applied backwards hence the 1 - (i + 1 - rating)*/
                let maskWidth = starSize.width * (CGFloat(1 - CGFloat(i + 1) + rating) * 0.66667 + 0.3333)
                stars[i].addMask(maskWidth: maskWidth)
            } else {
                stars[i].emptyStar()
            }
        }
    }
}
