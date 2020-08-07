//
//  PicnicDetailViewController.swift
//  Picnic
//
//  Created by Kyle Burns on 7/18/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

fileprivate let kPreviewHeight: CGFloat = 300

class PicnicDetailViewController: UIViewController {
    
    var map: MKMapView!
    var picnic: Picnic!
    var scrollView: UIScrollView!
    var preview: UIImageView!
    var rating: Rating!
    var name: UILabel!
    var overviewLabel: UILabel!
    var overview: UITextView!
    var tapToRateLabel: UILabel!
    var tapToRate: Rating!
    var liked: HeartButton!
    var navigationBar: NavigationBar!
    var presentingCell: FeaturedCell
    
    init(cell: FeaturedCell) {
        self.picnic = cell.picnic
        presentingCell = cell
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    
    var style: UIStatusBarStyle = .default

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        scrollView = UIScrollView(frame: view.frame)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = view.frame.size
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        preview = UIImageView()
        preview.contentMode = .scaleAspectFill
        preview.clipsToBounds = true
        Shared.shared.databaseManager.image(forPicnic: picnic) { image, error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                self.preview.image = image
            }
        }
        scrollView.addSubview(preview)
        
        map = MKMapView()
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: picnic.location, span: span)
        map.setRegion(region, animated: false)
        map.mapType = .hybrid
        let loc = MKPointAnnotation()
        loc.coordinate = picnic.location
        loc.title = picnic.name
        map.addAnnotation(loc)
        map.layer.cornerRadius = 5
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.showsUserLocation = false
        map.layer.prepareSublayersForShadow()
        map.layer.setShadow(radius: 5, color: .darkGray, opacity: 0.6, offset: CGSize(width: 0, height: 5))
        scrollView.addSubview(map)
        
        navigationBar = NavigationBar()
        navigationBar.backgroundColor = .clear
        let config = UIImage.SymbolConfiguration(pointSize: 35, weight: .light)
        let back = UIImage(systemName: "chevron.left", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        navigationBar.setLeftBarButton(image: back, target: self, action: #selector(backButtonTap))
        navigationBar.setLeftButtonPadding(amount: 10)
        view.addSubview(navigationBar)
        
        rating = Rating()
        rating.configure(picnic: picnic)
        rating.mode = .displayWithCount
        scrollView.addSubview(rating)
        
        liked = HeartButton()
        liked.configure(id: picnic.id)
        scrollView.addSubview(liked)
        
        name = UILabel()
        name.minimumScaleFactor = 0.8
        name.adjustsFontSizeToFitWidth = true
        name.text = picnic.name
        name.textColor = .white
        name.font = UIFont.systemFont(ofSize: 40)
        view.addSubview(name)
        
        tapToRate = Rating(starSize: 50)
        tapToRate.mode = .interactable
        tapToRate.style = .grayFill
        tapToRate.configure(picnic: picnic)
        scrollView.addSubview(tapToRate)
        
        tapToRateLabel = UILabel()
        tapToRateLabel.text = "Tap to rate"
        scrollView.addSubview(tapToRateLabel)
        
        overviewLabel = UILabel()
        overviewLabel.text = "About"
        overviewLabel.font = UIFont.systemFont(ofSize: 35, weight: .heavy)
        view.addSubview(overviewLabel)
        
        overview = UITextView()
//        overview.layer.cornerRadius = 5
        overview.isEditable = false
        overview.text = picnic.userDescription
        overview.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        scrollView.addSubview(overview)
        
        view.subviews.forEach {$0.translatesAutoresizingMaskIntoConstraints = false}
        scrollView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 40),
            
            preview.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            preview.topAnchor.constraint(equalTo: view.topAnchor),
            preview.widthAnchor.constraint(equalTo: view.widthAnchor),
            preview.heightAnchor.constraint(equalToConstant: kPreviewHeight),
            
            overviewLabel.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 10),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            overviewLabel.heightAnchor.constraint(equalToConstant: 40),
            overviewLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
            
            overview.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 10),
            overview.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15),
            overview.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30),
            overview.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            tapToRateLabel.topAnchor.constraint(equalTo: overview.bottomAnchor, constant: 10),
            tapToRateLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15),
            tapToRateLabel.widthAnchor.constraint(equalToConstant: 100),
            tapToRateLabel.heightAnchor.constraint(equalToConstant: 30),
            
            tapToRate.topAnchor.constraint(equalTo: tapToRateLabel.bottomAnchor),
            tapToRate.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15),
            tapToRate.widthAnchor.constraint(equalToConstant: tapToRate.width),
            tapToRate.heightAnchor.constraint(equalToConstant: tapToRate.starSize),
            
            map.topAnchor.constraint(equalTo: tapToRate.bottomAnchor, constant: 400),
            map.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15),
            map.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30),
            map.heightAnchor.constraint(equalToConstant: 220),
            
            liked.trailingAnchor.constraint(equalTo: preview.trailingAnchor, constant: -10),
            liked.bottomAnchor.constraint(equalTo: preview.bottomAnchor, constant: -10),
            liked.widthAnchor.constraint(equalToConstant: 50),
            liked.heightAnchor.constraint(equalToConstant: 45),
            
            name.leadingAnchor.constraint(equalTo: preview.leadingAnchor, constant: 10),
            name.bottomAnchor.constraint(equalTo: preview.bottomAnchor, constant: -10),
            name.trailingAnchor.constraint(lessThanOrEqualTo: liked.leadingAnchor, constant: -5),
            name.heightAnchor.constraint(lessThanOrEqualToConstant: 40),
            
            rating.leadingAnchor.constraint(equalTo: preview.leadingAnchor, constant: 10),
            rating.widthAnchor.constraint(equalToConstant: rating.width),
            rating.heightAnchor.constraint(equalToConstant: rating.starSize),
            rating.bottomAnchor.constraint(equalTo: name.topAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        style = .lightContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    @objc func mapTap(_ sender: UITapGestureRecognizer) {
        // push to fullscreen map view
    }
    
    @objc func backButtonTap(_ sender: UIButton) {
        presentingCell.like.update()
        navigationController?.popViewController(animated: true)
    }
    
}

extension MKMapViewDelegate {
    
}
