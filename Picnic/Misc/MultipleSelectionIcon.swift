//
//  MultipleSelectionIcon.swift
//  Picnic
//
//  Created by Kyle Burns on 8/2/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
import Photos

class MultipleSelectionIcon: UIButton {
    
    let icon = UIImage(systemName: "rectangle.fill.on.rectangle.angled.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .light))?.withTintColor(.white, renderingMode: .alwaysOriginal)
    var iconImageView: UIImageView!
    var isMultipleSelection: Bool = false {
        didSet {
            iconImageView.isHidden = !isMultipleSelection
        }
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    init(image: UIImage?) {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setup() {
        iconImageView = UIImageView(image: icon)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.isHidden = true
        backgroundColor = .darkWhite
        clipsToBounds = true
        layer.cornerRadius = 5
        addSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.8),
            iconImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0.8),
            iconImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.15),
            iconImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.15)
        ])
    }
}
