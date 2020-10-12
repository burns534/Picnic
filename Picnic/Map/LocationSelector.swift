//
//  MapView.swift
//  Picnic
//
//  Created by Kyle Burns on 5/29/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
import MapKit

let kDefaultLongitudinalMeters: CLLocationDistance = 12_000
private let reuseIdentifier = "cell"

class LocationSelector: UIViewController {
    
    private enum AnnotationReuseID: String { case pin }
    
    let map = MKMapView()
    let dialogueBox = UILabel()
    let resultsView = UITableView()
    let searchCompleter = MKLocalSearchCompleter()
    
    var coordinate: CLLocationCoordinate2D?
    var results: [MKMapItem] = []
    var completerResults: [MKLocalSearchCompletion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
// MARK: Warning Box
        dialogueBox.text = "Tap to drop pin"
        dialogueBox.textColor = .white
        dialogueBox.font = UIFont.systemFont(ofSize: 30, weight: .thin)
        dialogueBox.textAlignment = .center
        dialogueBox.backgroundColor = .clear
        dialogueBox.translatesAutoresizingMaskIntoConstraints = false
        
// MARK: Map
        map.translatesAutoresizingMaskIntoConstraints = false
        let coordinate = Managers.shared.locationManager.coordinate
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: kDefaultLongitudinalMeters, longitudinalMeters: kDefaultLongitudinalMeters)
        map.setRegion(region, animated: true)
        map.showsUserLocation = true
        map.mapType = .hybrid
        map.showsCompass = true
        map.showsScale = true
        
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .pointOfInterest
        searchCompleter.region = map.region
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(dropPin))
        map.addGestureRecognizer(tap)
        
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        resultsView.isHidden = true
        resultsView.dataSource = self
        resultsView.delegate = self
        resultsView.backgroundColor = .white
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        resultsView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        view.addSubview(dialogueBox)
        view.addSubview(map)
        view.addSubview(resultsView)

        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            resultsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            resultsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            dialogueBox.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dialogueBox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dialogueBox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dialogueBox.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func nextButtonHandler() {
        guard let coordinate = coordinate else {
            dialogueBox.backgroundColor = .white
            dialogueBox.textColor = .red
            dialogueBox.text = "Please select a location first"
            return
        }
        let next = NewPicnicController()
        next.configure(coordinate: coordinate)
        navigationController?.pushViewController(next, animated: true)
    }
    
    @objc func backButtonTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func dropPin(_ gesture: UITapGestureRecognizer) {
        dialogueBox.backgroundColor = .clear
        dialogueBox.textColor = .white
        dialogueBox.text = "Tap to drop pin"
        map.removeAnnotations(map.annotations.filter { $0 is MKPointAnnotation })
        let screenLocation = gesture.location(in: map)
        let mapCoordinate = map.convert(screenLocation, toCoordinateFrom: map)
        coordinate = mapCoordinate
        let pin = MKPointAnnotation()
        pin.coordinate = mapCoordinate
        map.addAnnotation(pin)
    }
}

extension LocationSelector: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        resultsView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchBar.text ?? ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchCompleter.queryFragment = searchBar.text ?? ""
    }
}

extension LocationSelector: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        completerResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let suggestion = completerResults[indexPath.row]
        cell.textLabel?.text = suggestion.title
        cell.detailTextLabel?.text = suggestion.subtitle
        return cell
    }
}

extension LocationSelector: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = completerResults[indexPath.row]
        let request = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: request)
        search.start { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let mapItems = result?.mapItems {
                self.results = mapItems
                self.map.addAnnotations(mapItems.map { $0.placemark})
                self.resultsView.isHidden = true
            }
        }
    }
}

extension LocationSelector: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerResults = completer.results
        resultsView.reloadData()
    }
}
