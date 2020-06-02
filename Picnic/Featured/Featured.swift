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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        configure()
    }
    
    func refresh() {
        print("refresh called")
        dbManager.picnic { data in
            self.locations = data
            self.collectionView.reloadData()
        }
    }
    
    func refresh(picnic: Picnic, dbRef: DatabaseReference) {
        self.locations.append(picnic)
        print(self.locations[self.locations.count - 1].name)
        self.collectionView.insertItems(at: [.init(item: self.locations.count - 1, section: 0)])
    }
    
    func configure() {
        refresh()
        
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        
        self.collectionView!.register(FeaturedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.square"), style: .plain, target: self, action: #selector(rightButton))
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        navigationController?.title = "Featured"
    }
    
    @objc func rightButton() {
        
        navigationController?.pushViewController(NewLocationController(), animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        
        cell.configure(title: locations[indexPath.item].name, imageName: locations[indexPath.item].imageName, imageViewSize: .init(width: 140, height: 200))
    
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
