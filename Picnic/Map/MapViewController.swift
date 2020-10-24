//
//  MapViewController.swift
//  Picnic
//
//  Created by Kyle Burns on 10/24/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.tintColor = .systemBlue
    }

}
