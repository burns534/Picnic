//
//  MapIcon.swift
//  Picnic
//
//  Created by Kyle Burns on 5/30/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

class MapIcon: UIView {

    var mapView: MKMapView!
    private var location: CLLocationCoordinate2D!
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setup() {
        isUserInteractionEnabled = true
        layer.cornerRadius = 10
        
        mapView = MKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.mapType = .hybrid
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.showsUserLocation = true
        mapView.layer.cornerRadius = 10
        
        setShadow(radius: 5, color: UIColor.darkGray.cgColor, opacity: 0.9, offset: .init(width: 0, height: 2))
        addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mapView.centerYAnchor.constraint(equalTo: centerYAnchor),
            // 5 on each side for shadow
            mapView.widthAnchor.constraint(equalTo: widthAnchor, constant: -10),
            mapView.heightAnchor.constraint(equalTo: heightAnchor, constant: -10)
        ])
    }
    
    func configure() {
        guard let location = Shared.shared.locationManager.location else {
            mapView.setRegion(MKCoordinateRegion(), animated: true)
            return
        }
        self.location = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        let region = MKCoordinateRegion(center: self.location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func configure(location: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations.filter { $0 is MKPointAnnotation })
        let pin = MKPointAnnotation()
        pin.coordinate = location
        mapView.addAnnotation(pin)
        mapView.setCenter(location, animated: true)
    }
}
