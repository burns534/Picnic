//
//  MapView.swift
//  Picnic
//
//  Created by Kyle Burns on 5/29/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
import MapKit

class LocationSelector: UIViewController {
    
    private enum AnnotationReuseID: String {
        case pin
    }
    
    var map: MKMapView!
    var coordinate: CLLocationCoordinate2D!
    var sender: NewLocationController
    var confirmButton: UIButton!
    var searchBar: UISearchBar!
    
    init(sender: NewLocationController) {
        self.sender = sender
        super.init(nibName: nil, bundle: nil)
        title = "Map"
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
// MARK: Map
        map = MKMapView(frame: .zero)
        map.setRegion(sender.region, animated: true)

        map.showsUserLocation = true
        map.mapType = .hybrid
        map.showsCompass = true
        map.showsScale = true
        map.translatesAutoresizingMaskIntoConstraints = false
        map.isUserInteractionEnabled = true
        
        /* Had to use tap gesture because long press was not working right for unknown reason. */
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(dropPin))
        map.addGestureRecognizer(tap)

        // add annotations from map icon
        for annotation in sender.map.mapView.annotations {
            print("annotation sent from sender")
            self.map.addAnnotation(annotation)
        }
        view.addSubview(map)
// MARK: Confirm Button
        confirmButton = UIButton(frame: .zero)
        confirmButton.setTitle("Confirm Selection", for: .normal)
        confirmButton.setTitleColor(.systemBlue, for: .normal)
        confirmButton.addTarget(self, action: #selector(doneButton), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmButton)
// MARK: Search Bar
        searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = self
        searchBar.barTintColor = UIColor.white.withAlphaComponent(0.6)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
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
    
    @objc func doneButton() {
        guard let loc = coordinate else {
            print("Error: MapIcon: doneButton: Cannot create picnic without selecting location")
            return
        }
        sender.coordinate = loc
        navigationController?.popViewController(animated: true)
        sender.map.configure(location: loc)
    }
    
    @objc func dropPin(_ gesture: UITapGestureRecognizer) {
        map.removeAnnotations(map.annotations.filter { $0 is MKPointAnnotation })
        let screenLocation = gesture.location(in: map)
        let mapCoordinate = map.convert(screenLocation, toCoordinateFrom: map)
        coordinate = mapCoordinate
        let pin = MKPointAnnotation()
        pin.coordinate = mapCoordinate
        map.addAnnotation(pin)
    }
}

extension LocationSelector: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
    }
}
