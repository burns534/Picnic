//
//  Rating.swift
//  Picnic
//
//  Created by Kyle Burns on 6/2/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

fileprivate let defaultStarSize: CGSize = CGSize(width: 20, height: 20)
// will display rating and number of ratings with stars
class Rating: UIView {

    var stars = [StarButton]()
    
    var starSize: CGSize
    var spacing: CGFloat = 1
    var rating: CGFloat = 0
    var width: CGFloat = 0
    var picnic: Picnic!
// MARK: For rating
    init(frame: CGRect, starSize: CGSize, spacing: CGFloat, rating: CGFloat) {
        self.starSize = starSize
        self.spacing = spacing
        self.rating = rating
        self.width = 5 * starSize.width + 4 * spacing
        super.init(frame: frame)
        setup()
        configureFloat(rating: rating)
    }
// MARK: For Display
    init(picnic: Picnic) {
        starSize = defaultStarSize
        rating = CGFloat(picnic.rating)
        width = 5.0 * starSize.width + 4.0 * spacing
        super.init(frame: .zero)
        self.picnic = picnic
        setup()
        configureFloat(rating: rating)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setup() {
        isUserInteractionEnabled = false
        
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
                /* star symbol does not go edge to edge in the image. The image leaves a small amount on the left and right of the star. Additionally, the the very corners of the stars are imperceptible when applying a small mask. Accounting for these two things, approximately a translation of approximately 1/6 the image size is needed to create correct star behavior.*/
                let mask = starSize.width * CGFloat(rating.truncatingRemainder(dividingBy: 1.0) * 0.62 + 0.15)
                stars[i].addMask(maskWidth: mask)
            } else {
                stars[i].emptyStar()
            }
        }
    }
    
// MARK: Obj-C functions
    @objc func starPress(_ sender: UIButton) {
        rating = CGFloat(sender.tag + 1)
        refresh(rating: rating)
// MARK: need to verify here if user has rated this picnic already
        Shared.shared.databaseManager.updateRating(picnic: picnic, rating: Float(rating)) {
            
        }
    }
}
