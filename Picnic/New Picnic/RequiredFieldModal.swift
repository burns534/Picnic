//
//  RequiredFieldModal.swift
//  Picnic
//
//  Created by Kyle Burns on 8/5/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

protocol RequiredFieldModalDelegate: AnyObject {
    func update(rating: CGFloat)
    func update(name: String)
    func update(description: String)
}

class RequiredFieldModal: UIViewController {
    
    var nameInstructions: UILabel!
    var nameField: UITextField!
    
    var ratingInstructions: UILabel!
    var rating: Rating!
    
    var descriptionInstructions: UILabel!
    var userDescription: UITextField!
    
    var progressIndicator: ProgressIndicator!
    
    var confirmButton: UIButton!
    private var state: ProgressIndicator.State = .one
    
    weak var delegate: RequiredFieldModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .darkWhite
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.setShadow(radius: 5, color: .darkGray, opacity: 0.6, offset: .zero)
        
        progressIndicator = ProgressIndicator()
        progressIndicator.configure(viewWidth: 200)
        view.addSubview(progressIndicator)
        
        confirmButton = UIButton()
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.backgroundColor = .olive
        confirmButton.layer.cornerRadius = 30
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        view.addSubview(confirmButton)
        
        rating = Rating()
        
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressIndicator.heightAnchor.constraint(equalToConstant: 40),
            progressIndicator.widthAnchor.constraint(equalToConstant: 200),
            progressIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            confirmButton.widthAnchor.constraint(equalToConstant: 250),
            confirmButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    @objc func confirm(_ sender: UIButton) {
        switch state {
        case .one:
            state = .two
            delegate?.update(rating: rating.rating)
        case .two:
            state = .three
            delegate?.update(name: nameField.text!)
        case .three:
            state = .done
            delegate?.update(description: userDescription.text!)
        case .done:
            state = .completed
            dismiss(animated: true)
        default:
            return
        }
        progressIndicator.updateState(state: state)
    }
}
