//
//  HeartButton.swift
//  Picnic
//
//  Created by Kyle Burns on 7/31/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

protocol HeartButtonDelegate: AnyObject {
    func likePress(isLiked: Bool)
}

class HeartButton: UIButton {
    weak var delegate: HeartButtonDelegate?
    private var isLiked: Bool = false
    let heartFill: UIImage?
    let heart: UIImage?

    /**
        Designated Initializer
     */
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        addTarget(self, action: #selector(likePress), for: .touchDown)
//        Shared.shared.user.isLiked(post: uid) {
//            self.isLiked = $0
//            let heart = UIImage(systemName: $0 ? "heart.fill" : "heart", withConfiguration: self.config)?.withRenderingMode(.alwaysTemplate)
//            self.setImage(heart, for: .normal)
//            self.imageView?.tintColor = $0 ? .red : .white
//            self.imageView!.translatesAutoresizingMaskIntoConstraints = false
//
        
//        imageView?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        imageView?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        imageView?.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
//        imageView?.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8)
//    }
    
    init(pointSize: CGFloat) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .thin)
        heartFill = UIImage(systemName: "heart.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        heart = UIImage(systemName: "heart", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        let frame = CGRect(x: 0, y: 0, width: pointSize, height: pointSize)
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLiked(isLiked: Bool) {
        self.isLiked = true
        setImage(isLiked ? heartFill : heart, for: .normal)
        imageView?.tintColor = isLiked ? .red : .white
    }

//    func update() {
//        guard let id = uid else { return }
//        Shared.shared.user.isLiked(post: id) { value in
//            self.isLiked = value
//            let heart = UIImage(systemName: value ? "heart.fill" : "heart", withConfiguration: self.config)?.withRenderingMode(.alwaysTemplate)
//            self.imageView?.image = heart
//            self.imageView?.tintColor = value ? .red : .white
//        }
//    }
    
//    func like() {
//        guard let id = uid else { return }
//        isLiked = true
//
//        imageView?.image = heart
//        imageView?.tintColor = .red
//        Shared.shared.user.likePost(id: id, value: true)
//    }
//
//    @objc func likePress(_ sender: UIButton) {
//        guard let id = uid else { return }
//        isLiked.toggle()
//        let heart = UIImage(systemName: isLiked ? "heart.fill" : "heart", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
//        imageView?.image = heart
//        imageView?.tintColor = isLiked ? .red : .white
//        Shared.shared.user.likePost(id: id, value: isLiked)
//    }
}
