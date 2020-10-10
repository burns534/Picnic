//
//  FeaturedCelll.swift
//  Picnic
//
//  Created by Kyle Burns on 5/22/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

fileprivate let imageViewSize: CGSize = CGSize(width: kFeaturedCellSize.width, height: 200)
fileprivate let kTitlePointSize: CGFloat = 25.0
let kHeartFrame = CGRect(x: 0, y: 0, width: 50, height: 45)

class FeaturedCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var title: UILabel!
    var rating: Rating!
    var picnic: Picnic!
    var like: HeartButton!
    var location: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        // configure image
        imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.setGradient(colors: [.clear, UIColor.black.withAlphaComponent(0.4)])
        contentView.addSubview(imageView)
        
        // configure title
        title = UILabel(frame: frame)
        title.textColor = .white
        title.font = UIFont.systemFont(ofSize: kTitlePointSize, weight: .semibold)
        contentView.addSubview(title)
        
        rating = Rating()
        contentView.addSubview(rating)
        like = HeartButton(pointSize: 35)
        like.addTarget(self, action: #selector(likePress), for: .touchUpInside)
        contentView.addSubview(like)
        
        location = UILabel()
        location.textColor = .white
        contentView.addSubview(location)
        
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // this isn't working
    override func prepareForReuse() {
        imageView.image = nil
        title.text = nil
        Managers.shared.databaseManager.removeListener(like)
    }
    
    func configure(picnic: Picnic) {
        rating.configure(picnic: picnic)
        rating.mode = .displayWithCount
        Managers.shared.databaseManager.addSaveListener(picnic: picnic, listener: like)
// MARK: change this to loading wheel
        Managers.shared.databaseManager.image(forPicnic: picnic) {
            self.imageView.image = $0
        }
        
// apply shadow to cell
        layer.cornerRadius = 10
        setShadow(radius: 10, color: .darkGray, opacity: 0.6, offset: CGSize(width: 0, height: 5))
        self.picnic = picnic
        title.text = picnic.name
// MARK: I don't really like this
        location.text = (picnic.city ?? "") + ", " + (picnic.state ?? "")
        
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

            location.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            location.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            location.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.centerXAnchor, constant: 5)
        ])
    }
    
    @objc func likePress(_ sender: HeartButton) {
        if sender.isActive {
            Managers.shared.databaseManager.unsavePost(picnic: picnic)
        } else {
            Managers.shared.databaseManager.savePost(picnic: picnic)
        }
    }
}
