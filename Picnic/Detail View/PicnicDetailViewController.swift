//
//  PicnicDetailViewController.swift
//  Picnic
//
//  Created by Kyle Burns on 7/18/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

class PicnicDetailViewController: UIViewController {
    
    var map: MKMapView!
    var picnic: Picnic!
    var preview: UIImageView!
    
    init(picnic: Picnic) {
        self.picnic = picnic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        preview = UIImageView()
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.contentMode = .scaleAspectFit
        preview.clipsToBounds = true
        dbManager.image(forPicnic: picnic) { image, error in
            if let error = error {
                self.preview.image = UIImage(named: "loading.jpg")
                print(error.localizedDescription)
                return
            } else {
                self.preview.image = image
            }
        }
        view.addSubview(preview)
        
        NSLayoutConstraint.activate([
            preview.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            preview.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            preview.widthAnchor.constraint(equalToConstant: 200),
            preview.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
}

extension MKMapViewDelegate {
    
}
