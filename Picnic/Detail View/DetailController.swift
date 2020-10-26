//
//  PicnicDetailViewController.swift
//  Picnic
//
//  Created by Kyle Burns on 7/18/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit

let kModalOffset: CGFloat = UIScreen.main.bounds.height * 0.55
let kStagedModalLabelWidthMultiplier: CGFloat = 0.7
let kStagedModalLabelHeightMultiplier: CGFloat = 0.2

class DetailController: UIViewController {
    var picnic: Picnic = .empty
    let detailView = DetailView(frame: .zero)
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        
// MARK: Preview Subviews
        detailView.configure(picnic: picnic, image: nil)
        detailView.liked.addTarget(self, action: #selector(likePress), for: .touchUpInside)
        detailView.reviews.delegate = self
        Managers.shared.databaseManager.addReviewQuery(for: picnic, limit: 20, queryKey: "Reviews")
        Managers.shared.databaseManager.nextPage(forReviewQueryKey: "Reviews") { reviews in
            self.detailView.reviews.update(reviews: reviews)
        }
        detailView.tagView.isScrollEnabled = false
        let tgr = UITapGestureRecognizer(target: self, action: #selector(mapTap))
        detailView.mapView.addGestureRecognizer(tgr)
        view.addSubview(detailView)
        
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        let rightBarButtonItem = UIBarButtonItem(systemItem: .action)
        rightBarButtonItem.target = self
        rightBarButtonItem.action = #selector(options)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
//        navigationController?.navigationBar.isTranslucent = true
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationController?.navigationBar.tintColor = .white
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        Managers.shared.databaseManager.addSaveListener(picnic: picnic, listener: detailView.liked) { liked in
            self.detailView.liked.setActive(isActive: liked)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Managers.shared.databaseManager.removeListener(detailView.liked)
        Managers.shared.databaseManager.removeQuery("Reviews")
    }

    @objc func mapTap(_ sender: UITapGestureRecognizer) {
        let mc = MapViewController()
        mc.picnic = picnic
        navigationController?.pushViewController(mc, animated: true)
    }
    
    @objc func likePress(_ sender: HeartButton) {
        if sender.isActive {
            Managers.shared.databaseManager.unsavePost(picnic: picnic)
        } else {
            Managers.shared.databaseManager.savePost(picnic: picnic)
        }
    }
    
    @objc func options() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Share", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Get Directions", style: .default, handler: { alert in
            let item = MKMapItem(placemark: MKPlacemark(coordinate: self.picnic.coordinate))
            item.name = self.picnic.name
            item.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                MKLaunchOptionsShowsTrafficKey: true
            ])
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            actionSheet.dismiss(animated: true)
        }))
        
        present(actionSheet, animated: true)
    }
}

extension DetailController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = ShortPresentationController(presentedViewController: presented, presenting: presenting)
        pc.offset = kModalOffset
        return pc
    }
}

extension DetailController: ReviewsDelegate {
    func presentModal() {
        let reviewModal = ReviewCreationController()
        reviewModal.transitioningDelegate = self
        reviewModal.modalPresentationStyle = .custom
        reviewModal.offset = kModalOffset
        reviewModal.picnic = picnic
        present(reviewModal, animated: true)
    }
}

extension DetailController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
