//
//  FeaturedCelll.swift
//  Picnic
//
//  Created by Kyle Burns on 5/22/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

fileprivate var imageViewSize: CGSize = CGSize(width: kFeaturedCellSize.width, height: 200)

class FeaturedCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var title: UILabel!
    var rating: Rating!
    var picnic: Picnic!
    var like: HeartButton!
    var location: UILabel!
    
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
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        // configure title
        title = UILabel(frame: frame)
        title.textColor = .white
        title.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        contentView.addSubview(title)
        
        rating = Rating()
        contentView.addSubview(rating)
        like = HeartButton()
        contentView.addSubview(like)
        
        location = UILabel()
        location.textColor = .white
        contentView.addSubview(location)
        
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // MARK: FIX
        let dtgr = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        dtgr.delegate = self
        dtgr.numberOfTapsRequired = 2
        addGestureRecognizer(dtgr)
    }
    
    // this isn't working
    override func prepareForReuse() {
        imageView.image = nil
        title.text = nil
    }
    
    func configure(picnic: Picnic) {
        rating.configure(picnic: picnic)
        rating.mode = .displayWithCount
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
        title.text = picnic.name
        location.text = picnic.city + ", " + picnic.state
        
// MARK: Constraints
        NSLayoutConstraint.activate([
            // supplied
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.heightAnchor.constraint(equalTo: heightAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            
            rating.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            rating.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),
            rating.widthAnchor.constraint(equalToConstant: rating.width),
            rating.heightAnchor.constraint(equalToConstant: rating.starSize),
            
            title.bottomAnchor.constraint(equalTo: rating.topAnchor),
            title.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),
            title.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor),
            
            like.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            like.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            like.widthAnchor.constraint(equalToConstant: 50),
            like.heightAnchor.constraint(equalToConstant: 45),
            
            location.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            location.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            location.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.centerXAnchor, constant: 5)
        ])
    }
    
    @objc func doubleTap(_ sender: UITapGestureRecognizer) {
//        like.like()
    }
}

extension FeaturedCell: UIGestureRecognizerDelegate {
    
}
