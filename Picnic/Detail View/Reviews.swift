//
//  Reviews.swift
//  Picnic
//
//  Created by Kyle Burns on 10/8/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

private let rowHeight: CGFloat = 200

protocol ReviewsDelegate: AnyObject {
    func presentModal()
}

class Reviews: UIView {
    let tableView = UITableView()
    var reviews: [Review] = []
    weak var delegate: ReviewsDelegate?
    
    func setup() {
        let header = UILabel()
        header.text = "Reviews"
        header.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        header.translatesAutoresizingMaskIntoConstraints = false
        
        let addReviewButton = UIButton()
        addReviewButton.backgroundColor = .olive
        addReviewButton.translatesAutoresizingMaskIntoConstraints = false
        addReviewButton.setTitle("Add Review", for: .normal)
        addReviewButton.setTitleColor(.white, for: .normal)
        addReviewButton.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .thin)
        addReviewButton.addTarget(self, action: #selector(addReview), for: .touchUpInside)
        addReviewButton.layer.cornerRadius = 5
        addReviewButton.clipsToBounds = true
        
        tableView.dataSource = self
        tableView.rowHeight = rowHeight
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.reuseID)
        
        addSubview(header)
        addSubview(addReviewButton)
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: topAnchor),
            header.leadingAnchor.constraint(equalTo: leadingAnchor),
            header.heightAnchor.constraint(equalToConstant: 40),
            
            addReviewButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            addReviewButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            addReviewButton.heightAnchor.constraint(equalToConstant: 35),
            addReviewButton.widthAnchor.constraint(equalToConstant: 150),
            
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func update(reviews: [Review]) {
        self.reviews = reviews
        tableView.reloadData()
    }
    
    @objc func addReview(_ sender: UIButton) {
        delegate?.presentModal()
    }
}

extension Reviews: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.reuseID) as? ReviewCell else {
            return .init()
        }
        cell.configure(review: reviews[indexPath.row])
        return cell
    }
}
