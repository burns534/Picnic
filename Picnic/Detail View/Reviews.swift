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
    let header = UILabel()
    var picnic = Picnic()
    func configure(picnic: Picnic) {
        self.picnic = picnic
    }
}

extension Reviews: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    
    
}
