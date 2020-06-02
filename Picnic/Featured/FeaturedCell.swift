//
//  FeaturedCelll.swift
//  Picnic
//
//  Created by Kyle Burns on 5/22/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class FeaturedCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    var title: UILabel!
    var userDescription: UILabel!
    var state: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false
        // configure image
        imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        contentView.addSubview(imageView!)
        // configure cell
        self.layer.cornerRadius = 30
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 150, height: 200), cornerRadius: 30).cgPath
        buttonShadow(view: self, radius: 30, color: UIColor.darkGray.cgColor, opacity: 0.9, offset: CGSize(width: 0, height: 5))
        
        // configure title
        title = UILabel(frame: frame)
        title.translatesAutoresizingMaskIntoConstraints = false
//        title = UILabel(frame: CGRect(x: 210, y: 20, width: 100, height: 160))
        title.numberOfLines = 3
        contentView.addSubview(title)
        
        userDescription = UILabel(frame: frame)
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        userDescription.numberOfLines = 3
        contentView.addSubview(userDescription)
        
        state = UILabel(frame: frame)
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        state.numberOfLines = 1
        contentView.addSubview(state)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func configure(title: String, imageName: String, imageViewSize: CGSize) {
        dbManager.image(for: imageName) { image, error in
            if let _ = error {
                return
            } else {
                self.imageView.image = image
            }
        }
        self.title.text = title
        
        // constraints
        NSLayoutConstraint.activate([
            // supplied
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.imageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.imageView.widthAnchor.constraint(equalToConstant: imageViewSize.width),
            self.imageView.heightAnchor.constraint(equalToConstant: imageViewSize.width),
            
            self.title.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 10),
            self.title.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ])
    }
}
