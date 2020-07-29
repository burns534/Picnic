//
//  FeaturedCelll.swift
//  Picnic
//
//  Created by Kyle Burns on 5/22/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

fileprivate var imageViewSize: CGSize = CGSize(width: cellSize.width, height: 200)

class FeaturedCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var title: UILabel!
    var rating: Rating!
    var picnic: Picnic!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setup() {
        self.backgroundColor = .white
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        // configure image
        imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.maskedCorners = CACornerMask(arrayLiteral: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        // configure title
        title = UILabel(frame: frame)
        title.textAlignment = .left
        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(title)
        
        rating = Rating()
        rating.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rating)
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        title.text = nil
    }
    
    func configure(picnic: Picnic) {
// MARK: change this to loading wheel
        self.imageView.image = UIImage(named: "loading.jpg")
        dbManager.image(forPicnic: picnic) { image, error in
            if let error = error {
                self.imageView.image = UIImage(named: "loading.jpg")
                print(error.localizedDescription)
                return
            } else {
                self.imageView.image = image
            }
        }
// apply shadow to cell
        layer.cornerRadius = 10
        layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: cellSize.width, height: cellSize.height), cornerRadius: 10).cgPath
        setShadow(radius: 10, color: UIColor.darkGray.cgColor, opacity: 0.6, offset: CGSize(width: 0, height: 5))
        
        rating.configureFloat(rating: CGFloat(picnic.rating))
        self.picnic = picnic
        self.title.text = picnic.name
// MARK: Constraints
        NSLayoutConstraint.activate([
            // supplied
            self.contentView.topAnchor.constraint(equalTo: topAnchor),
            self.contentView.leftAnchor.constraint(equalTo: leftAnchor),
            self.contentView.heightAnchor.constraint(equalTo: heightAnchor),
            self.contentView.widthAnchor.constraint(equalTo: widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalToConstant: imageViewSize.height),
            
            self.title.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            self.title.leftAnchor.constraint(equalTo: self.imageView.leftAnchor, constant: 10),
            self.title.widthAnchor.constraint(equalToConstant: 200),
            self.title.heightAnchor.constraint(equalToConstant: 20),
            
            self.rating.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: -30),
            self.rating.leftAnchor.constraint(equalTo: self.imageView.leftAnchor, constant: 10),
            self.rating.widthAnchor.constraint(equalToConstant: self.rating.width),
            self.rating.heightAnchor.constraint(equalToConstant: self.rating.starSize.height),
        ])
    }
}
