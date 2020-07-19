//
//  CustomPickerFlowLayout.swift
//  Picnic
//
//  Created by Kyle Burns on 7/15/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class CustomPickerFlowLayout: UICollectionViewFlowLayout {
    
    convenience init(itemSize: CGSize, scrollDirection: UICollectionView.ScrollDirection, minimumLineSpacing: CGFloat, sectionInset: UIEdgeInsets, minimumInteritemSpacing: CGFloat = 10.0) {
        self.init()
        self.itemSize = itemSize
        self.scrollDirection = scrollDirection
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
        self.minimumInteritemSpacing = minimumInteritemSpacing
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

}
