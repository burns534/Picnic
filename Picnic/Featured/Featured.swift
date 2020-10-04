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

class Featured: UICollectionViewController {
    
    var locations = [Picnic]()
    
    private let refreshController = UIRefreshControl()
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        title = "Featured"
        tabBarItem.image = UIImage(systemName: "star")
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func refresh(completion: @escaping () -> () = {}) {
        guard let loc = Shared.shared.locationManager.location else { return }
        Shared.shared.databaseManager.query(byLocation: loc, queryLimit: 20, precision: 3) { picnics in
            self.locations = picnics
            self.collectionView.reloadData()
            completion()
        }
    }
    
    func configure() {
        refresh()
        
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.refreshControl = refreshController
        
        refreshController.addTarget(self, action: #selector(pullDown), for: .valueChanged)
        
        self.collectionView!.register(FeaturedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.square"), style: .plain, target: self, action: #selector(rightBarButton))
        navigationItem.rightBarButtonItem?.tintColor = .olive
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(filterHandler))
        navigationItem.leftBarButtonItem?.tintColor = .olive
        
        Shared.shared.authManager.delegate = self
    }
    
    
    
    @objc func pullDown(_ sender: Any) {
        refresh { self.refreshController.endRefreshing() }
    }
    
    @objc func rightBarButton() {
        navigationController?.pushViewController(LocationSelector(), animated: true)
    }
    
    @objc func filterHandler(_ sender: UIBarButtonItem) {
        
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FeaturedCell else
        {
            print("Error: Could not load cell")
            return UICollectionViewCell()
        }
        let picnic = locations[indexPath.item]
        cell.configure(picnic: picnic)
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailView = DetailController()
        detailView.configure(picnic: locations[indexPath.item])
        navigationController?.pushViewController(detailView, animated: true)
    }

}

extension Featured: AuthManagerDelegate {
    func didSignIn() {
        collectionView.reloadData()
    }
}
