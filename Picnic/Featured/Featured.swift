//
//  FeaturedCollectionViewController.swift
//  Picnic
//
//  Created by Kyle Burns on 5/25/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
import FirebaseDatabase

private let reuseIdentifier = "Cell"

let kFeaturedCellSize = CGSize(width: 400, height: 260)

class Featured: UIViewController {
    
    var locations = [Picnic]()
    var collectionView: UICollectionView!
    
    private let refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Featured"
        refreshController.addTarget(self, action: #selector(pullDown), for: .valueChanged)
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: CustomFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.refreshControl = refreshController
        collectionView.register(FeaturedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        refreshDataSource {
            self.collectionView.performBatchUpdates {
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
        view.addSubview(collectionView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.square"), style: .plain, target: self, action: #selector(rightBarButton))
        navigationItem.rightBarButtonItem?.tintColor = .olive
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(filterHandler))
        navigationItem.leftBarButtonItem?.tintColor = .olive
        
        Shared.shared.authManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
    }
    
    func refreshDataSource(completion: @escaping () -> ()) {
        guard let loc = Shared.shared.locationManager.location else { return }
        Shared.shared.databaseManager.query(byLocation: loc, queryLimit: 20, precision: 3) { picnics in
            self.locations = picnics
            completion()
        }
    }
    
    @objc func pullDown(_ sender: Any) {
        refreshDataSource {
            self.collectionView.performBatchUpdates {
                self.collectionView.reloadSections(IndexSet(integer: 0))
            } completion: { _ in
                self.refreshController.endRefreshing()
            }
        }
    }
    
    @objc func rightBarButton() {
        navigationController?.pushViewController(LocationSelector(), animated: true)
    }
    
    @objc func filterHandler(_ sender: UIBarButtonItem) {
        
    }
}

extension Featured: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        locations.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FeaturedCell else {
            return UICollectionViewCell()
        }
        cell.configure(picnic: locations[indexPath.item])
        return cell
    }
}

extension Featured: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailView = DetailController()
        detailView.configure(picnic: locations[indexPath.item])
        navigationController?.pushViewController(detailView, animated: true)
    }
}

extension Featured: AuthManagerDelegate {
    func didSignIn() { collectionView.reloadData() }
}
