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

fileprivate let imageSize: CGSize = CGSize(width: 102, height: 102)

class NewLocationController: UIViewController, UIGestureRecognizerDelegate {
    
    var name: UITextField!
    var userDescription: UITextField!
    var category: UITextField!
    var state: UITextField!
    var images = [UIImage]()
    
    var addPhotos: UIButton!
    var interactiveRating: Rating
    
    var collectionView: UICollectionView!
    
    var map: MapIcon!
    
    
    private var locatedUser: Bool = false
    
    let frame = CGRect(x: 0, y: 0, width: 300, height: 50)
    var coordinates: CLLocationCoordinate2D!
    
    let locationManager = CLLocationManager()
// MARK: Initializers
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
    
// MARK: Map
    
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
    
// MARK: Configure
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
        
        addPhotos = UIButton(frame: .zero)
        addPhotos.translatesAutoresizingMaskIntoConstraints = false
        addPhotos.setTitle("Add Photos", for: .normal)
        addPhotos.setTitleColor(.systemBlue, for: .normal)
        addPhotos.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        view.addSubview(addPhotos)
        
        interactiveRating.translatesAutoresizingMaskIntoConstraints = false
        interactiveRating.isUserInteractionEnabled = true
        view.addSubview(interactiveRating)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.register(NewLocationCollectionViewCell.self, forCellWithReuseIdentifier: "pickerCell")
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
    // MARK: Constraints
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
            
            addPhotos.topAnchor.constraint(equalTo: state.bottomAnchor, constant: 5),
            addPhotos.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            addPhotos.rightAnchor.constraint(lessThanOrEqualTo: map.leftAnchor),
            
            interactiveRating.topAnchor.constraint(equalTo: addPhotos.bottomAnchor, constant: 5),
            interactiveRating.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            interactiveRating.rightAnchor.constraint(lessThanOrEqualTo: map.leftAnchor),
            interactiveRating.widthAnchor.constraint(equalToConstant: interactiveRating.width),
            interactiveRating.heightAnchor.constraint(equalToConstant: interactiveRating.starSize.height),
            
            collectionView.topAnchor.constraint(equalTo: map.bottomAnchor, constant: 20),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: 405),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: Obj-C functions
    @objc func save(_ sender: UIBarButtonItem) {
         guard let _ = self.coordinates else { return }
         // need to provide user with feedback here
         guard let safelyUnwrappedName = name.text else {
             print("Error: name field cannot be empty")
             return
         }
         
         let idList = self.images.map { image in
             return UUID().uuidString
         }
         let newPicnic: Picnic = Picnic(name: safelyUnwrappedName, userDescription: userDescription.text ?? "", category: category.text ?? "", state: state.text ?? "", coordinates: .init(latitude: coordinates.latitude, longitude: coordinates.longitude), isFeatured: false, isLiked: false, isFavorite: false, park: "none", imageNames: idList, rating: Float(interactiveRating.rating))
         
         // add to collection view datasource
         locations.append(newPicnic)
         
         // store picnic data
         dbManager.store(picnic: newPicnic, images: self.images) {
             print("successfully saved picnic with name \(newPicnic.name)")
             self.navigationController?.popViewController(animated: true)
         }
         
     }
     
     @objc func handleMapGesture(_ gesture: UITapGestureRecognizer) {
         navigationController?.pushViewController(MapView(sender: self), animated: true)
     }
     
     @objc func presentImagePicker(_ sender: UIButton) {
         let layout = CustomPickerFlowLayout(itemSize: imageSize, scrollDirection: .vertical, minimumLineSpacing: 1, sectionInset: .zero, minimumInteritemSpacing: 0)
         navigationController?.pushViewController(CustomImagePickerController(collectionViewLayout: layout, destination: self), animated: true)
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
            state.becomeFirstResponder()
            return true
        default:
            return true
        }
    }
}
//MARK: MKMapViewDelegate
extension NewLocationController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//
    }
}
// MARK: UICollectionViewDataSource
extension NewLocationController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pickerCell", for: indexPath) as? NewLocationCollectionViewCell else {
            fatalError("Could not dequeue/cast cell")
        }
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    
}
