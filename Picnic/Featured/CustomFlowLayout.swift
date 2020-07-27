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
        self.itemSize = CGSize(width: cellSize.width, height: cellSize.height)
        self.minimumLineSpacing = 25
        sectionInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
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
