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
let kDefaultSearchWidth: CLLocationDistance = 32_000

class LocationSelector: UIViewController {
    
    private enum AnnotationReuseID: String { case pin }
    
    let map = MKMapView()
    let dialogueBox = UILabel()
    let resultsView = UITableView()
    let searchCompleter = MKLocalSearchCompleter()
    let confirmButton = UIButton()
    let searchBar = UISearchBar()
    
    var coordinate: CLLocationCoordinate2D?
    var results: [MKMapItem] = []
    var completerResults: [MKLocalSearchCompletion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
// MARK: Warning Box
        dialogueBox.text = "Tap to drop pin"
        dialogueBox.textColor = .white
        dialogueBox.font = UIFont.systemFont(ofSize: 35, weight: .light)
        dialogueBox.textAlignment = .center
        dialogueBox.translatesAutoresizingMaskIntoConstraints = false
        dialogueBox.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
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
        searchCompleter.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: kDefaultSearchWidth, longitudinalMeters: kDefaultSearchWidth)
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(dropPin))
        map.addGestureRecognizer(tap)
        
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        resultsView.isHidden = true
        resultsView.dataSource = self
        resultsView.delegate = self
        resultsView.backgroundColor = .white
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        resultsView.register(SuggestionCell.self, forCellReuseIdentifier: SuggestionCell.reuseID)
        
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 35, weight: .light)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.isHidden = true
        confirmButton.addTarget(self, action: #selector(confirmHandler), for: .touchUpInside)
        confirmButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        view.addSubview(map)
        view.addSubview(resultsView)
        view.addSubview(dialogueBox)
        view.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            resultsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            resultsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            dialogueBox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            dialogueBox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dialogueBox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dialogueBox.heightAnchor.constraint(equalToConstant: 60),
            
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func confirmHandler() {
        guard let coordinate = coordinate else {
            dialogueBox.backgroundColor = .white
            dialogueBox.textColor = .red
            dialogueBox.text = "Please select a location first"
            confirmButton.isHidden = true
            dialogueBox.isHidden = false
            return
        }
        let next = NewPicnicController()
        next.coordinate = coordinate
        navigationController?.pushViewController(next, animated: true)
    }
    
    @objc func backButtonTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func dropPin(_ gesture: UITapGestureRecognizer) {
        dialogueBox.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dialogueBox.textColor = .white
        dialogueBox.text = "Tap to drop pin"
        map.removeAnnotations(map.annotations.filter { $0 is MKPointAnnotation })
        let screenLocation = gesture.location(in: map)
        let mapCoordinate = map.convert(screenLocation, toCoordinateFrom: map)
        coordinate = mapCoordinate
        let pin = MKPointAnnotation()
        pin.coordinate = mapCoordinate
        map.addAnnotation(pin)
        dialogueBox.isHidden = true
        confirmButton.isHidden = false
    }
}

extension LocationSelector: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
        searchBar.text = ""
        results = []
        resultsView.isHidden = true
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
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(center: Managers.shared.locationManager.coordinate, latitudinalMeters: kDefaultSearchWidth, longitudinalMeters: kDefaultSearchWidth)
        let search = MKLocalSearch(request: request)
        search.start { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let mapItems = result?.mapItems {
                self.results = mapItems
                self.resultsView.reloadData()
            }
        }
    }
}

extension LocationSelector: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        completerResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SuggestionCell.reuseID, for: indexPath)
        let suggestion = completerResults[indexPath.row]
        let title = NSMutableAttributedString(string: suggestion.title, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)])
        let subtitle = NSMutableAttributedString(string: suggestion.subtitle)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 18.0)]
        suggestion.titleHighlightRanges.forEach {
            title.addAttributes(attributes, range: $0.rangeValue)
        }
        suggestion.subtitleHighlightRanges.forEach {
            subtitle.addAttributes(attributes, range: $0.rangeValue)
        }
        cell.textLabel?.attributedText = title
        cell.detailTextLabel?.attributedText = subtitle
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
                let annotations: [MKPointAnnotation] = mapItems.map {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = $0.placemark.coordinate
                    annotation.title = $0.name
                    annotation.subtitle = $0.placemark.title
                    return annotation
                }
                self.map.addAnnotations(annotations)
                self.confirmButton.isHidden = false
                self.dialogueBox.isHidden = true
                self.resultsView.isHidden = true
                self.searchBar.resignFirstResponder()
                self.searchBar.endEditing(true)
                self.searchBar.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
                guard let coordinate = annotations.first?.coordinate else {
                    return
                }
                self.map.setCenter(coordinate, animated: true)
                self.coordinate = coordinate
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

class SuggestionCell: UITableViewCell {
    static let reuseID = "SuggestionCellReuseID"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
