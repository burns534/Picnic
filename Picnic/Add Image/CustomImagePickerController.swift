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

// MARK: There is a bug with previews being blurry - not loading the requested image, only the cached image

class CustomImagePickerController: UICollectionViewController {
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    var preview: ZoomableImage!
    var selectedImages = [UIImage]()
    var sourceButton: UIButton!
    var destination: UIViewController!
    var menu: FloatingMenu!
    var counter: Int16 = 0
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate let previewManager = PHImageManager()
    
    var availableWidth: CGFloat = 0
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect: CGRect = .zero
    private var previousPreviewIndexPath: IndexPath = .init(item: 0, section: 0)
    
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(ImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // Do any additional setup after loading the view.
        configurePhotos()
        setup()
    }

    // MARK: This will be used in a parent tableView controller to send the fetch
    func configurePhotos() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        PHPhotoLibrary.shared().register(self)
        
        if self.fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            self.fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
    }
    
    func setup() {
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        
        view.backgroundColor = .white
        
        let asset = fetchResult.object(at: 0)
        preview = ZoomableImage(frame: previewFrame)
        previewManager.requestImage(for: asset, targetSize: CGSize(width: 1200, height: 1800), contentMode: .aspectFit, options: nil) { image, _ in
            if let _ = image {
                self.preview.image = image
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
            menu.heightAnchor.constraint(equalToConstant: 50)
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
    
    // need segue handler
    
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
        cell.toggleSelectionImage()
        counter = 0
        if cell.toggle {
            if indexPath != previousPreviewIndexPath {
                previewManager.requestImage(for: asset, targetSize: CGSize(width: 1200, height: 1800), contentMode: .aspectFit, options: nil) { image, _ in
                    if let image = image {
                        self.preview.image = image
                        if self.counter == 1 {
                            self.selectedImages.removeLast()
                        }
                        self.selectedImages.append(image)
                        self.counter += 1
                    }
                }
                previousPreviewIndexPath = indexPath
            }
        } else {
            selectedImages.removeAll(where: { $0 == cell.imageView.image! })
        }
    }
    
    @objc func confirmPhotos(_ sender: UIButton) {
        guard let vc = destination as? NewLocationController else { return }
        vc.images = selectedImages
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
