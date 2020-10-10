//
//  MapView.swift
//  Picnic
//
//  Created by Kyle Burns on 5/29/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
import MapKit

fileprivate let kLattitudeDelta = 0.2
fileprivate let kLongitudeDelta = 0.2

class LocationSelector: UIViewController {
    
    private enum AnnotationReuseID: String { case pin }
    
    var map: MKMapView!
    var selectedCoordinate: CLLocationCoordinate2D!
    var navigationBar: NavigationBar!
    var searchButton: UIButton!
    var warningBox: UILabel!
    var instructions: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
// MARK: Warning Box
        warningBox = UILabel()
        warningBox.text = "Please select a location first"
        warningBox.textAlignment = .center
        warningBox.backgroundColor = .white
        warningBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(warningBox)
        
// MARK: Map
        map = MKMapView(frame: view.frame)
// MARK: This is bad practice and needs to be fixed
        guard let location = Managers.shared.locationManager.location else {
            map.setRegion(MKCoordinateRegion(), animated: true)
            return
        }
        let span = MKCoordinateSpan(latitudeDelta: kLattitudeDelta, longitudeDelta: kLongitudeDelta)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        map.setRegion(region, animated: true)
        map.showsUserLocation = true
        map.mapType = .hybrid
        map.showsCompass = true
        map.showsScale = true
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(dropPin))
        map.addGestureRecognizer(tap)
        view.addSubview(map)
        
        instructions = UILabel()
        instructions.text = "Select a loction"
        instructions.textColor = .white
        instructions.textAlignment = .center
        instructions.backgroundColor = .clear
        view.addSubview(instructions)
        
// MARK: Navigation Bar
        navigationBar = NavigationBar()
        navigationBar.defaultConfiguration(left: true)
        navigationBar.backgroundColor = .clear
        navigationBar.leftBarButton?.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        navigationBar.leftBarButton?.tintColor = .white
        let rightButton = UIButton()
        rightButton.setTitle("Next", for: .normal)
        rightButton.addTarget(self, action: #selector(nextButtonHandler), for: .touchUpInside)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .thin)
        rightButton.setTitleColor(.white, for: .normal)
        navigationBar.setRightBarButton(button: rightButton)
        navigationBar.setRightButtonPadding(amount: 10)
        
        searchButton = UIButton()
        searchButton.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .thin))?.withRenderingMode(.alwaysTemplate), for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonHandler), for: .touchUpInside)
        searchButton.tintColor = .white
        navigationBar.setCenterView(view: searchButton)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 40),
            
            warningBox.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            warningBox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            warningBox.widthAnchor.constraint(equalTo: view.widthAnchor),
            warningBox.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    @objc func searchButtonHandler(_ sender: UIButton) {
        // push search controller
    }
    
    @objc func nextButtonHandler() {
        guard let _ = selectedCoordinate else {
            view.bringSubviewToFront(warningBox)
            return
        }
// MARK: This is bad
        if #available(iOS 14, *) {
            let next = NewPicnicController()
            next.configure(coordinate: selectedCoordinate)
            navigationController?.pushViewController(next, animated: true)
            if let featured = tabBarController?.viewControllers?.first as? Featured {
                next.delegate = featured
            }
        } else {
            fatalError()
        }
    }
    
    @objc func backButtonTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func dropPin(_ gesture: UITapGestureRecognizer) {
        view.sendSubviewToBack(warningBox)
        map.removeAnnotations(map.annotations.filter { $0 is MKPointAnnotation })
        let screenLocation = gesture.location(in: map)
        let mapCoordinate = map.convert(screenLocation, toCoordinateFrom: map)
        selectedCoordinate = mapCoordinate
        let pin = MKPointAnnotation()
        pin.coordinate = mapCoordinate
        map.addAnnotation(pin)
    }
}

extension LocationSelector: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
    }
}

extension LocationSelector: UINavigationControllerDelegate {
}
