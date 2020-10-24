//
//  PicnicNameStage.swift
//  Picnic
//
//  Created by Kyle Burns on 10/17/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

fileprivate let textFieldHeightMultiplier: CGFloat = 0.15

class PicnicNameStage: ContentStage {
    override func createSubviews() {
        super.createSubviews()
        contentTextField.placeholder = "Something recognizable"
        contentTextField.textAlignment = .center
        contentLabel.text = "Give this picnic a name"
    }
    
    override func setupContentConstraints() {
        NSLayoutConstraint.activate([
            contentTextField.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            contentTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.65),
            contentTextField.heightAnchor.constraint(equalTo: heightAnchor, multiplier: textFieldHeightMultiplier)
        ])
    }
}

//// UITextField delegate
//extension PicnicNameStage {
//
//    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        textField.endEditing(true)
//        return true
//    }
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if let text = textField.text, text.count > 15 {
//            return false
//        } else {
//            return true
//        }
//    }
//}
