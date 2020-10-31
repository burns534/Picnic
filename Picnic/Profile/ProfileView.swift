//
//  ProfileView.swift
//  Picnic
//
//  Created by Kyle Burns on 10/21/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

fileprivate let profileImageRadius: CGFloat = 25
fileprivate let bioHeightRatio: CGFloat = 0.1

protocol ProfileViewDelegate: AnyObject {
    func selectionChange(selection: ProfileView.Selection)
}

class ProfileView: UIView {
    let profileImage = UIImageView()
    let screenNameLabel = UILabel()
    let userBio = PaddedTextView()
    let posts = PicnicCollectionView(frame: .zero)
    let savedPostsButton = UIButton()
    let userPostsButton = UIButton()
    
    enum Selection {
        case saved, userPosts
    }
    
    weak var delegate: ProfileViewDelegate?
    private var selection: Selection = .saved
    
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
        UserManager.default.getProfileImage { image in
            self.profileImage.image = image
        }
        
        screenNameLabel.text = Managers.shared.auth.currentUser?.displayName
        screenNameLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        screenNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        userBio.translatesAutoresizingMaskIntoConstraints = false
        UserManager.default.getUserBio {
            self.userBio.text = $0
        }
        let divider = UIView()
        divider.backgroundColor = .darkWhite
        divider.translatesAutoresizingMaskIntoConstraints = false
        posts.translatesAutoresizingMaskIntoConstraints = false
        
//        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)
//        savedPostsButton.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        savedPostsButton.setTitle("Saved", for: .normal)
        savedPostsButton.setTitleColor(.olive, for: .normal)
        savedPostsButton.addTarget(self, action: #selector(showSavedPosts), for: .touchUpInside)
        savedPostsButton.translatesAutoresizingMaskIntoConstraints = false
        
        userPostsButton.setTitle("My Posts", for: .normal)
        userPostsButton.setTitleColor(.olive, for: .normal)
        userPostsButton.addTarget(self, action: #selector(showUserPosts), for: .touchUpInside)
        userPostsButton.translatesAutoresizingMaskIntoConstraints = false
        
        let divider1 = UIView()
        divider1.backgroundColor = .darkWhite
        divider1.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(profileImage)
        addSubview(screenNameLabel)
        addSubview(userBio)
        addSubview(divider)
        addSubview(savedPostsButton)
        addSubview(userPostsButton)
        addSubview(divider1)
        addSubview(posts)
        
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            profileImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImage.widthAnchor.constraint(equalToConstant: profileImageRadius * 2),
            profileImage.heightAnchor.constraint(equalToConstant: profileImageRadius * 2),
            
            screenNameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            screenNameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 10),
            
            userBio.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 20),
            userBio.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            userBio.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            userBio.heightAnchor.constraint(equalTo: heightAnchor, multiplier: bioHeightRatio),
            
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.topAnchor.constraint(equalTo: userBio.bottomAnchor, constant: 5),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            savedPostsButton.topAnchor.constraint(equalTo: divider.bottomAnchor),
            savedPostsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            
            userPostsButton.topAnchor.constraint(equalTo: savedPostsButton.topAnchor),
            userPostsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            
            divider1.heightAnchor.constraint(equalToConstant: 1),
            divider1.topAnchor.constraint(equalTo: savedPostsButton.bottomAnchor, constant: 5),
            divider1.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider1.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            posts.topAnchor.constraint(equalTo: divider1.bottomAnchor, constant: 5),
            posts.leadingAnchor.constraint(equalTo: leadingAnchor),
            posts.trailingAnchor.constraint(equalTo: trailingAnchor),
            posts.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc func showSavedPosts() {
        if selection != .saved {
            delegate?.selectionChange(selection: .saved)
            selection = .saved
        }
    }
    
    @objc func showUserPosts() {
        if selection != .userPosts {
            delegate?.selectionChange(selection: .userPosts)
            selection = .userPosts
        }
    }
}
