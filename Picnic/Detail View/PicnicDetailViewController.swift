//
//  PicnicDetailViewController.swift
//  Picnic
//
//  Created by Kyle Burns on 7/18/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

class PicnicDetailViewController: UIViewController {
    
    var map: MKMapView!
    var picnic: Picnic!
    var scrollView: UIScrollView!
    var preview: UIImageView!
    var rating: Rating!
    
    init(picnic: Picnic) {
        self.picnic = picnic
        super.init(nibName: nil, bundle: nil)
        title = picnic.name
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        preview = UIImageView()
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.contentMode = .scaleAspectFill
        preview.clipsToBounds = true
        Shared.shared.databaseManager.image(forPicnic: picnic) { image, error in
            if let error = error {
                self.preview.image = UIImage(named: "loading.jpg")
                print(error.localizedDescription)
                return
            } else {
                self.preview.image = image
            }
        }
        view.addSubview(preview)
        
        scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: picnic.location, span: span)
        map.setRegion(region, animated: false)
        map.mapType = .hybrid
        let loc = MKPointAnnotation()
        loc.coordinate = picnic.location
        map.addAnnotation(loc)
        
        map.layer.cornerRadius = 5
        map.layer.prepareSublayersForShadow()
        map.layer.setShadow(radius: 5, color: UIColor.darkGray.cgColor, opacity: 0.6, offset: CGSize(width: 0, height: 5))
        view.addSubview(map)
    
        NSLayoutConstraint.activate([
            preview.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            preview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            preview.widthAnchor.constraint(equalTo: view.widthAnchor),
            preview.heightAnchor.constraint(equalToConstant: 300),
            
            map.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 10),
            map.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            map.widthAnchor.constraint(equalToConstant: 350),
            map.heightAnchor.constraint(equalToConstant: 200),
            
            scrollView.topAnchor.constraint(equalTo: map.bottomAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}

extension MKMapViewDelegate {
    
}
