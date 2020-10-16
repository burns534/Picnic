//
//  ImagePickerStage.swift
//  Picnic
//
//  Created by Kyle Burns on 10/15/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class ImagePickerStage: UIView {
    let imagePickerButton = MultipleSelectionIcon()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        imagePickerButton.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        imagePickerButton.tintColor = .darkGray
        imagePickerButton.translatesAutoresizingMaskIntoConstraints = false
        
        let imagePickerLabel = UILabel()
        imagePickerLabel.translatesAutoresizingMaskIntoConstraints = false
        imagePickerLabel.text = "Add Photos"
        imagePickerLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        imagePickerLabel.textColor = .black
        imagePickerLabel.textAlignment = .center
        
        addSubview(imagePickerButton)
        addSubview(imagePickerLabel)
        
        NSLayoutConstraint.activate([
            imagePickerLabel.topAnchor.constraint(equalTo: topAnchor),
            imagePickerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            imagePickerLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: kStagedModalLabelHeightMultiplier),
            imagePickerLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: kStagedModalLabelWidthMultiplier),
            
            imagePickerButton.topAnchor.constraint(equalTo: imagePickerLabel.bottomAnchor, constant: 20),
            imagePickerButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            imagePickerButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            imagePickerButton.heightAnchor.constraint(equalTo: imagePickerButton.widthAnchor)
        ])
    }
    
}
