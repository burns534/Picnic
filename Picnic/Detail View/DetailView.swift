//
//  DetailView.swift
//  Picnic
//
//  Created by Kyle Burns on 10/17/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

let kPreviewHeightMultiplier: CGFloat = 0.3
/**
 meters (Double)
 */
fileprivate let mapPrecision: CLLocationDistance = 5_000

class DetailView: UIView {
    let mapView = MKMapView()
    let reviews = Reviews(frame: .zero)
    let liked = HeartButton(pointSize: 40)
    let overview = UITextView()
    let preview = UIImageView()
    let name = UILabel()
    let rating = Rating(frame: .zero)
    let tagView = TagView()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
// TODO: Add refresh controller to scrollview (also must refresh reviews)
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bounces = false

        preview.isUserInteractionEnabled = true
        preview.contentMode = .scaleAspectFill
        preview.clipsToBounds = true
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * kPreviewHeightMultiplier)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textColor = .white
        name.font = UIFont.systemFont(ofSize: 35)
        
        liked.translatesAutoresizingMaskIntoConstraints = false
        rating.mode = .displayWithCount
        rating.style = .wireframe
        
        let overviewLabel = UILabel()
        overviewLabel.text = "Overview"
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        
        overview.translatesAutoresizingMaskIntoConstraints = false
        overview.isEditable = false
        overview.isScrollEnabled = false
        overview.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        overview.textContainerInset = .zero
        overview.textContainer.lineFragmentPadding = 0
        overview.layer.cornerRadius = 5
        overview.clipsToBounds = true
        
        tagView.mode = .display
        tagView.translatesAutoresizingMaskIntoConstraints = false

        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.showsUserLocation = false
        mapView.layer.cornerRadius = 8
        mapView.clipsToBounds = true
        
        reviews.translatesAutoresizingMaskIntoConstraints = false
        
        preview.addSubview(rating)
        preview.addSubview(liked)
        preview.addSubview(name)
        addSubview(scrollView)
        scrollView.addSubview(preview)
        scrollView.addSubview(overviewLabel)
        scrollView.addSubview(overview)
        scrollView.addSubview(tagView)
        scrollView.addSubview(mapView)
        scrollView.addSubview(reviews)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo:topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo:leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo:trailingAnchor),
   
            liked.trailingAnchor.constraint(equalTo: preview.trailingAnchor, constant: -20),
            liked.bottomAnchor.constraint(equalTo: preview.bottomAnchor, constant: -10),
            
            name.leadingAnchor.constraint(equalTo: preview.leadingAnchor, constant: 10),
            name.bottomAnchor.constraint(equalTo: preview.bottomAnchor, constant: -5),
            name.trailingAnchor.constraint(lessThanOrEqualTo: liked.leadingAnchor, constant: -5),
            name.heightAnchor.constraint(equalToConstant: 30),
            
            rating.leadingAnchor.constraint(equalTo: preview.leadingAnchor, constant: 10),
            rating.widthAnchor.constraint(equalTo: preview.widthAnchor, multiplier: 0.35),
            rating.bottomAnchor.constraint(equalTo: name.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preview.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            preview.heightAnchor.constraint(equalTo: heightAnchor, multiplier: kPreviewHeightMultiplier),
            preview.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            preview.topAnchor.constraint(equalTo: scrollView.topAnchor),
            
            overviewLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            overviewLabel.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 10),
            
            overview.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            overview.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor),
            overview.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
            
            tagView.topAnchor.constraint(equalTo: overview.bottomAnchor, constant: 10),
            tagView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            tagView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
            
            mapView.topAnchor.constraint(equalTo: tagView.bottomAnchor, constant: 10),
            mapView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            mapView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
            mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 0.6),
            
            reviews.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            reviews.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 10),
            reviews.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
            reviews.heightAnchor.constraint(equalTo: reviews.widthAnchor, multiplier: 1.2),
            reviews.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            reviews.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -20)
        ])
    }
    
    func configure(picnic: Picnic, image: UIImage?) {
        if let image = image {
            preview.image = image
        } else {
            PicnicManager.default.image(forPicnic: picnic) { [self] image in
                preview.image = image
                preview.setGradient(colors: [
                    .clear,
                    UIColor.black.withAlphaComponent(0.3)
                ])
            }
        }
        tagView.tags = picnic.tags?.tags ?? []
        if tagView.tags.count == 0 {
            
        }
        name.text = picnic.name
        rating.rating = picnic.rating
        let region = MKCoordinateRegion(center: picnic.coordinates.location, latitudinalMeters: mapPrecision, longitudinalMeters: mapPrecision)
        mapView.setRegion(region, animated: false)
        let loc = MKPointAnnotation()
        loc.coordinate = picnic.coordinate
        loc.title = picnic.name
        mapView.addAnnotation(loc)
        overview.text = picnic.userDescription
    }
}
