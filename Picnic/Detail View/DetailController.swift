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
fileprivate let visitButtonSize: CGSize = CGSize(width: 150, height: 80)

class DetailController: UIViewController {
    
    var picnic: Picnic!
    let navigationBar = NavigationBar()
    let preview = UIImageView()
    let rating = Rating()
    let map = MKMapView()
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let nameLabel = UILabel()
    let overviewLabel = UITextView()
    let overview = UITextView()
    let visitedLabel = UILabel()
    let wouldVisitLabel = UILabel()
    var wouldVisitButton: VisitButton!
    var visitedButton: VisitButton!
    var liked: HeartButton!
    

// MARK: What is this ????
    override var preferredStatusBarStyle: UIStatusBarStyle { style }

    var style: UIStatusBarStyle = .default

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = false
        scrollView.bounces = true
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        scrollView.addSubview(stackView)
        
        navigationBar.defaultConfiguration(left: true)
        navigationBar.backgroundColor = .clear
        navigationBar.leftBarButton?.tintColor = .white
        navigationBar.leftBarButton?.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 40),
        ])
        
// MARK: Section One
        preview.contentMode = .scaleAspectFill
        preview.clipsToBounds = true
        preview.setGradient(colors: [.clear, UIColor.black.withAlphaComponent(0.4)])
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.setGradient(colors: [.clear, UIColor.black.withAlphaComponent(0.4)])
        Shared.shared.picnicManager.image(forPicnic: picnic) { image in
            self.preview.image = image
        }
        
        rating.configure(picnic: picnic)
        rating.translatesAutoresizingMaskIntoConstraints = false
        rating.mode = .displayWithCount
        
        liked = HeartButton(pointSize: 40)
        liked.translatesAutoresizingMaskIntoConstraints = false
        liked.addTarget(self, action: #selector(likePress), for: .touchUpInside)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.text = picnic.name
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 40)
        
        preview.addSubview(rating)
        preview.addSubview(liked)
        preview.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            liked.trailingAnchor.constraint(equalTo: preview.trailingAnchor, constant: -20),
            liked.bottomAnchor.constraint(equalTo: preview.bottomAnchor, constant: -10),
            
            nameLabel.leadingAnchor.constraint(equalTo: preview.leadingAnchor, constant: 10),
            nameLabel.bottomAnchor.constraint(equalTo: preview.bottomAnchor, constant: -5),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: liked.leadingAnchor, constant: -5),
            nameLabel.heightAnchor.constraint(equalToConstant: 40),
            
            rating.leadingAnchor.constraint(equalTo: preview.leadingAnchor, constant: 10),
            rating.widthAnchor.constraint(equalToConstant: rating.width),
            rating.heightAnchor.constraint(equalToConstant: rating.starSize),
            rating.bottomAnchor.constraint(equalTo: nameLabel.topAnchor)
        ])
        
        stackView.addArrangedSubview(preview)

