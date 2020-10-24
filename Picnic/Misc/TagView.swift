//
//  TagView.swift
//  Picnic
//
//  Created by Kyle Burns on 10/20/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class TagView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var labels: [String] {
        tags.map { $0.prettyString }
    }

    var tags: [PicnicTag] = []
    
    override var intrinsicContentSize: CGSize {
        collectionViewLayout.collectionViewContentSize
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        dataSource = self
        delegate = self
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        allowsMultipleSelection = true
        register(PicnicTagCell.self, forCellWithReuseIdentifier: PicnicTagCell.reuseID)
    }
    
    convenience init(tags: [PicnicTag]) {
        self.init()
        self.tags = tags
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }
    
// MARK: UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PicnicTagCell {
            UIView.animate(withDuration: 0.1) {
                cell.alpha = 0.8
                cell.transform = .init(scaleX: 0.95, y: 0.95)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PicnicTagCell {
            UIView.animate(withDuration: 0.1) {
                cell.alpha = 1.0
                cell.transform = .identity
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return NSString(string: labels[indexPath.item]).size(withAttributes: [.font: UIFont.systemFont(ofSize: 20, weight: .light)]) + 10
    }
    
// MARK: UICollectionView Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PicnicTagCell.reuseID, for: indexPath) as? PicnicTagCell else {
            return UICollectionViewCell()
        }
        cell.label.text = labels[indexPath.item]
        return cell
    }
}

class PicnicTagCell: UICollectionViewCell {
    static let reuseID = "PicnicTagCellReuseID"
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        contentView.backgroundColor = UIColor.organic.withAlphaComponent(0.7)
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.organic.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
