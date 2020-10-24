//
//  PicnicTagStage.swift
//  Picnic
//
//  Created by Kyle Burns on 10/20/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class PicnicTagStage: UIView {
    let tagView = TagView(tags: PicnicTag.allCases)
    
    var tags: [PicnicTag]? {
        tagView.indexPathsForSelectedItems?.compactMap { (indexPath) -> PicnicTag in
            PicnicTag.allCases[indexPath.item]
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let instructions = UILabel()
        instructions.text = "Select relevant tags"
        instructions.textAlignment = .center
        instructions.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        instructions.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tagView)
        addSubview(instructions)
        
        NSLayoutConstraint.activate([
            instructions.topAnchor.constraint(equalTo: topAnchor),
            instructions.centerXAnchor.constraint(equalTo: centerXAnchor),
            instructions.heightAnchor.constraint(equalTo: heightAnchor, multiplier: kStagedModalLabelHeightMultiplier),
            instructions.widthAnchor.constraint(equalTo: widthAnchor, multiplier: kStagedModalLabelWidthMultiplier),
            
            tagView.topAnchor.constraint(equalTo: instructions.bottomAnchor, constant: 10),
            tagView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tagView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            tagView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}



