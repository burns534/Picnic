//
//  Reviews.swift
//  Picnic
//
//  Created by Kyle Burns on 10/8/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class Reviews: UIView {
    let tableView = UITableView()
    var reviews: [Review] = []
    
    func setup() {
        let header = UILabel()
        header.text = "Reviews"
        header.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        header.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.reuseID)
        
        addSubview(header)
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: topAnchor),
            header.leadingAnchor.constraint(equalTo: leadingAnchor),
            header.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func update(reviews: [Review]) {
        self.reviews = reviews
        tableView.reloadData()
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
