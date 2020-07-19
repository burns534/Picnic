//
//  AddImage.swift
//  Picnic
//
//  Created by Kyle Burns on 5/26/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

#if targetEnvironment(simulator)
    let cameraBlock = true
#else
    let cameraBlock = false
#endif

fileprivate let imageSize: CGSize = CGSize(width: 102, height: 102)

class AddImage: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var vc: UIImagePickerController!
    
    let customPickerFlowLayout = CustomPickerFlowLayout(itemSize: imageSize, scrollDirection: .vertical, minimumLineSpacing: 1, sectionInset: .zero, minimumInteritemSpacing: 0)
    var customPicker: CustomImagePickerController
    
    var camera: UIButton!
    
    var photoLibrary: UIButton!
    
    var sender: NewLocationController
    
    init(sender: NewLocationController) {
        self.sender = sender
        customPicker = CustomImagePickerController(collectionViewLayout: customPickerFlowLayout)
        super.init(nibName: nil, bundle: nil)
        customPicker.destination = sender
        title = "Add Photos"
        tabBarItem.image = UIImage(systemName: "camera")
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tabBarController?.title = "Add Photos"
        // Do any additional setup after loading the view.
        vc = UIImagePickerController()
        vc.allowsEditing = true
        vc.delegate = self
        
        camera = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        camera.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        camera.setTitle("From Library", for: .normal)
        camera.setTitleColor(.systemBlue, for: .normal)
        camera.addTarget(self, action: #selector(photoLibPress), for: .touchUpInside)
        view.addSubview(camera)
        
        photoLibrary = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        photoLibrary.center = CGPoint(x: view.center.x, y: view.center.y + 50)
        photoLibrary.setTitle("From Camera", for: .normal)
        photoLibrary.setTitleColor(.systemBlue, for: .normal)
        photoLibrary.addTarget(self, action: #selector(cameraPress), for: .touchUpInside)
        view.addSubview(photoLibrary)
        
    }
    
    @objc func cameraPress(_ sender: UIButton) {
        if !cameraBlock {
            vc.sourceType = .camera
            vc.cameraDevice = .rear
            present(vc, animated: true, completion: nil)
        } else {
            print("Error: AddImage: cameraPress: Cannot access camera in simulator/debug mode")
        }
    }
    
    @objc func photoLibPress(_ sender: UIButton) {
        vc.sourceType = .photoLibrary
        present(customPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("Error: Could not load image")
            return
        }
        sender.images.append(image)
        navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
