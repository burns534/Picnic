//
//  ZoomableImage.swift
//  Picnic
//
//  Created by Kyle Burns on 7/18/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class ZoomableImage: UIScrollView {

    var imageView: UIImageView!
    
    convenience init(image: UIImage) {
        self.init(frame: .zero)
        imageView.image = image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        minimumZoomScale = 0.2
        maximumZoomScale = 6.0
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bounces = true
        bouncesZoom = true
        alwaysBounceVertical = true
        alwaysBounceHorizontal = true
        
        contentSize = imageView.frame.size
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setImage(image: UIImage) {
        imageView?.image = image
    }
}
