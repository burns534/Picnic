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
    var rating: Rating! = Rating()
    var picnic: Picnic!
    var like: HeartButton! = HeartButton()
    
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
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.maskedCorners = CACornerMask(arrayLiteral: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        // configure title
        title = UILabel(frame: frame)
        title.textAlignment = .left
        contentView.addSubview(title)
    
        contentView.addSubview(rating)
        contentView.addSubview(like)
// MARK: FIX
        let dtgr = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        dtgr.delegate = self
        dtgr.numberOfTapsRequired = 2
        addGestureRecognizer(dtgr)
        
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    // this isn't working
    override func prepareForReuse() {
        imageView.image = nil
        title.text = nil
    }
    
    func configure(picnic: Picnic) {
        rating.configure(picnic: picnic)
        rating.configureFloat()
        rating.isRatingCountHidden = false
        like.configure(id: picnic.id)
        
// MARK: change this to loading wheel
        Shared.shared.databaseManager.image(forPicnic: picnic) { image, error in
            if let error = error {
                print("Error: FeaturedCell: configure: \(error.localizedDescription)")
                return
            } else {
                self.imageView.image = image
            }
        }
        
// apply shadow to cell
        layer.cornerRadius = 10
        setShadow(radius: 10, color: .darkGray, opacity: 0.6, offset: CGSize(width: 0, height: 5))
        self.picnic = picnic
        self.title.text = picnic.name
        
// MARK: Constraints
        NSLayoutConstraint.activate([
            // supplied
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.heightAnchor.constraint(equalTo: heightAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalToConstant: imageViewSize.height),
            
            self.title.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            self.title.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor, constant: 10),
            self.title.widthAnchor.constraint(equalToConstant: 200),
            self.title.heightAnchor.constraint(equalToConstant: 20),
            
            rating.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -30),
            rating.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),
            rating.widthAnchor.constraint(equalToConstant: rating.width),
            rating.heightAnchor.constraint(equalToConstant: rating.starSize.height),
            
            like.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            like.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            like.widthAnchor.constraint(equalToConstant: 50),
            like.heightAnchor.constraint(equalToConstant: 45),
        ])
    }
    
    @objc func doubleTap(_ sender: UITapGestureRecognizer) {
//        like.like()
    }
}

extension FeaturedCell: UIGestureRecognizerDelegate {
    
}
