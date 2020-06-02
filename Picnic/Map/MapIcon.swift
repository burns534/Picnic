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
    
    override init(frame: CGRect) {
        mapView = MKMapView(frame: .init(x: 10, y: 10, width: frame.width - 20, height: frame.height - 20))
        super.init(frame: frame)
        configureMap()
        self.addSubview(mapView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func configureMap() {
        //mapView.setUserTrackingMode(.followWithHeading, animated: true)
        
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false

        let span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        let region = MKCoordinateRegion(center: mapView.userLocation.location?.coordinate ?? startCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        mapView.mapType = .hybrid
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        
        mapView.isUserInteractionEnabled = true
        
        mapView.showsUserLocation = false

        mapView.layer.cornerRadius = 10
        self.layer.cornerRadius = 10
        buttonShadow(view: self, radius: 10, color: UIColor.darkGray.cgColor, opacity: 0.9, offset: .init(width: 0, height: 5))
    }
}

extension MapIcon: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print((userLocation.location?.coordinate ?? startCoordinate).latitude)
        let region = MKCoordinateRegion(center: userLocation.location?.coordinate ?? startCoordinate, span: .init(latitudeDelta: 0.25, longitudeDelta: 0.25))
        mapView.setRegion(region, animated: true)
    }
}
