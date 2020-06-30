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

let cellSize = CGSize(width: 350, height: 300)

class Featured: UICollectionViewController {
    
    var locations = [Picnic]()
    
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
    
    func refresh() {
        dbManager.picnic { data in
            self.locations = data
            self.collectionView.reloadData()
        }
    }
    
    func refresh(picnic: Picnic, dbRef: DatabaseReference) {
        self.locations.append(picnic)
        self.collectionView.insertItems(at: [.init(item: self.locations.count - 1, section: 0)])
    }
    
    func configure() {
        refresh()
        
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        
        self.collectionView!.register(FeaturedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.square"), style: .plain, target: self, action: #selector(rightBarButton))
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        navigationController?.title = "Featured"
    }
    
    @objc func rightBarButton() {
        
        navigationController?.pushViewController(NewLocationController(rating: .init(frame: .zero, starSize: .init(width: 30, height: 30), spacing: 1, rating: 0)), animated: true)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return locations.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FeaturedCell else
        {
            print("Error: Could not load cell")
            return UICollectionViewCell()
        }
        let picnic = locations[indexPath.item]
        cell.setupShadow(cellSize: cellSize)
        cell.configure(parent: self, picnic: picnic, imageViewSize: cellSize / 2, rating: Rating(frame: .zero, starSize: .init(width: 20, height: 20), spacing: 1, rating: CGFloat(picnic.rating)))
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
