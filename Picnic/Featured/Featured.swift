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
    var picnics = [Picnic]()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CustomFlowLayout())
    let mapView = PicnicMap()
    let mapImage = UIImage(systemName: "map")?.withRenderingMode(.alwaysOriginal)
    let featuredImage = UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate)
    
    private let refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Featured"
        refreshController.addTarget(self, action: #selector(pullDown), for: .valueChanged)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.refreshControl = refreshController
        collectionView.register(FeaturedCell.self, forCellWithReuseIdentifier: FeaturedCell.reuseID)
        let location = Managers.shared.locationManager.location ?? .init()
        Managers.shared.databaseManager.addPicnicQuery(location: location, limit: kDefaultQueryLimit, radius: kDefaultQueryRadius, key: "Picnics")
        Managers.shared.databaseManager.nextPage(forPicnicQueryKey: "Picnics") { picnics in
            self.collectionView.performBatchUpdates {
                self.picnics = picnics
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
        view.addSubview(collectionView)

        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.setup()
        mapView.isHidden = true
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: mapImage, style: .plain, target: self, action: #selector(toggleHandler))
        navigationItem.rightBarButtonItem?.tintColor = .olive

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(filterHandler))
        navigationItem.leftBarButtonItem?.tintColor = .olive
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc func pullDown(_ sender: Any) {
        Managers.shared.databaseManager.refresh(forPicnicQueryKey: "Picnics") { picnics in
            self.collectionView.performBatchUpdates {
                self.picnics = picnics
                self.collectionView.reloadSections(IndexSet(integer: 0))
            } completion: { _ in
                self.refreshController.endRefreshing()
            }
        }
    }
    
    @objc func rightBarButton() {
        navigationController?.pushViewController(LocationSelector(), animated: true)
    }
    
    @objc func toggleHandler(_ sender: UIButton) {
        if mapView.isHidden {
            navigationItem.rightBarButtonItem?.image = featuredImage
            mapView.isHidden = false
        } else {
            navigationItem.rightBarButtonItem?.image = mapImage
            mapView.isHidden = true
        }
        mapView.update(picnics: picnics)
    }
    
    @objc func filterHandler(_ sender: UIBarButtonItem) {
        let filterController = FilterController()
        filterController.delegate = self
        present(filterController, animated: true)
    }
}

extension Featured: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        picnics.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCell.reuseID, for: indexPath) as? FeaturedCell else {
            return UICollectionViewCell()
        }
        cell.configure(picnic: picnics[indexPath.item])
        return cell
    }
}

extension Featured: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailView = DetailController()
        detailView.configure(picnic: picnics[indexPath.item])
        navigationController?.pushViewController(detailView, animated: true)
    }
}

extension Featured: PicnicMapDelegate {
    func annotationTap(picnic: Picnic) {
        let detailView = DetailController()
        detailView.configure(picnic: picnic)
        navigationController?.pushViewController(detailView, animated: true)
    }
}

extension Featured: FilterControllerDelegate {
    func refreshDataSource(picnics: [Picnic]) {
        self.picnics = picnics
        if !mapView.isHidden {
            collectionView.reloadData()
            mapView.update(picnics: picnics)
        } else {
            collectionView.performBatchUpdates {
                collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
        
    }
}


