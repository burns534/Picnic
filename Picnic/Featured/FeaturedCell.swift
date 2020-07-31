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
    var like: UIButton!
    
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
        
        like = HeartButton(isLiked: false, frame: .zero)
        like.addTarget(self, action: #selector(likePress), for: .touchDown)
        like.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(like)
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        title.text = nil
    }
    
    @objc func likePress(_ sender: UIButton) {
        guard let s = sender as? HeartButton else { return }
        s.toggle()
        Shared.shared.user.likePost(id: picnic.id)
    }
    
    func configure(picnic: Picnic) {
        rating = Rating(picnic: picnic)
        rating.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rating)
        
// MARK: change this to loading wheel
        self.imageView.image = UIImage(named: "loading.jpg")
        Shared.shared.databaseManager.image(forPicnic: picnic) { image, error in
            if let error = error {
                self.imageView.image = UIImage(named: "loading.jpg")
                print("Error: FeaturedCell: configure: \(error.localizedDescription)")
                return
            } else {
                self.imageView.image = image
            }
        }
        
// apply shadow to cell
        layer.cornerRadius = 10
        setShadow(radius: 10, color: UIColor.darkGray.cgColor, opacity: 0.6, offset: CGSize(width: 0, height: 5))
        
        rating.configureFloat(rating: CGFloat(picnic.rating))
        self.picnic = picnic
        self.title.text = picnic.name
        
// MARK: Constraints
        NSLayoutConstraint.activate([
            // supplied
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.heightAnchor.constraint(equalTo: heightAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalToConstant: imageViewSize.height),
            
            self.title.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            self.title.leftAnchor.constraint(equalTo: self.imageView.leftAnchor, constant: 10),
            self.title.widthAnchor.constraint(equalToConstant: 200),
            self.title.heightAnchor.constraint(equalToConstant: 20),
            
            rating.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -30),
            rating.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: 10),
            rating.widthAnchor.constraint(equalToConstant: rating.width),
            rating.heightAnchor.constraint(equalToConstant: rating.starSize.height),
            
            like.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            like.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            like.widthAnchor.constraint(equalToConstant: 50),
            like.heightAnchor.constraint(equalToConstant: 45),
        ])
    }
}
