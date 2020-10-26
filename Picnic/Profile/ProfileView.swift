//
//  ProfileView.swift
//  Picnic
//
//  Created by Kyle Burns on 10/21/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

fileprivate let profileImageRadius: CGFloat = 25

class ProfileView: UIView {
    
    let profileImage = UIImageView()
    let screenNameLabel = UILabel()
// TODO: Custom collectionview for saved posts
//    let savedPosts =

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 2
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.cornerRadius = 25
        Managers.shared.getProfileImage { image in
            self.profileImage.image = image
        }
        
        screenNameLabel.text = Managers.shared.auth.currentUser?.displayName
        screenNameLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        screenNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(profileImage)
        addSubview(screenNameLabel)
        
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            profileImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImage.widthAnchor.constraint(equalToConstant: profileImageRadius * 2),
            profileImage.heightAnchor.constraint(equalToConstant: profileImageRadius * 2),
            
            screenNameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            screenNameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 10),
        ])
    }
}
