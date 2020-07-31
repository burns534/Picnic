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
fileprivate let previewFrame: CGRect = CGRect(x: 0, y: 0, width: 414, height: 400)

class CustomImagePickerController: UICollectionViewController {
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    var preview: ZoomableImage!
    var selectedImages = [Int: UIImage]()
    var sourceButton: UIButton!
    var destination: UIViewController!
    var menu: FloatingMenu!
    var counter: Int16 = 0
    var availableWidth: CGFloat = 0
    let limitView = UILabel()
    
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect: CGRect = .zero
    
    private var imageManager = PHCachingImageManager()
    private var previousSelectedIndexPath: IndexPath = IndexPath()
    
    convenience init(collectionViewLayout layout: UICollectionViewLayout, destination: UIViewController) {
        self.init(collectionViewLayout: layout)
        self.destination = destination
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

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
        preview = ZoomableImage(frame: previewFrame)
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 800, height: 1200), contentMode: .aspectFit, options: nil) { image, _ in
            if image != nil {
                self.preview.image = image
            } else {
                print("Error: CustomImagePickerController: setup: PHImageManager returned nil for preview Image")
            }
        }
        
        preview.translatesAutoresizingMaskIntoConstraints = false
//        preview.clipsToBounds = true
        view.addSubview(preview)
        
        sourceButton = UIButton()
        sourceButton.setTitle("Recents", for: .normal)
        
        navigationItem.titleView = sourceButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(confirmPhotos))
        
        menu = FloatingMenu(sender: self)
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.layer.cornerRadius = 20
        menu.clipsToBounds = true
        view.addSubview(menu)
        
        limitView.translatesAutoresizingMaskIntoConstraints = false
        limitView.backgroundColor = .white
        limitView.text = "There is a limit of 5 photos per picnic"
        limitView.textColor = .black
        limitView.textAlignment = .center
        limitView.isHidden = true
        view.addSubview(limitView)
        
        NSLayoutConstraint.activate([
            preview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            preview.heightAnchor.constraint(equalToConstant: 400),
            preview.leftAnchor.constraint(equalTo: view.leftAnchor),
            preview.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            
            collectionView.topAnchor.constraint(equalTo: preview.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            
            menu.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            menu.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            menu.widthAnchor.constraint(equalToConstant: 200),
            menu.heightAnchor.constraint(equalToConstant: 50),
            
            limitView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            limitView.leftAnchor.constraint(equalTo: view.leftAnchor),
            limitView.rightAnchor.constraint(equalTo: view.rightAnchor),
            limitView.heightAnchor.constraint(equalToConstant: 50)
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
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
        let asset = fetchResult.object(at: indexPath.item)
// case: is current preview
        if previousSelectedIndexPath == indexPath {
            if cell.hasActiveSelection {
                if selectedImages.count >= 5 {
                    limitView.isHidden = true
                }
                selectedImages.removeValue(forKey: indexPath.item)
                cell.toggleSelectionState()
            } else if selectedImages.count < 5 {
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.resizeMode = .fast
                PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 800, height: 1200), contentMode: .aspectFit, options: options) { image, _ in
                    if image != nil {
                        self.selectedImages[indexPath.item] = image
                        if self.selectedImages.count >= 5 {
                            self.limitView.isHidden = false
                        }
                    } else {
                        print("Error: CustomImagePickerController: didSelectItemAt: PHImageManager returned nil for image at cell \(indexPath.item)")
                    }
                }
                cell.toggleSelectionState()
            }
// case: is not current preview - only case that changes index path
        } else {
            if cell.hasActiveSelection {
                if selectedImages.count >= 5 {
                    limitView.isHidden = true
                }
                selectedImages.removeValue(forKey: indexPath.item)
                cell.toggleSelectionState()
            } else if selectedImages.count < 5 {
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.resizeMode = .fast
                PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 800, height: 1200), contentMode: .aspectFit, options: options) { image, _ in
                    if let image = image {
                        self.preview.image = image
                        self.selectedImages[indexPath.item] = image
                        if self.selectedImages.count >= 5 {
                            self.limitView.isHidden = false
                        }
                    } else {
                        print("Error: CustomImagePickerController: didSelectItemAt: PHImageManager returned nil for image at cell \(indexPath.item)")
                    }
                }
                previousSelectedIndexPath = indexPath
                cell.toggleSelectionState()
            }
        }
    }
    
    @objc func confirmPhotos(_ sender: UIButton) {
        guard let vc = destination as? NewLocationController else { return }
        vc.images = Array(selectedImages.values)
        navigationController?.popViewController(animated: true)
        vc.collectionView.reloadData()
    }
}

// MARK: Need to finish this
extension CustomImagePickerController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        //
    }
}
