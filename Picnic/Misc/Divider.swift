//
//  Divider.swift
//  Picnic
//
//  Created by Kyle Burns on 8/7/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class Divider: UIView {
    
    var size: CGSize
    
    init(width: CGFloat, height: CGFloat) {
        size = CGSize(width: width, height: height)
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}
