//
//  RequiredFieldModal.swift
//  Picnic
//
//  Created by Kyle Burns on 8/5/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

fileprivate let imageSize: CGSize = CGSize(width: 102, height: 102)

fileprivate let labelTopMargin: CGFloat = 30

fileprivate let fieldTopMargin: CGFloat = 30

protocol RequiredFieldModalDelegate: AnyObject {
    func update(rating: CGFloat)
    func update(name: String)
    func update(description: String)
    func update(images: [UIImage])
}

class RequiredFieldModal: UIViewController {
    
    var nameInstructions: UILabel!
    var nameField: PaddedTextField!
    var ratingInstructions: UILabel!
    var rating: Rating!
    var descriptionInstructions: UILabel!
    var userDescription: PaddedTextField!
    var imageLabel: UILabel!
    var imageSelection: MultipleSelectionIcon!
    var progressIndicator: ProgressIndicator!
    var imagePicker: CustomImagePickerController!
    var confirmButton: UIButton!
    var modalOffsetY: CGFloat?
    
    private var state: ProgressIndicator.State = .one
    
    weak var delegate: RequiredFieldModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.setShadow(radius: 5, color: .darkGray, opacity: 0.6, offset: .zero)
        
        let layout = CustomPickerFlowLayout(itemSize: imageSize, scrollDirection: .vertical, minimumLineSpacing: 1, sectionInset: .zero, minimumInteritemSpacing: 0)
        imagePicker = CustomImagePickerController(collectionViewLayout: layout)
        imagePicker.delegate = self
        
        progressIndicator = ProgressIndicator()
        progressIndicator.configure(viewWidth: 200)
        view.addSubview(progressIndicator)
        
        confirmButton = UIButton()
        confirmButton.setTitle("Next", for: .normal)
        confirmButton.backgroundColor = .lightGray
        confirmButton.layer.cornerRadius = 30
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        view.addSubview(confirmButton)
        
        imageLabel = UILabel()
        imageLabel.text = "Add some photos"
        imageLabel.textAlignment = .center
        imageLabel.font = UIFont.systemFont(ofSize: 25, weight: .light)
        imageLabel.isHidden = true
        view.addSubview(imageLabel)
        
        imageSelection = MultipleSelectionIcon()
        imageSelection.isHidden = true
        imageSelection.backgroundColor = .darkWhite
        imageSelection.layer.cornerRadius = 5
        imageSelection.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        view.addSubview(imageSelection)
        
        descriptionInstructions = UILabel()
        descriptionInstructions.text = "Give a description for other users"
        descriptionInstructions.textAlignment = .center
        descriptionInstructions.font = UIFont.systemFont(ofSize: 25, weight: .light)
        descriptionInstructions.isHidden = true
        view.addSubview(descriptionInstructions)
        
        userDescription = PaddedTextField()
        userDescription.setPadding(.standard)
        userDescription.backgroundColor = .darkWhite
        userDescription.layer.cornerRadius = 10
        userDescription.contentVerticalAlignment = .top
        userDescription.placeholder = "Try to keep it short"
        userDescription.isHidden = true
        userDescription.delegate = self
        userDescription.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.addSubview(userDescription)
        
        ratingInstructions = UILabel()
        ratingInstructions.text = "What did you think?"
        ratingInstructions.textAlignment = .center
        ratingInstructions.font = UIFont.systemFont(ofSize: 25, weight: .light)
        ratingInstructions.isHidden = true
        view.addSubview(ratingInstructions)
        
        rating = Rating(starSize: 60)
        rating.mode = .interactable
        rating.style = .grayFill
        rating.delegate = self
        rating.isHidden = true
        view.addSubview(rating)
// The two need to be at the top of the view stack
        nameInstructions = UILabel()
        nameInstructions.text = "Give this picnic a name"
        nameInstructions.textAlignment = .center
        nameInstructions.font = UIFont.systemFont(ofSize: 25, weight: .light)
        view.addSubview(nameInstructions)
        
        nameField = PaddedTextField()
        nameField.setPadding(.standard)
        nameField.backgroundColor = .darkWhite
        nameField.layer.cornerRadius = 10
        nameField.textAlignment = .center
        nameField.placeholder = "Something recognizable"
        nameField.delegate = self
        nameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.addSubview(nameField)
        
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressIndicator.heightAnchor.constraint(equalToConstant: 40),
            progressIndicator.widthAnchor.constraint(equalToConstant: 200),
            progressIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            confirmButton.widthAnchor.constraint(equalToConstant: 350),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
            
