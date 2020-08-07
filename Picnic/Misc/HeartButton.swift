//
//  HeartButton.swift
//  Picnic
//
//  Created by Kyle Burns on 7/31/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class HeartButton: UIButton {
    
    var isLiked: Bool = false
    let config = UIImage.SymbolConfiguration(weight: .light)
    var uid: String!
    
    func configure(id: String) {
        uid = id
        addTarget(self, action: #selector(likePress), for: .touchDown)
        Shared.shared.user.isLiked(post: uid) {
            self.isLiked = $0
            let heart = UIImage(systemName: $0 ? "heart.fill" : "heart", withConfiguration: self.config)?.withRenderingMode(.alwaysTemplate)
            self.setImage(heart, for: .normal)
            self.imageView?.tintColor = $0 ? .red : .white
            self.imageView!.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.imageView!.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                self.imageView!.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                self.imageView!.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),
                self.imageView!.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8)
            ])
        }
    }

    func update() {
        guard let id = uid else { return }
        Shared.shared.user.isLiked(post: id) { value in
            self.isLiked = value
            let heart = UIImage(systemName: value ? "heart.fill" : "heart", withConfiguration: self.config)?.withRenderingMode(.alwaysTemplate)
            self.imageView?.image = heart
            self.imageView?.tintColor = value ? .red : .white
        }
    }
    
    func like() {
        guard let id = uid else { return }
        isLiked = true
        let heart = UIImage(systemName: "heart.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        imageView?.image = heart
        imageView?.tintColor = .red
        Shared.shared.user.likePost(id: id, value: true)
    }
    
    @objc func likePress(_ sender: UIButton) {
        guard let id = uid else { return }
        isLiked.toggle()
        let heart = UIImage(systemName: isLiked ? "heart.fill" : "heart", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        imageView?.image = heart
        imageView?.tintColor = isLiked ? .red : .white
        Shared.shared.user.likePost(id: id, value: isLiked)
    }
}
