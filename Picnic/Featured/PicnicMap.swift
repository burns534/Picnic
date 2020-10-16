//
//  PicnicMap.swift
//  Picnic
//
//  Created by Kyle Burns on 10/10/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

fileprivate let annotationSize: CGFloat = 70

protocol PicnicMapDelegate: AnyObject {
    func annotationTap(picnic: Picnic)
}

class PicnicMap: UIView {
    let map = MKMapView()
    weak var delegate: PicnicMapDelegate?
    
    func setup() {
        map.delegate = self
        map.translatesAutoresizingMaskIntoConstraints = false
        map.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(PicnicAnnotation.self))
        map.setRegion(MKCoordinateRegion(center: Managers.shared.locationManager.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)), animated: false)
        map.showsScale = true
        map.showsCompass = true
        map.showsUserLocation = true
        addSubview(map)
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: topAnchor),
            map.bottomAnchor.constraint(equalTo: bottomAnchor),
            map.leadingAnchor.constraint(equalTo: leadingAnchor),
            map.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func update(picnics: [Picnic]) {
        map.removeAnnotations(map.annotations)
        map.addAnnotations(picnics.map { PicnicAnnotation(picnic: $0) })
    }
}

extension PicnicMap: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        if let annotation = annotation as? PicnicAnnotation {
            let reuseIdentifier = NSStringFromClass(PicnicAnnotation.self)
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation) as? CustomAnnotationView else { return nil }
            annotationView.configure(annotation: annotation)
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? PicnicAnnotation else { return }
        delegate?.annotationTap(picnic: annotation.picnic)
    }
}

class PicnicAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate = CLLocationCoordinate2D()
    var title: String?
    var picnic: Picnic
    
    init(picnic: Picnic) {
        self.picnic = picnic
        coordinate = picnic.coordinate
        title = picnic.name
        super.init()
    }
}

class CustomAnnotationView: MKAnnotationView {
    
    var imageView: UIImageView!
   
    func configure(annotation: PicnicAnnotation) {
        frame.size = CGSize(width: annotationSize, height: annotationSize)
        imageView = UIImageView(frame: frame)
        canShowCallout = true
        isEnabled = true
        Managers.shared.databaseManager.image(forPicnic: annotation.picnic) { image in
            self.imageView.image = image
        }
        layer.cornerRadius = annotationSize / 7.0
        layer.borderWidth = annotationSize / 35.0
        layer.borderColor = UIColor.white.cgColor
        backgroundColor = .clear
        imageView.layer.cornerRadius = annotationSize / 7.0
        imageView.clipsToBounds = true
        addSubview(imageView)
        

        let button = UIButton(type: .infoLight)
        button.tintColor = .olive
        rightCalloutAccessoryView = button
    }
}
