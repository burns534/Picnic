//
//  StarImage.swift
//  Picnic
//
//  Created by Kyle Burns on 10/18/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class StarImage: UIImageView {
    private var overlay: UIImageView?
    
    func setOverlay(image: UIImage?, ratio: CGFloat) {
        guard let image = image else { return }
        let overlay = UIImageView(image: image)
        addSubview(overlay)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        let mask = UIView(frame: CGRect(x: 0.15 * frame.width, y: 0, width: 0.7 * ratio * frame.width, height: frame.height))
        mask.backgroundColor = .black
        overlay.mask = mask
    }
    
    func removeOverlay() {
        overlay?.removeFromSuperview()
        overlay = nil
        mask = nil
    }
}
