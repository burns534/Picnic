//
//  ReviewCell.swift
//  Picnic
//
//  Created by Kyle Burns on 10/11/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class ReviewCell: UITableViewCell {
    static let reuseID: String = "ReviewCellReuseID"
    let rating = Rating()
    let timestamp = UILabel()
    let userNameLabel = UILabel()
    let content = UITextView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        rating.mode = .display
        rating.style = .grayFill
        userNameLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        addSubview(rating)
        addSubview(timestamp)
        addSubview(userNameLabel)
        addSubview(content)
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userNameLabel.widthAnchor.constraint(equalToConstant: 100),
            userNameLabel.heightAnchor.constraint(equalToConstant: 50),
            
            timestamp.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor),
            timestamp.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            timestamp.widthAnchor.constraint(equalToConstant: 100),
            timestamp.heightAnchor.constraint(equalToConstant: 50),
            
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
        Managers.shared.databaseManager.getUser(for: review.uid) { user in
            self.userNameLabel.text = user.displayName
        }
        content.text = review.content
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
