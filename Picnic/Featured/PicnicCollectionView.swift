//
//  PicnicCollectionView.swift
//  Picnic
//
//  Created by Kyle Burns on 10/31/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

protocol PicnicCollectionViewDelegate: UICollectionViewDelegate {
    func refresh(completion: @escaping ([Picnic]) -> ())
}
// Maybe shouldn't have put the refresh controller in here
class PicnicCollectionView: UIView {
    var collectionView: UICollectionView
    var picnics: [Picnic] = []
    private let refreshController = UIRefreshControl()
    var delegate: PicnicCollectionViewDelegate? {
        didSet {
            collectionView.delegate = delegate
        }
    }
    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: frame, collectionViewLayout: CustomFlowLayout())
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSubviews() {
        refreshController.addTarget(self, action: #selector(pullDown), for: .valueChanged)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.register(FeaturedCell.self, forCellWithReuseIdentifier: FeaturedCell.reuseID)
        collectionView.refreshControl = refreshController
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc func pullDown(_ sender: Any) {
        delegate?.refresh { picnics in
            self.collectionView.performBatchUpdates {
                self.picnics = picnics
                self.collectionView.reloadSections(IndexSet(integer: 0))
            } completion: { _ in
                self.refreshController.endRefreshing()
            }
        }
    }
    
    func refresh(picnics: [Picnic]) {
        collectionView.performBatchUpdates {
            self.picnics = picnics
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}

extension PicnicCollectionView: UICollectionViewDataSource {
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
