//
//  CustomImagePickerController.swift
//  Picnic
//
//  Created by Kyle Burns on 7/1/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"
private let kPreviewFrameWidth = 414
private let kPreviewFrameHeight = 400

#if targetEnvironment(simulator)
    let cameraBlock = true
#else
    let cameraBlock = false
#endif

protocol CustomImagePickerControllerDelegate: AnyObject {
    func refreshImageSource(images: [UIImage])
}

class CustomImagePickerController: UICollectionViewController {
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    var preview: UIImageView!
    var selectedImages = [Int: UIImage]()
    var sourceButton: UIButton!
    var menu: FloatingMenu!
    var counter: Int16 = 0
    var availableWidth: CGFloat = 0
    var limitView: UILabel!
    var navigationBar: NavigationBar!
    var imagePickerController: UIImagePickerController!
    
    let previewFrame = CGRect(x: 0, y: 0, width: kPreviewFrameWidth, height: kPreviewFrameHeight)
    
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect: CGRect = .zero
    
    private var imageManager = PHCachingImageManager()
    private var previousSelectedIndexPath: IndexPath = IndexPath()
    
    weak var delegate: CustomImagePickerControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(ImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        configurePhotos()
        setup()
    }
    
    func configurePhotos() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        allPhotosOptions.predicate = predicate
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        PHPhotoLibrary.shared().register(self)
    }
    
    func setup() {
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        view.backgroundColor = .white
        
        let asset = fetchResult.object(at: 0)
        preview = UIImageView()
        preview.contentMode = .scaleAspectFit
        view.addSubview(preview)
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 800, height: 1200), contentMode: .aspectFit, options: nil) { image, _ in
            if image != nil {
                self.preview.image = image
            } else {
                print("Error: CustomImagePickerController: setup: PHImageManager returned nil for preview Image")
            }
        }
        
        imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.cameraDevice = .rear
        
        menu = FloatingMenu()
        menu.layer.cornerRadius = 20
        menu.clipsToBounds = true
        view.addSubview(menu)
        
        limitView = UILabel()
        limitView.backgroundColor = .darkWhite
        limitView.text = "There is a limit of 5 photos per picnic"
        limitView.textColor = .black
        limitView.textAlignment = .center
        limitView.isHidden = true
        view.addSubview(limitView)
        
        navigationBar = NavigationBar(frame: kNavigationBarFrame)
        navigationBar.setTitle(text: "Select Photos")
        navigationBar.title?.font = UIFont.systemFont(ofSize: 25)
        navigationBar.title?.textColor = .olive
        navigationBar.rightBarButton.setTitle("Confirm", for: .normal)
        navigationBar.rightBarButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        navigationBar.rightBarButton.setTitleColor(.olive, for: .normal)
        navigationBar.rightBarButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .light)
        navigationBar.setRightButtonPadding(amount: 10)
        view.addSubview(navigationBar)
        
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 60),
            
            preview.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            preview.heightAnchor.constraint(equalToConstant: 400),
            preview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            preview.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            collectionView.topAnchor.constraint(equalTo: preview.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            menu.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            menu.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            menu.widthAnchor.constraint(equalToConstant: 200),
            menu.heightAnchor.constraint(equalToConstant: 50),
            
            limitView.bottomAnchor.constraint(equalTo: preview.bottomAnchor),
            limitView.centerXAnchor.constraint(equalTo: preview.centerXAnchor),
            limitView.heightAnchor.constraint(equalToConstant: 50),
            limitView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let scale = UIScreen.main.scale
        // should be fine
        let cellSize = (collectionViewLayout as! CustomPickerFlowLayout).itemSize
        self.thumbnailSize = CGSize(width: scale * cellSize.width, height: scale * cellSize.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = fetchResult.object(at: indexPath.item)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ImageCell else {
            fatalError("Error: CustomImagePickerController: collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath): could not cast UICollectionViewCell to ImageCell at indexPath \(indexPath)")
        }
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.configure()
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { image, _ in
            // Not sure what this means
            // UIKit may have recycled this cell by the handler's activation time.
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    func updateCachedAssets() {
        guard isViewLoaded && view.window != nil else { return }
        
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // detect scroll change?
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        // if scroll isn't enough, it would waste resources to update
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForVisibleItems }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForVisibleItems }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        // Store the computed rectangle for future comparison.
        previousPreheatRect = preheatRect

    }
    // did not help
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        limitView.text = "There is a limit of 5 photos per picnic"
        if selectedImages.count < 5 { limitView.isHidden = true }
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
        let asset = fetchResult.object(at: indexPath.item)
// case: is current preview
        if previousSelectedIndexPath == indexPath {
            if cell.hasActiveSelection {
                if selectedImages.count >= 5 {
                    limitView.isHidden = true
                }
                selectedImages.removeValue(forKey: indexPath.item)
                cell.hasActiveSelection = false
            } else if selectedImages.count < 5 {
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.resizeMode = .fast
                PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 800, height: 1200), contentMode: .aspectFit, options: options) { image, _ in
                    if image != nil {
                        self.selectedImages[indexPath.item] = image
                    } else {
                        print("Error: CustomImagePickerController: didSelectItemAt: PHImageManager returned nil for image at cell \(indexPath.item)")
                    }
                }
                cell.hasActiveSelection = true
            } else {
                limitView.isHidden = false
            }
// case: is not current preview - only case that changes index path
        } else {
            if cell.hasActiveSelection {
                if selectedImages.count >= 5 {
                    limitView.isHidden = true
                }
                selectedImages.removeValue(forKey: indexPath.item)
                cell.hasActiveSelection = false
            } else if selectedImages.count < 5 {
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.resizeMode = .fast
                PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 800, height: 1200), contentMode: .aspectFit, options: options) { image, _ in
                    if let image = image {
                        self.preview.image = image
                        self.selectedImages[indexPath.item] = image
                    } else {
                        print("Error: CustomImagePickerController: didSelectItemAt: PHImageManager returned nil for image at cell \(indexPath.item)")
                    }
                }
                previousSelectedIndexPath = indexPath
                cell.hasActiveSelection = true
            } else {
                limitView.isHidden = false
            }
        }
    }
// MARK: Objective C Functions
    
    @objc func confirm(_ sender: UIButton) {
        if selectedImages.count == 0 {
            limitView.text = "No images selected"
            limitView.isHidden = false
            return
        }
        dismiss(animated: true)
        delegate?.refreshImageSource(images: Array(selectedImages.values))
    }
    
    @objc func cameraPress(_ sender: UIButton) {
        if !cameraBlock {
            present(imagePickerController, animated: true, completion: nil)
        } else {
            print("Error: Floating Menu: cameraPress: Cannot access camera")
        }
    }
    
}

// MARK: Need to finish this
extension CustomImagePickerController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        //
    }
}

extension CustomImagePickerController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            print("Error: Floating Menu: didFinishPickingMediaWithInfo: Could not load image")
            return
        }
        delegate?.refreshImageSource(images: [image])
        dismiss(animated: true)
        navigationController?.popViewController(animated: false)
    }
}
