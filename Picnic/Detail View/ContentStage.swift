//
//  ReviewContentStage.swift
//  Picnic
//
//  Created by Kyle Burns on 10/15/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class ContentStage: UIView {
    
    let contentLabel = UILabel()
    let contentTextField = PaddedTextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.text = "What did you think?"
        contentLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        contentLabel.adjustsFontSizeToFitWidth = true
        contentLabel.minimumScaleFactor = 0.5
        contentLabel.textAlignment = .center
        
        contentTextField.translatesAutoresizingMaskIntoConstraints = false
        contentTextField.placeholder = "Enter a Description"
        contentTextField.backgroundColor = .darkWhite
        contentTextField.clipsToBounds = true
        contentTextField.layer.cornerRadius = 5
        
        addSubview(contentLabel)
        addSubview(contentTextField)
        
        setupLabelConstraints()
        setupContentConstraints()
    }
    
    func setupLabelConstraints() {
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: topAnchor),
            contentLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: kStagedModalLabelHeightMultiplier),
            contentLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: kStagedModalLabelWidthMultiplier)
        ])
    }
    
    func setupContentConstraints() {
        NSLayoutConstraint.activate([
            contentTextField.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            contentTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            contentTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            contentTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}
