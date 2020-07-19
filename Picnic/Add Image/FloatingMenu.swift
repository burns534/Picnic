//
//  FloatingMenu.swift
//  Picnic
//
//  Created by Kyle Burns on 7/18/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class FloatingMenu: UIView, UINavigationControllerDelegate {
    
    // would like to make this a sliding menu eventually probably
    
    // could be more general and make a list of buttons but...
    var cameraButton: UIButton!
    var extraButton: UIButton!
    var sender: CustomImagePickerController!
    var imagePickerController: UIImagePickerController!
    
    private enum CurrentSource {
        case library, camera
    }
    
    convenience init(sender: CustomImagePickerController) {
        self.init()
        self.sender = sender
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    func configure() {
        backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        
        cameraButton = UIButton()
        cameraButton.addTarget(self, action: #selector(cameraPress), for: .touchUpInside)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        let cameraImage = UIImage(systemName: "camera")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        cameraButton.setImage(cameraImage, for: .normal)
        addSubview(cameraButton)
        
        extraButton = UIButton()
        extraButton.addTarget(self, action: #selector(libraryPress), for: .touchUpInside)
        let photoImage = UIImage(systemName: "photo")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        extraButton.setImage(photoImage, for: .normal)
        extraButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(extraButton)
        
        imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        NSLayoutConstraint.activate([
            cameraButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            cameraButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            cameraButton.heightAnchor.constraint(equalToConstant: 40),
            
            extraButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            extraButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            extraButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func cameraPress(_ sender: UIButton) {
        if !cameraBlock {
            imagePickerController.sourceType = .camera
            imagePickerController.cameraDevice = .rear
            self.sender.present(imagePickerController, animated: true, completion: nil)
        } else {
            print("Error: Floating Menu: cameraPress: Cannot access camera")
        }
    }

    
    @objc func libraryPress(_ sender: UIButton) {
        // This doesn't actually make sense to have as a button..
    }
}

extension FloatingMenu: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            print("Error: Floating Menu: didFinishPickingMediaWithInfo: Could not load image")
            return
        }
        
        guard let dest = self.sender.destination as? NewLocationController else { print("Error: Floating Menu: didFinishPickingMediaWithInfo: Could not cast destination as NewLocationController")
            return
        }
        
        dest.images.append(image)
        dest.dismiss(animated: true, completion: nil)
    }
}
