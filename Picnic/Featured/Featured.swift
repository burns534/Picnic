//
//  FeaturedCollectionViewController.swift
//  Picnic
//
//  Created by Kyle Burns on 5/25/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
import FirebaseDatabase
let kFeaturedCellSize = CGSize(width: 400, height: 260)

class Featured: UIViewController {
    private var picnics: [Picnic] = []
    let picnicCollectionView = PicnicCollectionView(frame: .zero)
    let mapView = PicnicMap()
    private let mapImage = UIImage(systemName: "map")?.withRenderingMode(.alwaysTemplate)
    private let featuredImage = UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Featured"
        picnicCollectionView.translatesAutoresizingMaskIntoConstraints = false
        picnicCollectionView.delegate = self
        let location = Managers.shared.locationManager.safeLocation
        PicnicManager.default.addPicnicQuery(params: [.location: location], key: "Picnics")
        PicnicManager.default.nextPage(for: "Picnics") { picnics in
            self.picnics = picnics
            self.picnicCollectionView.refresh(picnics: picnics)
        }
        view.addSubview(picnicCollectionView)

        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.setup()
        mapView.isHidden = true
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            picnicCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            picnicCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picnicCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            picnicCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.tintColor = .systemBlue
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: mapImage, style: .plain, target: self, action: #selector(toggleHandler))

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(filterHandler))
        navigationController?.navigationBar.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    
    
    @objc func toggleHandler(_ sender: UIButton) {
        if mapView.isHidden {
            mapView.update(picnics: picnics)
            navigationItem.rightBarButtonItem?.image = featuredImage
            mapView.isHidden = false
        } else {
            picnicCollectionView.refresh(picnics: picnics)
            navigationItem.rightBarButtonItem?.image = mapImage
            mapView.isHidden = true
        }
    }
    
    @objc func filterHandler(_ sender: UIBarButtonItem) {
        let filterController = FilterController()
        filterController.delegate = self
        present(filterController, animated: true)
    }
}

extension Featured: PicnicCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailView = DetailController()
        detailView.picnic = picnics[indexPath.item]
        navigationController?.pushViewController(detailView, animated: true)
    }
    
    func refresh(completion: @escaping ([Picnic]) -> ()) {
        PicnicManager.default.refreshPage(for: "Picnics") {
            self.picnics = $0
            completion($0)
        }
    }
}

extension Featured: PicnicMapDelegate {
    func annotationTap(picnic: Picnic) {
        let detailView = DetailController()
        detailView.picnic = picnic
        navigationController?.pushViewController(detailView, animated: true)
    }
}

extension Featured: FilterControllerDelegate {
    func filterChange() {
        PicnicManager.default.refreshPage(for: "Picnics") { picnics in
            self.picnics = picnics
            if self.mapView.isHidden {
                self.picnicCollectionView.refresh(picnics: picnics)
            } else {
                self.mapView.update(picnics: picnics)
            }
        }
    }
}


