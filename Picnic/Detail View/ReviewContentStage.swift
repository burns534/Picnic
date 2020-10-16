//
//  ReviewContentStage.swift
//  Picnic
//
//  Created by Kyle Burns on 10/15/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class ReviewContentStage: UIView {
    
    let reviewContentTextField = PaddedTextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        let reviewContentLabel = UILabel()
        reviewContentLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewContentLabel.text = "What did you think?"
        reviewContentLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        reviewContentLabel.adjustsFontSizeToFitWidth = true
        reviewContentLabel.minimumScaleFactor = 0.5
        reviewContentLabel.textAlignment = .center
        
        reviewContentTextField.translatesAutoresizingMaskIntoConstraints = false
        reviewContentTextField.placeholder = "Enter a Description"
        reviewContentTextField.backgroundColor = .darkWhite
        reviewContentTextField.clipsToBounds = true
        reviewContentTextField.layer.cornerRadius = 5
        reviewContentTextField.contentVerticalAlignment = .top
        reviewContentTextField.delegate = self
        
        addSubview(reviewContentLabel)
        addSubview(reviewContentTextField)
        
        NSLayoutConstraint.activate([
            reviewContentLabel.topAnchor.constraint(equalTo: topAnchor),
            reviewContentLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            reviewContentLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: kStagedModalLabelHeightMultiplier),
            reviewContentLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: kStagedModalLabelWidthMultiplier),
            
            reviewContentTextField.topAnchor.constraint(equalTo: reviewContentLabel.bottomAnchor, constant: 10),
            reviewContentTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            reviewContentTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            reviewContentTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}

extension ReviewContentStage: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
        return true
    }
}
