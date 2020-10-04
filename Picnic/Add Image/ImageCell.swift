//
//  ImageCell.swift
//  Picnic
//
//  Created by Kyle Burns on 7/15/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var representedAssetIdentifier: String!
    var selectionImage: UIImageView!
    var hasActiveSelection: Bool = false {
        didSet {
            if hasActiveSelection {
                selectionImage.image = circleFill
                selectionImage.tintColor = .lightBlue
            } else {
                selectionImage.image = circle
                selectionImage.tintColor = .lightGray
            }
        }
    }
    
    let circle = UIImage(systemName: "circle")!.withRenderingMode(.alwaysTemplate)
    let circleFill = UIImage(systemName: "largecircle.fill.circle")?.withRenderingMode(.alwaysTemplate)
    
    private let toggleColor: UIColor = .systemBlue
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setup() {
        self.backgroundColor = .clear
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        selectionImage = UIImageView(image: circle)
        selectionImage.translatesAutoresizingMaskIntoConstraints = false
        selectionImage.backgroundColor = .clear
        selectionImage.contentMode = .scaleAspectFit
        selectionImage.tintColor = .lightGray
        contentView.addSubview(selectionImage)
    }
    
    func configure() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.heightAnchor.constraint(equalTo: heightAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            
            selectionImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            selectionImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            selectionImage.widthAnchor.constraint(equalToConstant: 20),
            selectionImage.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}
