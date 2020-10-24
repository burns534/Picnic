//
//  NewLocationController.swift
//  Picnic
//
//  Created by Kyle Burns on 5/27/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class NewPicnicController: UIViewController {
    let detailView = DetailView()
    var coordinate = CLLocationCoordinate2D()
    private var images: [UIImage] = []
    private var shared: Bool = false
    private var picnic: Picnic = .empty
    private var tags: [PicnicTag] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        view.backgroundColor = .white
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToEndEditing))
//        view.addGestureRecognizer(tapGestureRecognizer)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share))
        
        detailView.reviews.removeFromSuperview()
        detailView.liked.isUserInteractionEnabled = false
        view.addSubview(detailView)
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let picnicModal = NewPicnicModal()
        picnicModal.offset = kModalOffset
        picnicModal.transitioningDelegate = self
        picnicModal.modalPresentationStyle = .custom
        picnicModal.delegate = self
        present(picnicModal, animated: true)
    }
    
// MARK: Obj-C functions
    
    @objc func share(_ sender: UIButton) {
        guard let uid = Managers.shared.auth.currentUser?.uid,
              !shared
        else { return }
        shared = true
        coordinate.getPlacemark { [self] placemark in
            picnic.city = placemark.locality
            picnic.state = placemark.administrativeArea
            picnic.uid = uid
            
            Managers.shared.databaseManager.store(picnic: picnic, images: self.images) {
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.selectedIndex = 0
            }
        }
     }
    
    @objc func backButtonTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
//    @objc func tapToEndEditing(_ gesture: UITapGestureRecognizer) {
//        let loc = gesture.location(in: view)
//        if name.frame.contains(loc) { return }
//        else if userDescription.frame.contains(loc) { return }
//        else if category.frame.contains(loc) { return }
//        view.endEditing(true)
//    }
}

extension NewPicnicController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = ShortPresentationController(presentedViewController: presented, presenting: presenting)
        pc.offset = kModalOffset
        return pc
    }
}
// TODO: This really is a poor design..
extension NewPicnicController: NewPicnicModalDelegate {
    func confirm(_ sender: NewPicnicModal) {
        images = sender.selectedImages
        picnic.name = sender.nameStage.contentTextField.text
        picnic.rating = sender.ratingStage.rating.rating
        picnic.ratingCount = 1
        picnic.totalRating = Int(picnic.rating)
        picnic.userDescription = sender.contentStage.contentTextField.text
        picnic.imageNames = images.map { _ in UUID().uuidString }
        picnic.coordinate = coordinate
        picnic.tags = TagContainer(sender.tagStage.tags)
        detailView.configure(picnic: picnic, image: images.first)
    }
}

