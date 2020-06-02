//
//  MapView.swift
//  Picnic
//
//  Created by Kyle Burns on 5/29/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
import MapKit

class MapView: UIViewController {
    
    var map: MKMapView!
    var coordinates: CLLocationCoordinate2D!
    var sender: NewLocationController
    var confirmButton: UIButton!
    
    init(sender: UIViewController) {
        self.sender = sender as! NewLocationController
        super.init(nibName: nil, bundle: nil)
        title = "Map"
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        // Do any additional setup after loading the view.
        map = MKMapView(frame: .zero)
        // assign delegate
        map.delegate = self
        
        map.setRegion(sender.map.mapView.region, animated: true)
        
        map.showsUserLocation = true
        map.mapType = .hybrid
        map.showsCompass = true
        map.showsScale = true
        map.translatesAutoresizingMaskIntoConstraints = false
        
        for annotation in sender.map.mapView.annotations {
            self.map.addAnnotation(annotation)
        }
        
        confirmButton = UIButton(frame: .zero)
        confirmButton.setTitle("Confirm Selection", for: .normal)
        confirmButton.addTarget(self, action: #selector(handleDoneButton), for: .touchUpInside)
        confirmButton.setTitleColor(.systemBlue, for: .normal)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        map.addGestureRecognizer(lpgr)
        lpgr.minimumPressDuration = 0.3
        view.addSubview(map)
        view.addSubview(confirmButton)
        NSLayoutConstraint.activate([
        confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        confirmButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        map.bottomAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.bottomAnchor, multiplier: 1),
        map.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: 0),
        map.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1.0, constant: -60)
        ])
    }
    // does not appear to be necessary
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        map.removeAnnotations(map.annotations)
    }
    
    @objc func track(_ sender: UIButton) {
        // show user location
        map.showsUserLocation = true
        map.setUserTrackingMode(.follow, animated: true)
    }
    
    @objc func handleDoneButton() {
        dismiss(animated: true) {
                if self.coordinates != nil {
                    self.sender.coordinates = self.coordinates
                    self.sender.map.mapView.setRegion(self.map.region, animated: true)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = self.coordinates
                    self.sender.map.mapView.removeAnnotations(self.sender.map.mapView.annotations)
                    self.sender.map.mapView.addAnnotation(annotation)
                    self.sender.reloadInputViews()
            }
        }
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.map.removeAnnotations(self.map.annotations)
            let screenLocation = gesture.location(in: self.map)
            let mapCoordinate = map.convert(screenLocation, toCoordinateFrom: self.map)
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapCoordinate
            self.map.addAnnotation(annotation)
            self.coordinates = mapCoordinate
        }
    }
}

extension MapView: MKMapViewDelegate {
   
}

extension MapView: UINavigationControllerDelegate {
    
}
