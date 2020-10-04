//
//  NewLocationController.swift
//  Picnic
//
//  Created by Kyle Burns on 5/27/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

// this is bad
fileprivate let imageSize: CGSize = CGSize(width: 102, height: 102)
fileprivate let kTextBoxCornerRadius: CGFloat = 5.0

protocol NewLocationControllerDelegate: AnyObject {
    func requestAnnotation() -> MKPointAnnotation?
}

class NewLocationController: UIViewController {
    
    var map: MKMapView!
    var name: PaddedTextField!
//    var userDescription: PaddedTextView!
    var userDescription: PaddedTextField!
    var category: PaddedTextField!
    var images = [UIImage]()
    var addImages: UIButton!
    var interactiveRating: Rating!
    var selectedImages: MultipleSelectionIcon!
    var navigationBar: NavigationBar!
    var scrollView: UIScrollView!
    var annotation: MKPointAnnotation!
    var shortPresentationController: ShortPresentationController!
    var requiredFieldModal: RequiredFieldModal!
    
    weak var delegate: NewLocationControllerDelegate?
    
    private let modalOffsetY: CGFloat = 500

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    
        annotation = delegate?.requestAnnotation()
        configure()
        
        requiredFieldModal = RequiredFieldModal()
        requiredFieldModal.modalOffsetY = modalOffsetY
        requiredFieldModal.delegate = self
        requiredFieldModal.transitioningDelegate = self
        requiredFieldModal.modalPresentationStyle = .custom
        navigationController?.present(requiredFieldModal, animated: true)
    }
    
// MARK: Configure
    func configure() {
        view.backgroundColor = .white
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToEndEditing))
        view.addGestureRecognizer(tapGestureRecognizer)
        
// MARK: ScrollView
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        
// MARK: Map
        map = MKMapView()
        map.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        map.setRegion(region, animated: false)
        map.mapType = .hybrid
        map.isUserInteractionEnabled = false
        view.addSubview(map)
        
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
        userDescription.contentMode = .top
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
        interactiveRating = Rating(starSize: 30)
        interactiveRating.delegate = self
        interactiveRating.mode = .interactable
        view.addSubview(interactiveRating)
        
// MARK: Selected Images
        
        selectedImages = MultipleSelectionIcon(image: images.first)
        selectedImages.layer.setShadow(radius: 5, color: .darkGray , opacity: 0.6, offset: CGSize(width: 0, height: 5))
        selectedImages.layer.cornerRadius = 5
        view.addSubview(selectedImages)
        
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        navigationBar = NavigationBar(frame: kNavigationBarFrame)
        navigationBar.backgroundColor = .white
        navigationBar.leftBarButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        navigationBar.setLeftButtonPadding(amount: 10)
        navigationBar.rightBarButton.setTitle("Share", for: .normal)
        navigationBar.rightBarButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        navigationBar.setRightButtonPadding(amount: 10)
        view.addSubview(navigationBar)
        
// MARK: Constraints
        NSLayoutConstraint.activate([
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
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
    }
    
// MARK: Obj-C functions
    
    @objc func share(_ sender: UIButton) {
        guard let name = name.text,
        let userDescription = userDescription.text,
        name == "",
        userDescription == ""
        else { return }

        let idList = self.images.map {_ in UUID().uuidString }
        
        annotation.coordinate.getPlacemark { placemark in
            
            let state = placemark.administrativeArea
            let city = placemark.locality

// MARK: didVisit shouldn't be true by default
            let locationData = LocationData(latitude: self.annotation.coordinate.latitude, longitude: self.annotation.coordinate.longitude, city: city, state: state, park: nil)
            let newPicnic = Picnic(uid: UUID().uuidString, name: name, userDescription: userDescription, tags: [], imageNames: idList, rating: self.interactiveRating.rating, didVisit: true, locationData: locationData)

            // add to collection view datasource
            locations.append(newPicnic)

            // store picnic data
            Shared.shared.databaseManager.store(picnic: newPicnic, images: self.images) {
                self.navigationController?.popToRootViewController(animated: true)
            }
            Shared.shared.userManager.ratePost(picnic: newPicnic)
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
extension NewLocationController: UITextFieldDelegate {
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

extension NewLocationController: UITextViewDelegate {
    
}

extension NewLocationController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        shortPresentationController = ShortPresentationController(offsetY: modalOffsetY, presentedViewController: presented, presenting: presenting)
        return shortPresentationController
    }
}

extension NewLocationController: RequiredFieldModalDelegate {
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

extension NewLocationController: RatingDelegate {
    func updateRating(value: Float) {
        interactiveRating.setRating(value: value)
    }
}
