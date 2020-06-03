//
//  MapIcon.swift
//  Picnic
//
//  Created by Kyle Burns on 5/30/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

class MapIcon: UIView {

    var mapView: MKMapView
    private var startCoordinate: CLLocationCoordinate2D!
    
    override init(frame: CGRect) {
        mapView = MKMapView(frame: .init(x: 10, y: 10, width: frame.width - 20, height: frame.height - 20))
        super.init(frame: frame)
        setupMap()
        self.addSubview(mapView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setupMap() {
//        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        mapView.mapType = .hybrid
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        
        mapView.isUserInteractionEnabled = true
        mapView.showsUserLocation = true

        mapView.layer.cornerRadius = 10
        self.layer.cornerRadius = 10
        buttonShadow(view: self, radius: 10, color: UIColor.darkGray.cgColor, opacity: 0.9, offset: .init(width: 0, height: 5))
    }
    
    func configureMap(startCoordinate: CLLocationCoordinate2D) {
        self.startCoordinate = startCoordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        let region = MKCoordinateRegion(center: self.startCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

//extension MapIcon: MKMapViewDelegate {
//
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        print((userLocation.location?.coordinate ?? self.startCoordinate).latitude)
//        let region = MKCoordinateRegion(center: userLocation.location?.coordinate ?? self.startCoordinate, span: .init(latitudeDelta: 0.25, longitudeDelta: 0.25))
//        mapView.setRegion(region, animated: true)
//    }
//}
