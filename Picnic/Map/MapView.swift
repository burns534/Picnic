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
    
    private enum AnnotationReuseID: String {
        case pin
    }
    
    var map: MKMapView!
    var coordinates: CLLocationCoordinate2D!
    var sender: NewLocationController
    var confirmButton: UIButton!
    var searchBar: UISearchBar!
    
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

        map = MKMapView(frame: .zero)
        //map.delegate = self
        
        // set region to the map icon's region in the new picnic page
        //map.setRegion(sender.map.mapView.region, animated: true)
        map.region = sender.map.mapView.region
        
        map.showsUserLocation = true
        map.mapType = .hybrid
        map.showsCompass = true
        map.showsScale = true
        map.translatesAutoresizingMaskIntoConstraints = false
        
        // add annotations from map icon
        for annotation in sender.map.mapView.annotations {
            print("annotation sent from sender")
            self.map.addAnnotation(annotation)
        }
        
        confirmButton = UIButton(frame: .zero)
        confirmButton.setTitle("Confirm Selection", for: .normal)
        confirmButton.setTitleColor(.systemBlue, for: .normal)
        confirmButton.addTarget(self, action: #selector(handleDoneButton), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        // for dropping pins
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        lpgr.minimumPressDuration = 0.3
        map.addGestureRecognizer(lpgr)
        
        searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = self
        searchBar.barTintColor = UIColor.white.withAlphaComponent(0.6)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        
        view.addSubview(map)
        view.addSubview(confirmButton)
        view.addSubview(searchBar)
      //  navigationController?.navigationItem.searchController
        
        NSLayoutConstraint.activate([
        searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
        searchBar.widthAnchor.constraint(equalToConstant: 400),
        searchBar.heightAnchor.constraint(equalToConstant: 30),
        map.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
        map.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: 0),
        map.heightAnchor.constraint(equalToConstant: 500),
        confirmButton.topAnchor.constraint(equalTo: map.bottomAnchor),
        confirmButton.widthAnchor.constraint(equalToConstant: 200),
        confirmButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    // does not appear to be necessary
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        map.removeAnnotations(map.annotations)
    }
    
    @objc func handleDoneButton() {
        if self.coordinates != nil {
            self.sender.coordinates = self.coordinates
            self.sender.map.mapView.removeAnnotations(self.sender.map.mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.coordinates
            navigationController?.popViewController(animated: true)
            self.sender.map.mapView.setCenter(annotation.coordinate, animated: true)
            self.sender.map.mapView.addAnnotation(annotation)
            self.sender.reloadInputViews()
        }
    }
    // There is a problem with the gesture recognizer
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        print("handleLongPressGesture")
        switch gesture.state {
        case .began:
            print(".began")
            let screenLocation = gesture.location(in: self.map)
            let mapCoordinate = map.convert(screenLocation, toCoordinateFrom: self.map)
            let annotation = PlaceAnnotation(coordinate: mapCoordinate)
            annotation.title = "hello"
            self.map.addAnnotation(annotation)
            self.coordinates = mapCoordinate
        case .ended:
            print(".ended")
        default:
            return
        }
    }
}

extension MapView: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
    }
}
