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

let cellSize = CGSize(width: 400, height: 300)

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
    
    func refresh(completion: @escaping ([Picnic]) -> () = {_ in}) {
        guard let loc = Shared.shared.locationManager.location else {
            print("Error: Featured: refresh: found nil for location")
            return
        }
        Shared.shared.databaseManager.query(byLocation: loc, queryLimit: 5, precision: 3) { picnics in
            self.locations = picnics
            self.collectionView.reloadData()
            completion(picnics)
        }
    }
    
    func configure() {
        refresh()
        
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.refreshControl = self.refreshController
        
        self.refreshController.addTarget(self, action: #selector(pullDown), for: .valueChanged)
        
        self.collectionView!.register(FeaturedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.square"), style: .plain, target: self, action: #selector(rightBarButton))
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        navigationController?.title = "Featured"
    }
    
    
    
    @objc func pullDown(_ sender: Any) {
        refresh { picnic in
            self.refreshController.endRefreshing()
        }
    }
    
    @objc func rightBarButton() {
        navigationController?.pushViewController(NewLocationController(), animated: true)
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
        guard let cell = collectionView.cellForItem(at: indexPath) as? FeaturedCell else {
            print("Error: Featured: didSelectItemAt: Could not cast")
            return
        }
        navigationController?.pushViewController(PicnicDetailViewController(picnic: cell.picnic), animated: true)
    }

}
