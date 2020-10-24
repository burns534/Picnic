//
//  ReviewCreationViewController.swift
//  Picnic
//
//  Created by Kyle Burns on 10/15/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
import PhotosUI
import FirebaseFirestore

fileprivate let targetSize: CGSize = CGSize(width: 500, height: 500)

class ReviewCreationController: StagedModalController {
    
    let ratingStage = RatingStage(frame: .zero)
    let contentStage = ContentStage(frame: .zero)
    let imagePickerStage = ImagePickerStage(frame: .zero)
    var imagePicker: PHPickerViewController!
    private let imageManager = PHImageManager()
    
    var picnic: Picnic = .empty
    var selectedImages = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePickerStage.imagePickerButton.addTarget(self, action: #selector(presentPicker), for: .touchUpInside)
        
        addStage(ratingStage)
        addStage(contentStage)
        addStage(imagePickerStage)
        
        let photoLibrary = PHPhotoLibrary.shared()
        var imagePickerConfiguration = PHPickerConfiguration(photoLibrary: photoLibrary)
        imagePickerConfiguration.filter = .images
        imagePickerConfiguration.selectionLimit = 10
        imagePicker = PHPickerViewController(configuration: imagePickerConfiguration)
        imagePicker.delegate = self
    }

    @objc func presentPicker() {
// TODO: Implement this
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                print("yayyyy")
            default:
                print("nooooo")
            }
        }
        present(imagePicker, animated: true)
    }
    
    override func confirmationHandler() {
        guard let id = picnic.id,
              let uid = Managers.shared.auth.currentUser?.uid
        else { return }
        let imageIDList = selectedImages.map { _ in UUID().uuidString }
        let review = Review(
            id: nil,
            pid: id,
            uid: uid,
            rating: ratingStage.rating.rating,
            content: contentStage.contentTextField.text ?? "",
            userDisplayName: Managers.shared.auth.currentUser?.displayName,
            userPhotoURL: Managers.shared.auth.currentUser?.photoURL,
            timestamp: Timestamp(date: Date()),
            images: imageIDList
        )
        Managers.shared.databaseManager.submitReview(review: review, images: selectedImages.count > 0 ? selectedImages: nil) { _ in
// TODO: This might be bad, look into it
            self.dismiss(animated: true)
        }
    }
}

extension ReviewCreationController: PHPickerViewControllerDelegate  {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let identifiers = results.compactMap { $0.assetIdentifier }
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
            let taskGroup = DispatchGroup()
            var results: [UIImage] = []
            for i in 0..<fetchResult.count {
                taskGroup.enter()
                let asset = fetchResult.object(at: i)
                self?.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil) {
                    if let image = $0,
                       let degraded = $1?[PHImageResultIsDegradedKey] as? Bool, !degraded {
                        results.append(image)
                        taskGroup.leave()
                    }
                }
            }
            taskGroup.notify(qos: .userInitiated, flags: .enforceQoS, queue: .main) {
                self?.selectedImages = results
                if results.count > 0 {
                    self?.imagePickerStage.imagePickerButton.setImage(results[0], for: .normal)
                    if results.count > 1 {
                        self?.imagePickerStage.imagePickerButton.isMultipleSelection = true
                    }
                }
                picker.dismiss(animated: true)
            }
        }
    }
}
