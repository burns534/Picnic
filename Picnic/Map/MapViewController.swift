//
//  MapViewController.swift
//  Picnic
//
//  Created by Kyle Burns on 10/24/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

class MapViewController: UIViewController {
    
    let mapView = MKMapView()
    var picnic: Picnic = .empty
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.tintColor = .systemBlue
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.setRegion(MKCoordinateRegion(center: picnic.coordinate, latitudinalMeters: kDefaultLongitudinalMeters, longitudinalMeters: kDefaultLongitudinalMeters), animated: false)
        let loc = MKPointAnnotation()
        loc.coordinate = picnic.coordinate
        loc.title = picnic.name
        mapView.addAnnotation(loc)
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
