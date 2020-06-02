//
//  CustomFlowLayout.swift
//  Picnic
//
//  Created by Kyle Burns on 5/25/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()
        self.scrollDirection = .vertical
        self.itemSize = CGSize(width: 150, height: 200)
        self.minimumLineSpacing = 25
        self.sectionInset = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCodingn not supported")
    }
    
    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath as IndexPath, withTargetPosition: position)
        
        attributes.alpha = 0.7
        
        return attributes
    }
}
