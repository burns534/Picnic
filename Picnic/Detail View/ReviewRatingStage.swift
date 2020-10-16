//
//  ReviewRatingStage.swift
//  Picnic
//
//  Created by Kyle Burns on 10/15/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class ReviewRatingStage: UIView {
    
    let reviewRating = Rating(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        let reviewRatingLabel = UILabel()
        reviewRatingLabel.adjustsFontSizeToFitWidth = true
        reviewRatingLabel.minimumScaleFactor = 0.5
        reviewRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewRatingLabel.text = "How was it?"
        reviewRatingLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        reviewRatingLabel.textAlignment = .center
        
        reviewRating.translatesAutoresizingMaskIntoConstraints = false
        reviewRating.mode = .interactable
        
        addSubview(reviewRatingLabel)
        addSubview(reviewRating)
        
        NSLayoutConstraint.activate([
            reviewRatingLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            reviewRatingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            reviewRatingLabel.heightAnchor.constraint(equalTo: reviewRatingLabel.heightAnchor, multiplier: kStagedModalLabelHeightMultiplier),
            reviewRatingLabel.widthAnchor.constraint(equalTo: reviewRatingLabel.widthAnchor, multiplier: kStagedModalLabelWidthMultiplier),
// TODO: Make Rating more compatible with constraints
            reviewRating.topAnchor.constraint(equalTo: reviewRatingLabel.bottomAnchor),
            reviewRating.centerXAnchor.constraint(equalTo: centerXAnchor),
            reviewRating.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7)
        ])
    }
}
