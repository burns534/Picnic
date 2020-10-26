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
    static let reuseID = "FeaturedCellReuseID"
    let imageView = UIImageView()
    let title = UILabel()
    let rating = Rating(frame: .zero)
    let like = HeartButton(pointSize: 35)
    let location = UILabel()
    var picnic: Picnic = .empty
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.setGradient(colors: [.clear, UIColor.black.withAlphaComponent(0.4)], bounds: bounds)
        contentView.addSubview(imageView)
        
        // configure title
        title.textColor = .white
        title.font = UIFont.systemFont(ofSize: kTitlePointSize, weight: .semibold)
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.8
        
        like.addTarget(self, action: #selector(likePress), for: .touchUpInside)
        
        location.textColor = .white
        contentView.addSubview(location)
        contentView.addSubview(title)
        contentView.addSubview(rating)
        contentView.addSubview(like)
        
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            rating.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            rating.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),
            rating.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            
            title.bottomAnchor.constraint(equalTo: rating.topAnchor),
            title.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),
            title.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10),
            
            like.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            like.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            location.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            location.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            location.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.centerXAnchor, constant: 5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        title.text = nil
        Managers.shared.databaseManager.removeListener(like)
    }
    
    func configure(picnic: Picnic) {
        rating.rating = picnic.rating
        rating.mode = .displayWithCount
        rating.style = .wireframe
        Managers.shared.databaseManager.addSaveListener(picnic: picnic, listener: like) { liked in
            self.like.setActive(isActive: liked)
        }
// MARK: change this to loading wheel
        Managers.shared.databaseManager.image(forPicnic: picnic) { [weak self] image in
            self?.imageView.image = image
            self?.imageView.setGradient(colors: [
                .clear,
                UIColor.black.withAlphaComponent(0.3)
            ])
            self?.imageView.setGradient(colors: [
                UIColor.black.withAlphaComponent(0.3),
                .clear
            ])
        }
        
// apply shadow to cell
        layer.cornerRadius = 10
        setShadow(radius: 10, color: .darkGray, opacity: 0.6, offset: CGSize(width: 0, height: 5))
        self.picnic = picnic
        title.text = picnic.name
// MARK: I don't really like this
        location.text = (picnic.city ?? "") + ", " + (picnic.state ?? "")
    }
    
    @objc func likePress(_ sender: HeartButton) {
        if sender.isActive {
            Managers.shared.databaseManager.unsavePost(picnic: picnic)
        } else {
            Managers.shared.databaseManager.savePost(picnic: picnic)
        }
    }
}
