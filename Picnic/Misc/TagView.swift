//
//  TagView.swift
//  Picnic
//
//  Created by Kyle Burns on 10/20/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

protocol TagViewSelectionDelegate: AnyObject {
    func didSelectTag(tags: [PicnicTag], at indexPath: IndexPath)
    func didDeslectTag(tags: [PicnicTag], at indexPath: IndexPath)
}

class TagView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    enum Mode {
        case selection, display
    }
    
    private var labels: [String] {
        tags.map { $0.prettyString }
    }

    var tags: [PicnicTag] = []
    var defaultColor: UIColor = .lightGray
    var selectionColor: UIColor = .olive
    
    var mode: Mode = .selection {
        didSet {
            isUserInteractionEnabled = mode == .selection
            visibleCells.forEach { cell in
                switch mode {
                case .display:
                    cell.contentView.backgroundColor = self.selectionColor
                case .selection:
                    cell.contentView.backgroundColor = cell.isSelected ? selectionColor : defaultColor
                }
            }
        }
    }
    
    var selectedItems: [PicnicTag] {
        indexPathsForSelectedItems?.map {
            PicnicTag.allCases[$0.item]
        } ?? []
    }
    
    weak var selectionDelegate: TagViewSelectionDelegate?
    
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
//                cell.alpha = 0.8
                cell.transform = .init(scaleX: 0.95, y: 0.95)
                cell.contentView.backgroundColor = self.selectionColor
            }
            selectionDelegate?.didSelectTag(tags: selectedItems, at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PicnicTagCell {
            UIView.animate(withDuration: 0.1) {
//                cell.alpha = 1.0
                cell.transform = .identity
                cell.contentView.backgroundColor = self.defaultColor
            }
            selectionDelegate?.didDeslectTag(tags: selectedItems, at: indexPath)
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
        let color = mode == .selection ? selectionColor : defaultColor
        cell.contentView.layer.borderColor = color.cgColor
        cell.contentView.backgroundColor = color.withAlphaComponent(0.8)
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
        
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
