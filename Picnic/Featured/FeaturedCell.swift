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
    var userDescription: UITextView!
    var state: UILabel!
    var rating: Rating!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setup(cellSize: CGSize) {
        self.backgroundColor = .white
        //self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        // configure image
        imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        contentView.addSubview(imageView!)
        // configure cell
        self.layer.cornerRadius = 30
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: cellSize.width, height: cellSize.height), cornerRadius: 30).cgPath
        buttonShadow(view: self, radius: 10, color: UIColor.darkGray.cgColor, opacity: 0.9, offset: CGSize(width: 0, height: 5))
        
        // configure title
        title = UILabel(frame: frame)
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 3
        contentView.addSubview(title)
        
        userDescription = UITextView(frame: frame)
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userDescription)
        
        state = UILabel(frame: frame)
        state.translatesAutoresizingMaskIntoConstraints = false
        state.numberOfLines = 1
        contentView.addSubview(state)
        
        rating = Rating(frame: .zero, rating: 3)
        rating.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rating)
    }
    
    func configure(title: String, imageName: String, userDescription: String, state: String, imageViewSize: CGSize) {
        dbManager.image(for: imageName) { image, error in
            if let _ = error {
                return
            } else {
                self.imageView.image = image
            }
        }
        self.title.text = title
        self.userDescription.text = userDescription
        self.userDescription.sizeToFit()
        self.state.text = state
    
        // constraints
        NSLayoutConstraint.activate([
            // supplied
            
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.contentView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.contentView.widthAnchor.constraint(equalTo: self.widthAnchor),
            
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 5),
            self.imageView.widthAnchor.constraint(equalToConstant: imageViewSize.width),
            self.imageView.heightAnchor.constraint(equalToConstant: imageViewSize.width),
            
            self.title.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            self.title.leftAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: 10),
            self.title.widthAnchor.constraint(equalToConstant: 100),
            self.title.heightAnchor.constraint(equalToConstant: 20),
            
            self.rating.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 5),
            self.rating.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor),
            self.rating.widthAnchor.constraint(equalToConstant: 79),
            self.rating.heightAnchor.constraint(equalToConstant: 15),
            
            // Slight issue with text alignment here
            self.userDescription.topAnchor.constraint(equalTo: self.rating.bottomAnchor, constant: 5),
            self.userDescription.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
//            self.userDescription.widthAnchor.constraint(equalToConstant: 250),
//            self.userDescription.heightAnchor.constraint(equalToConstant: 80),
            
            
            self.state.topAnchor.constraint(equalTo: self.userDescription.bottomAnchor, constant: 5),
            self.state.widthAnchor.constraint(equalToConstant: 200),
            self.state.heightAnchor.constraint(equalToConstant: 20),
            self.state.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ])
    }
}
