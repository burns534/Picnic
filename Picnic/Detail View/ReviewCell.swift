//
//  ReviewCell.swift
//  Picnic
//
//  Created by Kyle Burns on 10/11/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

private let profileSize: CGFloat = 35

class ReviewCell: UITableViewCell {
    static let reuseID: String = "ReviewCellReuseID"
    let rating = Rating()
    let timestamp = UILabel()
    let userNameLabel = UILabel()
    let content = UITextView()
    let profileIcon = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        rating.mode = .display
        rating.style = .grayFill
        
        profileIcon.clipsToBounds = true
        profileIcon.layer.cornerRadius = profileSize / 2.0
        contentView.addSubview(rating)
        contentView.addSubview(timestamp)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(content)
        contentView.addSubview(profileIcon)
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            profileIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            profileIcon.widthAnchor.constraint(equalToConstant: profileSize),
            profileIcon.heightAnchor.constraint(equalToConstant: profileSize),
            
            userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: profileIcon.trailingAnchor, constant: 10),
            userNameLabel.widthAnchor.constraint(equalToConstant: 120),
            userNameLabel.heightAnchor.constraint(equalToConstant: 40),
            
            timestamp.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor),
            timestamp.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            timestamp.widthAnchor.constraint(equalToConstant: 120),
            timestamp.heightAnchor.constraint(equalToConstant: 30),
            
            rating.topAnchor.constraint(equalTo: contentView.topAnchor),
            rating.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rating.widthAnchor.constraint(equalToConstant: rating.width),
            rating.heightAnchor.constraint(equalToConstant: rating.starSize),
            
            content.topAnchor.constraint(equalTo: timestamp.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(review: Review) {
        rating.setRating(value: Float(review.rating))
        userNameLabel.text = review.userDisplayName
        content.text = review.content
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = review.userPhotoURL,
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.profileIcon.image = image
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