            ratingInstructions.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ratingInstructions.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: labelTopMargin),
            ratingInstructions.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
            ratingInstructions.heightAnchor.constraint(equalToConstant: 40),
            
            rating.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rating.topAnchor.constraint(equalTo: ratingInstructions.bottomAnchor, constant: fieldTopMargin),
            rating.widthAnchor.constraint(equalToConstant: rating.width),
            rating.heightAnchor.constraint(equalToConstant: rating.starSize),
            
            nameInstructions.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameInstructions.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: labelTopMargin),
            nameInstructions.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
            nameInstructions.heightAnchor.constraint(equalToConstant: 40),
            
            nameField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameField.topAnchor.constraint(equalTo: nameInstructions.bottomAnchor, constant: fieldTopMargin),
            nameField.widthAnchor.constraint(equalToConstant: 300)
            ])
        
        NSLayoutConstraint.activate([
            descriptionInstructions.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionInstructions.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: labelTopMargin),
            descriptionInstructions.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
            descriptionInstructions.heightAnchor.constraint(equalToConstant: 40),
            
            userDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userDescription.topAnchor.constraint(equalTo: descriptionInstructions.bottomAnchor, constant: fieldTopMargin),
            userDescription.heightAnchor.constraint(equalToConstant: 100),
            userDescription.widthAnchor.constraint(equalToConstant: 380),
            
            imageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageLabel.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: labelTopMargin * 0.3),
            imageLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
            imageLabel.heightAnchor.constraint(equalToConstant: 30),
            
            imageSelection.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageSelection.topAnchor.constraint(equalTo: imageLabel.bottomAnchor, constant: fieldTopMargin * 0.3),
            imageSelection.widthAnchor.constraint(equalToConstant: 160),
            imageSelection.heightAnchor.constraint(equalTo: imageSelection.widthAnchor)
        ])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        guard let offset = modalOffsetY else { return }
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let height = keyboardFrame.cgRectValue.height
            if view.frame.origin.y == offset {
                view.frame.origin.y -= height
            }
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        guard let offset = modalOffsetY else { return }
        if view.frame.origin.y != offset {
            view.frame.origin.y = offset
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text != "" && confirmButton.backgroundColor == .lightGray {
            confirmButton.backgroundColor = .olive
        } else if text == "" && confirmButton.backgroundColor == .olive {
                confirmButton.backgroundColor = .lightGray
        }
    }
    
    @objc func presentImagePicker(_ sender: UIButton) {
        present(imagePicker, animated: true)
    }
    
    func updateState() {
        switch state {
        case .one:
            if nameField.text! == "" { print("it's empty"); return } // present warning
            state = .two
            delegate?.update(name: nameField.text!)
            nameField.isHidden = true
            nameInstructions.isHidden = true
            view.sendSubviewToBack(nameField)
            view.sendSubviewToBack(nameInstructions)
            rating.isHidden = false
            ratingInstructions.isHidden = false
            confirmButton.backgroundColor = .lightGray
            resignFirstResponder()
            view.endEditing(true)
        case .two:
            if rating.rating == 0 { return }
            state = .three
            delegate?.update(rating: rating.rating)
            rating.isHidden = true
            ratingInstructions.isHidden = true
            view.sendSubviewToBack(rating)
            view.sendSubviewToBack(ratingInstructions)
            userDescription.isHidden = false
            descriptionInstructions.isHidden = false
        case .three:
            state = .done
            delegate?.update(description: userDescription.text!)
            confirmButton.titleLabel?.text = "Confirm"
            userDescription.isHidden = true
            descriptionInstructions.isHidden = true
            view.sendSubviewToBack(userDescription)
            view.sendSubviewToBack(descriptionInstructions)
            imageSelection.isHidden = false
            imageLabel.isHidden = false
            resignFirstResponder()
            view.endEditing(true)
        case .done:
            state = .one
            confirmButton.titleLabel?.text = "Next"
            imageSelection.isHidden = true
            imageLabel.isHidden = true
            view.sendSubviewToBack(imageSelection)
            view.sendSubviewToBack(imageLabel)
            dismiss(animated: true)
            state = .one
            rating.isHidden = false
            ratingInstructions.isHidden = false
        }
        progressIndicator.updateState(state: state)
    }
    
    @objc func confirm(_ sender: UIButton) {
        updateState()
    }
}

extension RequiredFieldModal: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        view.endEditing(true)
        return true
    }
}

extension RequiredFieldModal: RatingDelegate {
    func ratingDidUpdate(rating: CGFloat) {
        confirmButton.backgroundColor = .olive
    }
}

extension RequiredFieldModal: CustomImagePickerControllerDelegate {
    func refreshImageSource(images: [UIImage]) {
        delegate?.update(images: images)
        imageSelection.isMultipleSelection = images.count > 1 ? true : false
        imageSelection.setImage(images.first, for: .normal)
    }
}
