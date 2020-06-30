//
//  FeaturedCelll.swift
//  Picnic
//
//  Created by Kyle Burns on 5/22/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class FeaturedCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    var title: UILabel!
    var userDescription: UITextView!
    var state: UILabel!
    var rating: Rating!
    var deleteButton: UIButton!
    var parent: Featured!
    
    var picnic: Picnic!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setupShadow(cellSize: CGSize) {
        // configure cell
        self.layer.cornerRadius = 30
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: cellSize.width, height: cellSize.height), cornerRadius: 30).cgPath
        buttonShadow(view: self, radius: 10, color: UIColor.darkGray.cgColor, opacity: 0.9, offset: CGSize(width: 0, height: 5))
    }
    
    func setup() {
        self.backgroundColor = .white
        //self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        // configure image
        imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        contentView.addSubview(imageView!)
        
        // configure title
        title = UILabel(frame: frame)
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 3
        contentView.addSubview(title)
        
        userDescription = UITextView(frame: frame)
        userDescription.isUserInteractionEnabled = false
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userDescription)
        
        state = UILabel(frame: frame)
        state.translatesAutoresizingMaskIntoConstraints = false
        state.numberOfLines = 1
        contentView.addSubview(state)
        
        deleteButton = UIButton(frame: .zero)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deletePress), for: .touchUpInside)
        deleteButton.setTitle("delete", for: .normal)
        deleteButton.setTitleColor(.black, for: .normal)
        contentView.addSubview(deleteButton)
    }
    
    /* mostly works.... the collection view bug is pretty much irrelevant though
     it really doesn't even make sense to have a delete button at all... not sure what I was thinking. */
    @objc func deletePress(_ sender: UIButton) {
        print("deletePress called")
        let index = parent.collectionView.indexPath(for: self)!
        dbManager.deletePicnic(picnic: self.picnic) {
            print("deletePicnic completion")
            dbManager.deleteImage(for: self.picnic.name) {
                print("deleteImage completion")
                self.parent.locations.remove(at: index.item)
                self.parent.collectionView.deleteItems(at: [index])
            }
        }
        
    }
    
    func configure(parent: Featured, picnic: Picnic, imageViewSize: CGSize, rating: Rating) {
        dbManager.image(for: picnic.imageName) { image, error in
            if let _ = error {
                return
            } else {
                self.imageView.image = image
            }
        }
        self.parent = parent
        self.picnic = picnic
        self.title.text = picnic.name
        self.userDescription.text = picnic.userDescription
        self.state.text = picnic.state
        self.rating = rating
        self.rating.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.rating)
        // constraints
        NSLayoutConstraint.activate([
            // supplied
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.contentView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.contentView.widthAnchor.constraint(equalTo: self.widthAnchor),
            
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 5),
            self.imageView.widthAnchor.constraint(equalToConstant: imageViewSize.width),
            self.imageView.heightAnchor.constraint(equalToConstant: imageViewSize.width),
            
            self.title.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            self.title.leftAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: 10),
            self.title.widthAnchor.constraint(equalToConstant: 100),
            self.title.heightAnchor.constraint(equalToConstant: 20),
            
            self.rating.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 5),
            self.rating.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor),
            self.rating.widthAnchor.constraint(equalToConstant: self.rating.width),
            self.rating.heightAnchor.constraint(equalToConstant: self.rating.starSize.height),
            
            // Slight issue with text alignment here
            self.userDescription.topAnchor.constraint(equalTo: self.rating.bottomAnchor, constant: 5),
            self.userDescription.leftAnchor.constraint(equalTo: self.imageView.leftAnchor),
            self.userDescription.widthAnchor.constraint(equalToConstant: 250),
            self.userDescription.heightAnchor.constraint(equalToConstant: 60),
            
            self.state.topAnchor.constraint(equalTo: self.userDescription.bottomAnchor, constant: 5),
            self.state.widthAnchor.constraint(equalToConstant: 200),
            self.state.heightAnchor.constraint(equalToConstant: 20),
            self.state.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            
            self.deleteButton.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: 10),
            self.deleteButton.leftAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: 10),
            self.deleteButton.heightAnchor.constraint(equalToConstant: 30),
            self.deleteButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}
