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
    
    private enum AnnotationReuseID: String {
        case pin
    }
    
    var map: MKMapView!
    var selectedCoordinate: CLLocationCoordinate2D!
    var navigationBar: NavigationBar!
    var searchButton: UIButton!
    var warningBox: UILabel!
    var instructions: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func configure() {
        view.backgroundColor = .white
        
// MARK: Warning Box
        warningBox = UILabel()
        warningBox.text = "Please select a location first"
        warningBox.textAlignment = .center
        warningBox.backgroundColor = .white
        view.addSubview(warningBox)
        
// MARK: Map
        map = MKMapView(frame: .zero)
        guard let location = Shared.shared.locationManager.location else {
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
        
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
// MARK: Search Button
        searchButton = UIButton()
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .thin))?.withRenderingMode(.alwaysTemplate)
        searchButton.setImage(image, for: .normal)
        searchButton.tintColor = .olive
        searchButton.addTarget(self, action: #selector(searchButtonHandler), for: .touchUpInside)
        
// MARK: Navigation Bar
        navigationBar = NavigationBar(frame: kNavigationBarFrame)
        navigationBar.backgroundColor = .white
        navigationBar.leftBarButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        navigationBar.setLeftButtonPadding(amount: 10)
        
        navigationBar.rightBarButton.setTitle("next", for: .normal)
        navigationBar.rightBarButton.addTarget(self, action: #selector(nextButtonHandler), for: .touchUpInside)
        navigationBar.rightBarButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .light)
        navigationBar.rightBarButton.setTitleColor(.olive, for: .normal)
        navigationBar.setRightButtonPadding(amount: 10)
        
        navigationBar.setCenterView(view: searchButton)
        view.addSubview(navigationBar)

        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            map.widthAnchor.constraint(equalTo: view.widthAnchor),
            map.heightAnchor.constraint(equalTo: view.heightAnchor),
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            warningBox.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            warningBox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            warningBox.widthAnchor.constraint(equalTo: view.widthAnchor),
            warningBox.heightAnchor.constraint(equalToConstant: 60),
            
            instructions.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func searchButtonHandler(_ sender: UIButton) {
        // push search controller
    }
    
    @objc func nextButtonHandler() {
        guard let _ = selectedCoordinate else {
            view.bringSubviewToFront(warningBox)
            return
        }
        let next = NewLocationController()
        next.delegate = self
        navigationController?.pushViewController(next, animated: true)
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

extension LocationSelector: NewLocationControllerDelegate {
    func requestAnnotation() -> MKPointAnnotation? {
        guard let loc = selectedCoordinate else { return nil }
        let annotation = MKPointAnnotation()
        annotation.coordinate = loc
        return annotation
    }
}

extension LocationSelector: UINavigationControllerDelegate {
}
