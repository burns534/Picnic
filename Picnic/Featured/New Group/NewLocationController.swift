//
//  NewLocationController.swift
//  Picnic
//
//  Created by Kyle Burns on 5/27/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

let tags = ["river", "park", "trail", "playground", "shaded"]

// this is bad
fileprivate let imageSize: CGSize = CGSize(width: 102, height: 102)

class NewLocationController: UIViewController, UIGestureRecognizerDelegate {
    
    var map: MapIcon!
    var name: UITextField!
    var userDescription: UITextField!
    var category: UITextField!
    var images = [UIImage]()
    var addImages: UIButton!
    var interactiveRating: Rating!
    var collectionView: UICollectionView!
    var region: MKCoordinateRegion!
    
    let frame = CGRect(x: 0, y: 0, width: 300, height: 50)
    var coordinate: CLLocationCoordinate2D!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Picnic"
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        
        configure()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem?.tintColor = .toggle
    }
    
// MARK: Configure
    
    func configure() {
        
// MARK: Map
        map = MapIcon()
        map.configure()
        let mapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTap))
        map.translatesAutoresizingMaskIntoConstraints = false
        map.addGestureRecognizer(mapGestureRecognizer)
        view.addSubview(map)
// MARK: Name
        name = UITextField(frame: .zero)
        name.translatesAutoresizingMaskIntoConstraints = false
        name.placeholder = "name"
        name.delegate = self
        view.addSubview(name)
// MARK: User Description
        userDescription = UITextField(frame: .zero)
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        userDescription.placeholder = "Enter a description"
        userDescription.delegate = self
        view.addSubview(userDescription)
// MARK: Category
        category = UITextField(frame: .zero)
        category.translatesAutoresizingMaskIntoConstraints = false
        category.placeholder = "tag"    // will need rework for tagging system
        category.delegate = self
        view.addSubview(category)

// MARK: Add Photos Button
        addImages = UIButton(frame: .zero)
        addImages.translatesAutoresizingMaskIntoConstraints = false
        addImages.setTitle("Add Images", for: .normal)
        addImages.setTitleColor(.systemBlue, for: .normal)
        addImages.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        view.addSubview(addImages)
// MARK: Interactive Rating
        interactiveRating = Rating(frame: .zero, starSize: CGSize(width: 30, height: 30), spacing: 1, rating: 0)
        interactiveRating.translatesAutoresizingMaskIntoConstraints = false
        interactiveRating.isUserInteractionEnabled = true
        view.addSubview(interactiveRating)
        
// MARK: Selected Images
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.register(NewLocationCollectionViewCell.self, forCellWithReuseIdentifier: "pickerCell")
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
// MARK: Constraints
        NSLayoutConstraint.activate([
            map.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            map.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            map.widthAnchor.constraint(equalToConstant: 200),
            map.heightAnchor.constraint(equalToConstant: 200),
            
            name.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            name.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            name.rightAnchor.constraint(lessThanOrEqualTo: map.leftAnchor),
            
            userDescription.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 5),
            userDescription.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            userDescription.rightAnchor.constraint(lessThanOrEqualTo: map.leftAnchor),
            
            category.topAnchor.constraint(equalTo: userDescription.bottomAnchor, constant: 5),
            category.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            category.rightAnchor.constraint(lessThanOrEqualTo: map.leftAnchor),

            addImages.topAnchor.constraint(equalTo: category.bottomAnchor, constant: 5),
            addImages.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            addImages.rightAnchor.constraint(lessThanOrEqualTo: map.leftAnchor),
            
            interactiveRating.topAnchor.constraint(equalTo: addImages.bottomAnchor, constant: 5),
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
        guard let loc = coordinate else { return }
        
// MARK: provide feedback
        guard let safelyUnwrappedName = name.text else {
            print("Error: name field cannot be empty")
            return
        }

        let idList = self.images.map { _ in UUID().uuidString }
        // MARK: - FIX!!!!!!! state: "fixMe"
        
        coordinate.getPlacemark { placemark in
            
            let state = placemark.administrativeArea ?? ""

            let newPicnic: Picnic = Picnic(name: safelyUnwrappedName, userDescription: self.userDescription.text ?? "", category: self.category.text ?? "", state: state, coordinates: loc, isFeatured: false, isLiked: false, isFavorite: false, park: "none", imageNames: idList, rating: Float(self.interactiveRating.rating))

            // add to collection view datasource
            locations.append(newPicnic)

            // store picnic data
            dbManager.store(picnic: newPicnic, images: self.images) {
                self.navigationController?.popViewController(animated: true)
            }
        }
         
     }
     
     @objc func mapTap(_ gesture: UITapGestureRecognizer) {
        region = map.mapView.region
        print(region.center.latitude)
        navigationController?.pushViewController(LocationSelector(sender: self), animated: true)
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
