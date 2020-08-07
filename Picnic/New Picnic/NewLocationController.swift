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
    var name: UITextField!
    var userDescription: UITextField!
    var category: UITextField!
    var images = [UIImage]()
    var addImages: UIButton!
    var tapToRateLabel: UILabel!
    var interactiveRating: Rating!
    var selectedImages: MultipleSelectionIcon!
    var navigationBar: NavigationBar!
    var scrollView: UIScrollView!
    var lineView: UIView!
    var annotation: MKPointAnnotation!
    var shortPresentationController: ShortPresentationController!
    
    weak var delegate: NewLocationControllerDelegate?
    
    private let modalOffsetY: CGFloat = 500

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    
        annotation = delegate?.requestAnnotation()
        configure()
// make this an instance variable
        let vc = RequiredFieldModal()
        vc.modalOffsetY = modalOffsetY
        vc.delegate = self
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        navigationController?.present(vc, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setToolbarHidden(false, animated: true)
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
        name = UITextField(frame: .zero)
        name.placeholder = "Enter name"
//        name.setPadding(.standard)
        name.backgroundColor = .darkWhite
        name.layer.cornerRadius = kTextBoxCornerRadius
        name.delegate = self
        view.addSubview(name)
        
// MARK: User Description
        userDescription = UITextField(frame: .zero)
        userDescription.placeholder = "Enter a brief description"
        userDescription.contentVerticalAlignment = .top
//        userDescription.setPadding(.standard)
        userDescription.delegate = self
        userDescription.backgroundColor = .darkWhite
        userDescription.layer.cornerRadius = kTextBoxCornerRadius
        view.addSubview(userDescription)
        
// MARK: Category
        category = UITextField(frame: .zero)
        category.placeholder = "tag"
//        category.setPadding(.standard)
        category.backgroundColor = .darkWhite
        category.layer.cornerRadius = kTextBoxCornerRadius
        category.delegate = self
        view.addSubview(category)

// MARK: Add Photos Button
//        let cameraButtonConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .light)
//        let cameraIcon = UIImage(systemName: "camera.fill", withConfiguration: cameraButtonConfig)?.withTintColor(.gray, renderingMode: .alwaysOriginal)
//        addImages = UIButton()
//        addImages.setImage(cameraIcon, for: .normal)
//        addImages.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
//        view.addSubview(addImages)
//
// MARK: tapToRateLabel
        tapToRateLabel = UILabel()
        tapToRateLabel.text = "Tap to rate"
        tapToRateLabel.textColor = .gray
        view.addSubview(tapToRateLabel)
        
// MARK: Interactive Rating
        interactiveRating = Rating(starSize: CGSize(width: 30, height: 30))
        interactiveRating.isUserInteractionEnabled = true
        view.addSubview(interactiveRating)
        
// MARK: Selected Images
        
        selectedImages = MultipleSelectionIcon(image: images.first)
        selectedImages.layer.setShadow(radius: 5, color: .darkGray , opacity: 0.6, offset: CGSize(width: 0, height: 5))
        selectedImages.layer.cornerRadius = 5
        view.addSubview(selectedImages)
        
        navigationBar = NavigationBar()
        navigationBar.backgroundColor = .white
        let backConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .light)
        let back = UIImage(systemName: "chevron.left", withConfiguration: backConfig)?.withTintColor(.olive, renderingMode: .alwaysOriginal)
        navigationBar.setLeftBarButton(image: back, target: self, action: #selector(backButtonTap))
        navigationBar.setLeftButtonPadding(amount: 10)
        navigationBar.setRightBarButton(title: "share", target: self, action: #selector(share))
        navigationBar.rightBarButton?.setTitleColor(.olive, for: .normal)
        navigationBar.rightBarButton?.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .light)
        navigationBar.setRightButtonPadding(amount: 10)
        view.addSubview(navigationBar)
        // MARK: Line
        lineView = UIView()
        lineView.backgroundColor = .lightGray
        lineView.isHidden = true
        view.addSubview(lineView)
        
        view.subviews.forEach {$0.translatesAutoresizingMaskIntoConstraints = false}
        
// MARK: Constraints
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 40),
            
            lineView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            lineView.widthAnchor.constraint(equalTo: view.widthAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 2),
            lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
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
            
            tapToRateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            tapToRateLabel.topAnchor.constraint(equalTo: category.bottomAnchor, constant: 15),
            
            interactiveRating.topAnchor.constraint(equalTo: tapToRateLabel.bottomAnchor, constant: 5),
            interactiveRating.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            interactiveRating.widthAnchor.constraint(equalToConstant: interactiveRating.width),
            interactiveRating.heightAnchor.constraint(equalToConstant: interactiveRating.starSize.height),
            
            selectedImages.topAnchor.constraint(equalTo: interactiveRating.bottomAnchor, constant: 15),
            selectedImages.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            selectedImages.widthAnchor.constraint(equalToConstant: 100),
            selectedImages.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
// MARK: Obj-C functions
    
    @objc func share(_ sender: UIButton) {
        guard let name = name.text else { return }
        guard let description = userDescription.text else { return }
        if name == "" { return }
        if description == "" { return }

        let idList = self.images.map {_ in UUID().uuidString }
        
        annotation.coordinate.getPlacemark { placemark in
            
            let state = placemark.administrativeArea ?? ""

            let newPicnic: Picnic = Picnic(name: name, userDescription: description, category: self.category.text!, state: state, coordinates: self.annotation.coordinate, isFeatured: false, isLiked: false, isFavorite: false, park: "none", imageNames: idList, rating: Float(self.interactiveRating.rating), ratingCount: 1)

            // add to collection view datasource
            locations.append(newPicnic)

            // store picnic data
            Shared.shared.databaseManager.store(picnic: newPicnic, images: self.images) {
                self.navigationController?.popToRootViewController(animated: true)
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
extension NewLocationController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case name:
            resignFirstResponder()
            userDescription.becomeFirstResponder()
            return true
        case userDescription:
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
    
    func update(rating: CGFloat) {
        self.interactiveRating.update(rating: rating)
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

