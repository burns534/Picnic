//
//  NewLocationController.swift
//  Picnic
//
//  Created by Kyle Burns on 5/27/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

let tags = ["river", "park", "trail", "playground", "shaded"]

// will deal with this later
var startCoordinate = CLLocationCoordinate2D(latitude: 35.095136, longitude: -92.453771)

class NewLocationController: UIViewController, UIGestureRecognizerDelegate {
    
    var name: UITextField!
    var userDescription: UITextField!
    var category: UITextField!
    var state: UITextField!
    var image: UIImage!
    var addImage: UIButton!
    var interactiveRating: Rating
    
    var map: MapIcon!
    
    private var locatedUser: Bool = false
    
    let frame = CGRect(x: 0, y: 0, width: 300, height: 50)
    var coordinates: CLLocationCoordinate2D!
    
    let locationManager = CLLocationManager()
    
    init(rating: Rating) {
        self.interactiveRating = rating
        super.init(nibName: nil, bundle: nil)
        title = "Create Picnic"
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // have to get access to user location. This is ridiculous
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        
        configureMap()
        configureStackView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        
    }
    
    @objc func save(_ sender: UIBarButtonItem) {
        guard let _ = self.coordinates else { return }
        // need to provide user with feedback here
        guard let safelyUnwrappedName = name.text else {
            print("Error: name field cannot be empty")
            return
        }
        guard let safelyUnwrappedImage = self.image else {
            print("Error: found nil for image \(safelyUnwrappedName)")
            return
        }
        let newPicnic: Picnic = Picnic(name: safelyUnwrappedName, userDescription: userDescription.text ?? "", category: category.text ?? "", state: state.text ?? "", coordinates: .init(latitude: coordinates.latitude, longitude: coordinates.longitude), isFeatured: false, isLiked: false, isFavorite: false, park: "none", imageName: safelyUnwrappedName, rating: Float(interactiveRating.rating))
        print("appending new picnic named \(newPicnic.name)")
        locations.append(newPicnic)
        
        if let featured = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? Featured {
                dbManager.storeImage(for: safelyUnwrappedName, image: safelyUnwrappedImage) {
                   // reloads collectionview data
                    print("storeImage completion")
                    dbManager.storePicnic(picnic: newPicnic) { picnic, ref in
                        print("storePicnic completion")
                        featured.refresh(picnic: picnic, dbRef: ref)
                    }
                    self.navigationController?.popViewController(animated: true)
                }
        }
    }
    
    @objc func presentMap() {
        present(MapView(sender: self), animated: true)
    }
    
    @objc func handleMapGesture(_ gesture: UITapGestureRecognizer) {
        present(MapView(sender: self), animated: true)
    }
    
    @objc func presentImagePicker(_ sender: UIButton) {
        navigationController?.pushViewController(AddImage(sender: self), animated: true)
    }
    
// MARK -- Map
    
    func configureMap() {
        map = MapIcon(frame: .init(x: 0, y: 0, width: 200, height: 200))
        map.translatesAutoresizingMaskIntoConstraints = false
        map.configureMap(startCoordinate: (locationManager.location?.coordinate) ?? startCoordinate)

        let mapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleMapGesture))
        map.mapView.addGestureRecognizer(mapGestureRecognizer)
        view.addSubview(map)
        
        NSLayoutConstraint.activate([
        map.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        map.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        map.widthAnchor.constraint(equalToConstant: 200),
        map.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
// MARK -- Text Fields
    func configureStackView() {
        name = UITextField(frame: .zero)
        name.translatesAutoresizingMaskIntoConstraints = false
        name.placeholder = "name"
        name.delegate = self
        view.addSubview(name)
        
        userDescription = UITextField(frame: .zero)
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        userDescription.placeholder = "Enter a description"
        userDescription.delegate = self
        view.addSubview(userDescription)

        category = UITextField(frame: .zero)
        category.translatesAutoresizingMaskIntoConstraints = false
        category.placeholder = "tag"    // will need rework for tagging system
        category.delegate = self
        view.addSubview(category)
        
        state = UITextField(frame: .zero)
        state.translatesAutoresizingMaskIntoConstraints = false
        state.placeholder = "state"
        state.delegate = self
        view.addSubview(state)
        
        addImage = UIButton(frame: .zero)
        addImage.translatesAutoresizingMaskIntoConstraints = false
        addImage.setTitle("Add Images", for: .normal)
        addImage.setTitleColor(.systemBlue, for: .normal)
        addImage.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        view.addSubview(addImage)
        
        interactiveRating.translatesAutoresizingMaskIntoConstraints = false
        interactiveRating.isUserInteractionEnabled = true
        view.addSubview(interactiveRating)
        
        NSLayoutConstraint.activate([
            name.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            name.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            name.rightAnchor.constraint(lessThanOrEqualTo: map.leftAnchor),
            
            userDescription.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 5),
            userDescription.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            userDescription.rightAnchor.constraint(lessThanOrEqualTo: map.leftAnchor),
            
            category.topAnchor.constraint(equalTo: userDescription.bottomAnchor, constant: 5),
            category.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            category.rightAnchor.constraint(lessThanOrEqualTo: map.leftAnchor),
            
            state.topAnchor.constraint(equalTo: category.bottomAnchor, constant: 5),
            state.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            state.rightAnchor.constraint(lessThanOrEqualTo: map.leftAnchor),
            
            addImage.topAnchor.constraint(equalTo: state.bottomAnchor, constant: 5),
            addImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            addImage.rightAnchor.constraint(lessThanOrEqualTo: map.leftAnchor),
            
            interactiveRating.topAnchor.constraint(equalTo: addImage.bottomAnchor, constant: 100),
            interactiveRating.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
//            interactiveRating.rightAnchor.constraint(lessThanOrEqualTo: map.leftAnchor),
            interactiveRating.widthAnchor.constraint(equalToConstant: interactiveRating.width),
            interactiveRating.heightAnchor.constraint(equalToConstant: interactiveRating.starSize.height)
        ])
    }
}

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
            state.becomeFirstResponder()
            return true
        default:
            return true
        }
    }
}

extension NewLocationController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//
    }
}
