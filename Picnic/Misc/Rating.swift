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
    var ratingCountLabel: UILabel!
    var ratingCount: Int = 0
    
    var isRatingCountHidden: Bool = true {
        didSet {
            if let r = ratingCountLabel {
                r.isHidden = isRatingCountHidden
            } else if !isRatingCountHidden {
                configureRatingCount()
            }
        }
    }
// MARK: For rating
    init(starSize: CGSize, spacing: CGFloat = 1, rating: CGFloat = 0) {
        self.starSize = starSize
        self.spacing = spacing
        self.rating = rating
        self.width = 5 * starSize.width + 4 * spacing
        super.init(frame: .zero)
        setup()
        refresh()
    }
    
    init() {
        starSize = defaultStarSize
        width = 5.0 * starSize.width + 4.0 * spacing
        super.init(frame: .zero)
        setup()
        refresh()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func configure(picnic: Picnic) {
        self.picnic = picnic
        rating = CGFloat(picnic.rating)
        ratingCount = picnic.ratingCount
    }
    
    func configureRatingCount() {
        guard let p = picnic else { return }
        ratingCountLabel = UILabel()
        var ratingString: String
        if p.ratingCount > 1000 {
            let reduced: Float = Float(p.ratingCount) / 1000.0
            ratingString = String(format: "%.1fk", reduced)
        } else {
            ratingString = "\(p.ratingCount)"
        }
        ratingCountLabel.text = "(" + ratingString + ")"
        let length = ratingCountLabel.text!.count * 8
        ratingCountLabel.translatesAutoresizingMaskIntoConstraints = false
        // probably
        ratingCountLabel.textAlignment = .center
        ratingCountLabel.textColor = .white
        addSubview(ratingCountLabel)
        NSLayoutConstraint.activate([
            ratingCountLabel.leadingAnchor.constraint(equalTo: stars.last!.trailingAnchor, constant: 5),
            ratingCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            ratingCountLabel.widthAnchor.constraint(equalToConstant: CGFloat(length)),
            ratingCountLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
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
                starButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: (starSize.width + spacing) * CGFloat(i)),
                starButton.topAnchor.constraint(equalTo: self.topAnchor)
            ])
        }
    }
    
    func refresh() {
        for i in 0..<5 {
            if CGFloat(i) < rating {
                stars[i].fillStar()
            } else {
                stars[i].emptyStar()
            }
        }
    }
    
    func update(rating: CGFloat) {
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
    func configureFloat() {
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
        update(rating: rating)
        
// MARK: need to verify here if user has rated this picnic already
        guard let p = picnic else { return }
        Shared.shared.user.isRated(post: p.id) { value in
            print(p.id)
            if value {
                Shared.shared.databaseManager.updateRating(picnic: p, rating: Float(self.rating), increment: false)
            } else {
                Shared.shared.databaseManager.updateRating(picnic: p, rating: Float(self.rating), increment: true) {
                    Shared.shared.user.ratePost(id: p.id) { err in
                        if let err = err {
                            print("Error: \(err.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
