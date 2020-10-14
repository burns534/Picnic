//
//  StagedModalController.swift
//  Picnic
//
//  Created by Kyle Burns on 10/12/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

private let circleSize: CGFloat = 30
private let barSize: CGFloat = 20
private let barWidth: CGFloat = 3

protocol StagedModalControllerDelegate: AnyObject {
    func complete()
}

class StagedModalController: UIViewController {
    
    var selectedView: Int = 0
    var views: [UIView] = []
    var offset: CGFloat = 0.0
    private let progressBar = UIStackView()
    private let nextButton = UIButton()
    private var progressItems: [UILabel] = []
    
    weak var delegate: StagedModalControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.setShadow(radius: 5, color: .gray, opacity: 0.6, offset: .zero)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.alignment = .center
        progressBar.axis = .horizontal
        progressBar.distribution = .equalSpacing
        progressBar.spacing = 5
        view.addSubview(progressBar)

        let exitButton = UIButton()
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .thin))?.withRenderingMode(.alwaysTemplate), for: .normal)
        exitButton.tintColor = .lightGray
        exitButton.addTarget(self, action: #selector(exit), for: .touchUpInside)
        view.addSubview(exitButton)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = .olive
        nextButton.addTarget(self, action: #selector(nextHandler), for: .touchUpInside)
        nextButton.clipsToBounds = true
        nextButton.layer.cornerRadius = 5
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            exitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            progressBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: circleSize),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let height = keyboardFrame.cgRectValue.height
            if view.frame.origin.y == offset {
                view.frame.origin.y -= height
            }
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        if view.frame.origin.y != offset {
            view.frame.origin.y = offset
        }
    }
    
    func configure(stages: [UIView]) {
        stages.forEach { self.addStage($0) }
    }
/*
     Should be fine for the time being. Could be better
     
*/
    func addStage(_ newView: UIView) {
        views.append(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newView)
        if views.count == 2 {
            newView.isHidden = true
            let circles = [
                UILabel(frame: CGRect(origin: .zero, size: CGSize(width: circleSize, height: circleSize))),
                UILabel(frame: CGRect(origin: .zero, size: CGSize(width: circleSize, height: circleSize)))
                ]
            circles[0].text = "\(1)"
            circles[1].text = "\(2)"
            circles.forEach { circle in
                circle.textAlignment = .center
                circle.textColor = .gray
                circle.backgroundColor = .darkWhite
                circle.translatesAutoresizingMaskIntoConstraints = false
                circle.layer.cornerRadius = circleSize / 2
                circle.clipsToBounds = true
                circle.setShadow(radius: 5, color: .lightGray, opacity: 0.6, xOffset: 5)
                circle.widthAnchor.constraint(equalToConstant: circleSize).isActive = true
                circle.heightAnchor.constraint(equalToConstant: circleSize).isActive = true
            }
            progressBar.addArrangedSubview(circles[0])
            let bar = UIView()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.backgroundColor = .darkWhite
            bar.widthAnchor.constraint(equalToConstant: barSize).isActive = true
            bar.heightAnchor.constraint(equalToConstant: barWidth).isActive = true
            progressBar.addArrangedSubview(bar)
            progressBar.addArrangedSubview(circles[1])
            progressItems.append(contentsOf: circles)
            
        }
        
        if views.count > 3 {
            let bar = UIView()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.backgroundColor = .darkWhite
            bar.widthAnchor.constraint(equalToConstant: barSize).isActive = true
            bar.heightAnchor.constraint(equalToConstant: barWidth).isActive = true
            progressBar.addArrangedSubview(bar)
        
            let circle = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: circleSize, height: circleSize)))
            circle.textAlignment = .center
            circle.textColor = .gray
            circle.backgroundColor = .darkWhite
            circle.text = "\(views.count)"
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.layer.cornerRadius = circleSize / 2
            circle.clipsToBounds = true
            circle.setShadow(radius: 5, color: .lightGray, opacity: 0.6, xOffset: 5)
            circle.widthAnchor.constraint(equalToConstant: circleSize).isActive = true
            circle.heightAnchor.constraint(equalToConstant: circleSize).isActive = true
            
            progressBar.addArrangedSubview(circle)
            progressItems.append(circle)
        
        }
        
        NSLayoutConstraint.activate([
            newView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            newView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            newView.bottomAnchor.constraint(lessThanOrEqualTo: nextButton.topAnchor, constant: -10),
            newView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    @objc func exit() {
        dismiss(animated: true)
        if selectedView != 0 {
            views[selectedView].isHidden = true
            progressItems[selectedView].backgroundColor = .darkWhite
            progressItems[selectedView].textColor = .lightGray
            selectedView = 0
            views[selectedView].isHidden = false
            progressItems[selectedView].backgroundColor = .olive
            progressItems[selectedView].textColor = .white
            nextButton.setTitle("Next", for: .normal)
        }
    }
    
    @objc func nextHandler() {
        if selectedView < views.count - 1 {
            views[selectedView].isHidden = true
            progressItems[selectedView].backgroundColor = .darkWhite
            progressItems[selectedView].textColor = .lightGray
            selectedView += 1
            views[selectedView].isHidden = false
            progressItems[selectedView].backgroundColor = .olive
            progressItems[selectedView].textColor = .white
            if selectedView == views.count - 1 {
                nextButton.setTitle("Submit", for: .normal)
            }
        } else {
            delegate?.complete()
            exit()
        }
    }

}
