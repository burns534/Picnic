//
//  ReviewCell.swift
//  Picnic
//
//  Created by Kyle Burns on 10/11/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

private let profileSize: CGFloat = 40

class ReviewCell: UITableViewCell {
    static let reuseID: String = "ReviewCellReuseID"
    let rating = Rating()
    let timestamp = UILabel()
    let userNameLabel = UILabel()
    let content = UITextView()
    let profileIcon = UIImageView(image: UIImage(systemName: "person"))
    let imageStackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        rating.mode = .display
        rating.style = .wireframe
        profileIcon.clipsToBounds = true
        profileIcon.layer.cornerRadius = profileSize / 2.0
        profileIcon.layer.borderWidth = 1
        profileIcon.layer.borderColor = UIColor.darkWhite.cgColor
        
        userNameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        timestamp.font = UIFont.systemFont(ofSize: 12)
        content.font = UIFont.systemFont(ofSize: 20)
        
        let imageScrollView = UIScrollView()
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.bounces = false
        imageScrollView.showsVerticalScrollIndicator = false
        imageScrollView.showsHorizontalScrollIndicator = false
        
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        imageStackView.axis = .horizontal
        imageStackView.alignment = .center
        imageStackView.spacing = 10
        imageStackView.distribution = .equalSpacing
        imageScrollView.addSubview(imageStackView)
        
        contentView.addSubview(rating)
        contentView.addSubview(timestamp)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(content)
        contentView.addSubview(profileIcon)
        contentView.addSubview(imageScrollView)
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            profileIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            profileIcon.widthAnchor.constraint(equalToConstant: profileSize),
            profileIcon.heightAnchor.constraint(equalToConstant: profileSize),
            
            userNameLabel.centerYAnchor.constraint(equalTo: profileIcon.centerYAnchor, constant: -10),
            userNameLabel.leadingAnchor.constraint(equalTo: profileIcon.trailingAnchor, constant: 10),
            userNameLabel.widthAnchor.constraint(equalToConstant: 120),
            userNameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            timestamp.centerYAnchor.constraint(equalTo: profileIcon.centerYAnchor, constant: 10),
            timestamp.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            timestamp.widthAnchor.constraint(equalToConstant: 120),
            timestamp.heightAnchor.constraint(equalToConstant: 15),
            
            rating.centerYAnchor.constraint(equalTo: profileIcon.centerYAnchor),
            rating.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rating.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
            
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
        rating.rating = review.rating
        userNameLabel.text = review.userDisplayName
        content.text = review.content
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        timestamp.text = dateFormatter.string(from: review.date)
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
}
