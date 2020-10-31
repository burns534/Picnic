//
//  Profile.swift
//  Picnic
//
//  Created by Kyle Burns on 7/31/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class Profile: UIViewController {
    
    let profileView = ProfileView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .white

        profileView.translatesAutoresizingMaskIntoConstraints = false
        profileView.posts.delegate = self
        profileView.delegate = self
        view.addSubview(profileView)
        NSLayoutConstraint.activate([
            profileView.topAnchor.constraint(equalTo: view.topAnchor),
            profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        UserManager.default.addSavedPostQuery(for: "Saved") { picnics in
            self.profileView.posts.refresh(picnics: picnics)
        }
        UserManager.default.addUserPostQuery(for: "UserPosts")
    }

}

extension Profile: PicnicCollectionViewDelegate {
    func refresh(completion: @escaping ([Picnic]) -> ()) {
        UserManager.default.refreshQuery(forSavedQuery: "Saved") {
            completion($0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FeaturedCell else { return }
        let detailView = DetailController()
        detailView.picnic = cell.picnic
        present(detailView, animated: true)
    }
}

extension Profile: ProfileViewDelegate {
    func selectionChange(selection: ProfileView.Selection) {
        switch selection {
        case .saved:
            UserManager.default.refreshQuery(forSavedQuery: "Saved") {
                self.profileView.posts.refresh(picnics: $0)
            }
        case .userPosts:
            UserManager.default.refreshQuery(forUserPostQuery: "UserPosts") {
                self.profileView.posts.refresh(picnics: $0)
            }
        }
    }
}
