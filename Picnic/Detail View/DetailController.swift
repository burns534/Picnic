//
//  PicnicDetailViewController.swift
//  Picnic
//
//  Created by Kyle Burns on 7/18/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

fileprivate let kPreviewHeight: CGFloat = 300
let kNavigationBarFrame: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)

class DetailController: UIViewController {
    
    var map: MKMapView!
    var picnic: Picnic = Picnic()
    var scrollView: UIScrollView!
    var preview: UIImageView!
    var rating: Rating!
    var nameLabel: UILabel!
    var aboutLabel: UILabel!
    var overview: UITextView!
    var tapToRateLabel: UILabel!
    var tapToRate: Rating!
    var liked: HeartButton!
    var navigationBar: NavigationBar!

// MARK: What is this ????
    override var preferredStatusBarStyle: UIStatusBarStyle { style }

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
// MARK: Probably change this
        guard let picnicLocation = picnic.locationData?.location else { return }
        
        map = MKMapView()
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: picnicLocation, span: span)
        map.setRegion(region, animated: false)
        map.mapType = .hybrid
        let loc = MKPointAnnotation()
        loc.coordinate = picnicLocation
        loc.title = picnic.name
        map.addAnnotation(loc)
        map.layer.cornerRadius = 5
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.showsUserLocation = false
        map.layer.prepareSublayersForShadow()
        map.layer.setShadow(radius: 5, color: .darkGray, opacity: 0.6, offset: CGSize(width: 0, height: 5))
        scrollView.addSubview(map)
        
        rating = Rating()
        rating.configure(picnic: picnic)
        rating.mode = .displayWithCount
        scrollView.addSubview(rating)
        
        liked = HeartButton(pointSize: 40)
        liked.setLiked(isLiked: Shared.shared.userManager.isSaved(picnic: picnic))
        scrollView.addSubview(liked)
        
        nameLabel = UILabel()
        nameLabel.minimumScaleFactor = 0.8
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.text = picnic.name
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 40)
        view.addSubview(nameLabel)
        
        tapToRate = Rating(starSize: 50)
        tapToRate.delegate = self
        tapToRate.mode = .interactable
        tapToRate.style = .grayFill
        tapToRate.configure(picnic: picnic)
        scrollView.addSubview(tapToRate)
        
        tapToRateLabel = UILabel()
        tapToRateLabel.text = "Tap to rate"
        scrollView.addSubview(tapToRateLabel)
        
        aboutLabel = UILabel()
        aboutLabel.text = "About"
        aboutLabel.font = UIFont.systemFont(ofSize: 35, weight: .heavy)
        view.addSubview(aboutLabel)
        
        overview = UITextView()
//        overview.layer.cornerRadius = 5
        overview.isEditable = false
        overview.text = picnic.userDescription
        overview.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        scrollView.addSubview(overview)
        
        view.subviews.forEach {$0.translatesAutoresizingMaskIntoConstraints = false}
        scrollView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        navigationBar = NavigationBar(frame: kNavigationBarFrame.offsetBy(dx: 0, dy: 44))
        navigationBar.backgroundColor = .clear
        navigationBar.setContentColor(.white)
        navigationBar.leftBarButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        navigationBar.setLeftButtonPadding(amount: 10)
        view.addSubview(navigationBar)
    
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            preview.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            preview.topAnchor.constraint(equalTo: view.topAnchor),
            preview.widthAnchor.constraint(equalTo: view.widthAnchor),
            preview.heightAnchor.constraint(equalToConstant: kPreviewHeight),
            
            aboutLabel.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 10),
            aboutLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            aboutLabel.heightAnchor.constraint(equalToConstant: 40),
            aboutLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
            
            overview.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 10),
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
            liked.topAnchor.constraint(equalTo: preview.topAnchor, constant: 10),
            
            nameLabel.leadingAnchor.constraint(equalTo: preview.leadingAnchor, constant: 10),
            nameLabel.bottomAnchor.constraint(equalTo: preview.bottomAnchor, constant: -10),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: liked.leadingAnchor, constant: -5),
            nameLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 40),
            
            rating.leadingAnchor.constraint(equalTo: preview.leadingAnchor, constant: 10),
            rating.widthAnchor.constraint(equalToConstant: rating.width),
            rating.heightAnchor.constraint(equalToConstant: rating.starSize),
            rating.bottomAnchor.constraint(equalTo: nameLabel.topAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        style = .lightContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func configure(picnic: Picnic) { self.picnic = picnic }
    
    
    @objc func mapTap(_ sender: UITapGestureRecognizer) {
        // push to fullscreen map view
    }
    
    @objc func backButtonTap(_ sender: UIButton) {
// MARK: What??
//        presentingCell.like.update()
        navigationController?.popViewController(animated: true)
    }
    
}

extension MKMapViewDelegate {
    
}

extension DetailController: RatingDelegate {
// MARK: There will be an issue with a user trying to change their rating on a post, but that's probably okay for now
    func updateRating(value: Float) {
        rating.setRating(value: value)
        Shared.shared.userManager.rateRequest(picnic: picnic) {
            Shared.shared.databaseManager.updateRating(picnic: self.picnic, rating: value, increment: true)
        }
    }
}
