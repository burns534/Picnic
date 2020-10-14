//
//  NewLocationController.swift
//  Picnic
//
//  Created by Kyle Burns on 5/27/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

// this is bad
fileprivate let imageSize: CGSize = CGSize(width: 102, height: 102)
fileprivate let kTextBoxCornerRadius: CGFloat = 5.0

fileprivate let modalOffset: CGFloat = 500

// TODO: Clean this up
class NewPicnicController: UIViewController {
    
    var map: MKMapView!
    var name: PaddedTextField!
    var userDescription: PaddedTextField!
    var category: PaddedTextField!
    var images = [UIImage]()
    var addImages: UIButton!
    let interactiveRating = Rating(starSize: 30)
    var selectedImages: MultipleSelectionIcon!
    var navigationBar: NavigationBar!
    var scrollView: UIScrollView!
    var coordinate: CLLocationCoordinate2D?
    var requiredFieldModal: RequiredFieldModal!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        view.backgroundColor = .white
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToEndEditing))
        view.addGestureRecognizer(tapGestureRecognizer)
        
// MARK: ScrollView
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        
// MARK: Name
        name = PaddedTextField()
        name.placeholder = "Enter name"
        name.backgroundColor = .darkWhite
        name.layer.cornerRadius = kTextBoxCornerRadius
        name.delegate = self
        view.addSubview(name)
        
// MARK: User Description
//        userDescription = PaddedTextView()
        userDescription = PaddedTextField()
        userDescription.contentVerticalAlignment = .top
        userDescription.delegate = self
        userDescription.backgroundColor = .darkWhite
        userDescription.layer.cornerRadius = kTextBoxCornerRadius
        view.addSubview(userDescription)
        
// MARK: Category
        category = PaddedTextField()
        category.placeholder = "tag"
        category.backgroundColor = .darkWhite
        category.layer.cornerRadius = kTextBoxCornerRadius
        category.delegate = self
        view.addSubview(category)
        
// MARK: Interactive Rating
        interactiveRating.mode = .interactable
        view.addSubview(interactiveRating)
        
// MARK: Selected Images
        
        selectedImages = MultipleSelectionIcon(image: images.first)
        selectedImages.layer.setShadow(radius: 5, color: .darkGray , opacity: 0.6, offset: CGSize(width: 0, height: 5))
        selectedImages.layer.cornerRadius = 5
        view.addSubview(selectedImages)
        
// MARK: Map
        map = MKMapView()
        map.mapType = .hybrid
        map.isUserInteractionEnabled = false
        view.addSubview(map)
        
        if let coordinate = coordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            map.addAnnotation(annotation)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            map.setRegion(region, animated: false)
        }
        
        navigationBar = NavigationBar()
        navigationBar.defaultConfiguration(left: true)
        navigationBar.backgroundColor = .clear
        navigationBar.leftBarButton?.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        navigationBar.leftBarButton?.tintColor = .white
        let rightButton = UIButton()
        rightButton.setTitle("Share", for: .normal)
        rightButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        rightButton.setTitleColor(.white, for: .normal)
        navigationBar.setRightBarButton(button: rightButton)
        navigationBar.setRightButtonPadding(amount: 10)
        view.addSubview(navigationBar)
        
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
// MARK: Constraints
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 40),
            
            map.topAnchor.constraint(equalTo: view.topAnchor),
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.widthAnchor.constraint(equalTo: view.widthAnchor),
            map.heightAnchor.constraint(equalToConstant: 300),
            
            name.topAnchor.constraint(equalTo: map.bottomAnchor, constant: 15),
            name.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            name.trailingAnchor.constraint(equalTo: view.centerXAnchor),
            name.heightAnchor.constraint(equalToConstant: 40),
            
            userDescription.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 15),
            userDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            userDescription.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30),
            userDescription.heightAnchor.constraint(equalToConstant: 100)
        ]);
        
        NSLayoutConstraint.activate([
            category.topAnchor.constraint(equalTo: userDescription.bottomAnchor, constant: 15),
            category.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            category.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            category.heightAnchor.constraint(equalToConstant: 40),
            
            interactiveRating.topAnchor.constraint(equalTo: category.bottomAnchor, constant: 5),
            interactiveRating.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            interactiveRating.widthAnchor.constraint(equalToConstant: interactiveRating.width),
            interactiveRating.heightAnchor.constraint(equalToConstant: interactiveRating.starSize),
            
            selectedImages.topAnchor.constraint(equalTo: interactiveRating.bottomAnchor, constant: 15),
            selectedImages.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            selectedImages.widthAnchor.constraint(equalToConstant: 100),
            selectedImages.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        requiredFieldModal = RequiredFieldModal()
        requiredFieldModal.offset = modalOffset
        requiredFieldModal.delegate = self
        requiredFieldModal.transitioningDelegate = self
        requiredFieldModal.modalPresentationStyle = .custom
        navigationController?.present(requiredFieldModal, animated: true)
    }
    
// MARK: Configure
    func configure(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
// MARK: Obj-C functions
    
    @objc func share(_ sender: UIButton) {
        guard let name = name.text,
        let userDescription = userDescription.text,
        let coordinate = coordinate,
        let uid = Managers.shared.auth.currentUser?.uid,
        name != "", userDescription != ""
        else { return }
        let imageNames = self.images.map {_ in UUID().uuidString }
        
        coordinate.getPlacemark { placemark in
            let picnic = Picnic(
                id: nil,
                uid: uid,
                name: name,
                userDescription: userDescription,
                tags: nil,
                imageNames: imageNames,
                totalRating: Double(self.interactiveRating.rating),
                ratingCount: 1,
                wouldVisit: 0,
                visitCount: 1,
                coordinates: GeoPoint(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                ),
                city: placemark.locality,
                state: placemark.administrativeArea,
                park: nil,
                geohash: Region(coordinate: coordinate).hash
            )

            // store picnic data
            Managers.shared.databaseManager.store(picnic: picnic, images: self.images) {
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.selectedIndex = 0
            }
        }
         
     }
    
    @objc func backButtonTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func tapToEndEditing(_ gesture: UITapGestureRecognizer) {
        let loc = gesture.location(in: view)
        if name.frame.contains(loc) { return }
        else if userDescription.frame.contains(loc) { return }
        else if category.frame.contains(loc) { return }
        view.endEditing(true)
    }
}
// MARK: UITextFieldDelegate
extension NewPicnicController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case name:
            resignFirstResponder()
            category.becomeFirstResponder()
            return true
        case category:
            resignFirstResponder()
            view.endEditing(true)
            return true
        default:
            return true
        }
    }
}

extension NewPicnicController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = ShortPresentationController(presentedViewController: presented, presenting: presenting)
        pc.offset = modalOffset
        return pc
    }
}


extension NewPicnicController: RequiredFieldModalDelegate {
    func update(name: String) {
        self.name.text = name
    }
    
    func update(rating: Float) {
        self.interactiveRating.setRating(value: rating)
    }
    
    func update(description: String) {
        self.userDescription.text = description
    }
    
    func update(images: [UIImage]) {
        self.images = images
        selectedImages.setImage(images.first, for: .normal)
        selectedImages.isMultipleSelection = images.count > 1 ? true : false
    }
}

