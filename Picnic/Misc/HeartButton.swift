//
//  HeartButton.swift
//  Picnic
//
//  Created by Kyle Burns on 7/31/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class HeartButton: UIButton {
    let heartFill: UIImage?
    let heart: UIImage?
    private(set) var isActive: Bool = false
    
    init(pointSize: CGFloat) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .thin)
        heartFill = UIImage(systemName: "heart.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        heart = UIImage(systemName: "heart", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        let frame = CGRect(x: 0, y: 0, width: pointSize, height: pointSize)
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setActive(isActive: Bool) {
        self.isActive = isActive
        setImage(isActive ? heartFill : heart, for: .normal)
        imageView?.tintColor = isActive ? .red : .white
    }
}
