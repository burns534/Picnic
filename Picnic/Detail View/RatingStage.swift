//
//  ReviewRatingStage.swift
//  Picnic
//
//  Created by Kyle Burns on 10/15/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class RatingStage: UIView {
    
    let rating = Rating(frame: .zero)

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
        
        rating.translatesAutoresizingMaskIntoConstraints = false
        rating.style = .fill
        rating.mode = .interactable
        
        addSubview(reviewRatingLabel)
        addSubview(rating)
        
        NSLayoutConstraint.activate([
            reviewRatingLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            reviewRatingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            reviewRatingLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: kStagedModalLabelHeightMultiplier),
            reviewRatingLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: kStagedModalLabelWidthMultiplier),
            
            rating.topAnchor.constraint(equalTo: reviewRatingLabel.bottomAnchor),
            rating.centerXAnchor.constraint(equalTo: centerXAnchor),
            rating.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7)
        ])
    }
}
