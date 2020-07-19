//
//  ImageCell.swift
//  Picnic
//
//  Created by Kyle Burns on 7/15/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

extension UIColor {
    static let toggle = UIColor(red: 0.5, green: 0.9, blue: 0.1, alpha: 1.0)
}

class ImageCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var representedAssetIdentifier: String!
    var selectionImage: UIImageView!
    var toggle: Bool = false
    
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
        
        let circle = UIImage(systemName: "circle")!.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        selectionImage = UIImageView(image: circle)
        selectionImage.translatesAutoresizingMaskIntoConstraints = false
        selectionImage.backgroundColor = .clear
        selectionImage.contentMode = .scaleAspectFit
        contentView.addSubview(selectionImage)
    }
    
    func configure() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.heightAnchor.constraint(equalTo: heightAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            
            selectionImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            selectionImage.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5),
            selectionImage.widthAnchor.constraint(equalToConstant: 20),
            selectionImage.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func toggleSelectionImage() {
        toggle.toggle()
        if toggle {
            let largeCircleFillCircle = UIImage(systemName: "largecircle.fill.circle")?.withTintColor(.toggle, renderingMode: .alwaysOriginal)
            selectionImage.image = largeCircleFillCircle
        } else {
            let circle = UIImage(systemName: "circle")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            selectionImage.image = circle
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}