// MARK: Section Two
        visitedButton = VisitButton()
        visitedButton.translatesAutoresizingMaskIntoConstraints = false
        visitedButton.configure(text: "I've been")
        visitedButton.button.addTarget(self, action: #selector(didVisit), for: .touchUpInside)
        wouldVisitButton = VisitButton()
        wouldVisitButton.translatesAutoresizingMaskIntoConstraints = false
        wouldVisitButton.configure(text: "I'd go")
        wouldVisitButton.button.addTarget(self, action: #selector(wouldVisit), for: .touchUpInside)
        
        let visitedBarDivider = UIView()
        visitedBarDivider.backgroundColor = .black
        visitedBarDivider.translatesAutoresizingMaskIntoConstraints = false
        
        let visitedBar = UIStackView(arrangedSubviews: [visitedButton, visitedBarDivider, wouldVisitButton])
        visitedBar.axis = .horizontal
        visitedBar.alignment = .center
        visitedBar.translatesAutoresizingMaskIntoConstraints = false
        visitedBar.spacing = 0
        visitedBar.distribution = .equalCentering

        let overviewDivider = UIView()
        overviewDivider.translatesAutoresizingMaskIntoConstraints = false
        overviewDivider.backgroundColor = .lightGray
        
        overview.isEditable = false
        overview.insertText(picnic.userDescription)
        overview.isScrollEnabled = false
        overview.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        overview.textContainerInset = .zero
        overview.textContainer.lineFragmentPadding = .zero
        
        map.translatesAutoresizingMaskIntoConstraints = false
        map.setRegion(MKCoordinateRegion(center: picnic.coordinates.location, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)), animated: false)
        let loc = MKPointAnnotation()
        loc.coordinate = picnic.coordinates.location
        loc.title = picnic.name
        map.addAnnotation(loc)
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.showsUserLocation = false
// MARK: ??? no shadow visible
        map.layer.cornerRadius = 8
        map.layer.prepareSublayersForShadow()
        map.layer.setShadow(radius: 5, color: .darkGray, opacity: 0.6, offset: CGSize(width: 0, height: 5))
        
        NSLayoutConstraint.activate([
            preview.widthAnchor.constraint(equalTo: view.widthAnchor),
            preview.heightAnchor.constraint(equalToConstant: kPreviewHeight),
            
            visitedButton.widthAnchor.constraint(equalToConstant: 150),
            visitedButton.heightAnchor.constraint(equalToConstant: 80),
            
            wouldVisitButton.widthAnchor.constraint(equalToConstant: 150),
            wouldVisitButton.heightAnchor.constraint(equalToConstant: 80),
            
            visitedBarDivider.heightAnchor.constraint(equalToConstant: 40),
            visitedBarDivider.widthAnchor.constraint(equalToConstant: 1),
            
            visitedBar.widthAnchor.constraint(equalToConstant: 370),
            visitedBar.heightAnchor.constraint(equalToConstant: 80),
            
            overviewLabel.widthAnchor.constraint(equalToConstant: 370),
            overviewLabel.heightAnchor.constraint(equalToConstant: 30),
            overview.widthAnchor.constraint(equalToConstant: 370),
            overviewDivider.widthAnchor.constraint(equalToConstant: 370),
            overviewDivider.heightAnchor.constraint(equalToConstant: 1),
            
            map.widthAnchor.constraint(equalToConstant: 370),
            map.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        stackView.addArrangedSubview(visitedBar)
//        stackView.addArrangedSubview(overviewLabel)
        stackView.addArrangedSubview(overview)
        stackView.addArrangedSubview(overviewDivider)
//        stackView.addArrangedSubview(infoBar)
        stackView.addArrangedSubview(map)
        
        view.bringSubviewToFront(navigationBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        style = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.setNavigationBarHidden(true, animated: false)
        Shared.shared.userManager.addSaveListener(picnic: picnic, listener: liked)
        Shared.shared.picnicManager.addWouldVisitListener(picnic: picnic, listener: wouldVisitButton.label)
        Shared.shared.picnicManager.addVisitedListener(picnic: picnic, listener: visitedButton.label)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        Shared.shared.userManager.removeSaveListener(liked)
        Shared.shared.picnicManager.removeListeners([wouldVisitButton.label, visitedButton.label])
    }
    
    func configure(picnic: Picnic) { self.picnic = picnic }
    
    
    @objc func mapTap(_ sender: UITapGestureRecognizer) {
        // push to fullscreen map view
    }
    
    @objc func backButtonTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func likePress(_ sender: HeartButton) {
        if sender.isActive {
            Shared.shared.userManager.unsavePost(picnic: picnic)
        } else {
            Shared.shared.userManager.savePost(picnic: picnic)
        }
    }
    
    @objc func wouldVisit(_ sender: UIButton) {
        guard let sender = sender.superview as? VisitButton else { return }
        Shared.shared.picnicManager.updateWouldVisit(picnic: picnic, value: sender.toggle() ? 1 : -1)
    }
    
    @objc func didVisit(_ sender: VisitButton) {
        guard let sender = sender.superview as? VisitButton else { return }
        Shared.shared.picnicManager.updateVisited(picnic: picnic, value: sender.toggle() ? 1 : -1)
    }
}

extension DetailController: RatingDelegate {
// MARK: There will be an issue with a user trying to change their rating on a post, but that's probably okay for now
    func updateRating(value: Float) {
        Shared.shared.userManager.rateRequest(picnic: picnic) { allowable in
            if allowable {
                Shared.shared.picnicManager.updateRating(picnic: self.picnic, value: value)
                // update rating
            } else {
                // explain to user
            }
        }
    }
}

extension DetailController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        navigationBar.isHidden = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        navigationBar.isHidden = false
    }
}
