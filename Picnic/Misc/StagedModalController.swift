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

open class StagedModalController: UIViewController {
    static let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
    static let checkmark = UIImage(systemName: "checkmark", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
    open var selectedView: Int = 0
    open var views: [UIView] = []
    open var offset: CGFloat = 0.0
    open var progressItemDefaultBackgroundColor = UIColor.darkWhite
    open var progressItemDefaultTextColor = UIColor.gray
    open var progressItemSelectedBackgroundColor = UIColor.organic
    open var progressItemSelectedTextColor = UIColor.white
    private let progressBar = UIStackView()
    private let nextButton = UIButton()
    private var progressItems: [UILabel] = []
    private let checkmarkView = UIImageView(image: checkmark)

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = progressItemSelectedTextColor
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.setShadow(radius: 5, color: progressItemDefaultTextColor, opacity: 0.6, offset: .zero)
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.alignment = .center
        progressBar.axis = .horizontal
        progressBar.distribution = .equalSpacing
        progressBar.spacing = 5
        let tgr = UITapGestureRecognizer(target: self, action: #selector(progressBarTap))
        progressBar.addGestureRecognizer(tgr)
        view.addSubview(progressBar)

        let exitButton = UIButton()
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: StagedModalController.config)?.withRenderingMode(.alwaysTemplate), for: .normal)
        exitButton.tintColor = .lightGray
        exitButton.addTarget(self, action: #selector(exit), for: .touchUpInside)
        view.addSubview(exitButton)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(progressItemSelectedTextColor, for: .normal)
        nextButton.backgroundColor = progressItemSelectedBackgroundColor
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
            nextButton.heightAnchor.constraint(equalTo: nextButton.widthAnchor, multiplier: 0.16)
        ])
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let height = keyboardFrame.cgRectValue.height
// MARK: custom equality relation for CGFloat required because of precision issues
            if view.frame.origin.y.isEqualTo(offset) {
                view.frame.origin.y -= height
            }
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        if !view.frame.origin.y.isEqualTo(offset) {
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
            initializeProgressBar()
        } else if views.count > 2 {
            newView.isHidden = true
            progressBar.addArrangedSubview(generateBar())
            let circle = generateCircle(views.count)
            progressBar.addArrangedSubview(circle)
            progressItems.append(circle)
        }
        
        NSLayoutConstraint.activate([
            newView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            newView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            newView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            newView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10)
        ])
    }
    
    func pushStage(_ newView: UIView) {
        newView.translatesAutoresizingMaskIntoConstraints = false
        views.first?.isHidden = true
        views.insert(newView, at: 0)
        view.addSubview(newView)
        if views.count == 2 {
            initializeProgressBar()
        } else if views.count > 2 {
            let circle = generateCircle(1)
            circle.textColor = progressItemSelectedTextColor
            circle.backgroundColor = progressItemSelectedBackgroundColor
            progressItems.first?.textColor = progressItemDefaultTextColor
            progressItems.first?.backgroundColor = progressItemDefaultBackgroundColor
            progressBar.insertArrangedSubview(generateBar(), at: 0)
            progressBar.insertArrangedSubview(circle, at: 0)
            progressItems.insert(circle, at: 0)
            for i in 0..<progressItems.count {
                progressItems[i].text = String(i + 1)
            }
        }
        
        NSLayoutConstraint.activate([
            newView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            newView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            newView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            newView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10)
        ])
    }
    
    func insertStage(_ newView: UIView, at index: Int) {
        newView.translatesAutoresizingMaskIntoConstraints = false
        if index == 0 { views.first?.isHidden = true }
        else { newView.isHidden = true }
        views.insert(newView, at: index)
        view.addSubview(newView)
        if views.count == 2 {
            initializeProgressBar()
        } else if views.count > 2 {
            let circle = generateCircle(index + 1)
            if index == 0 {
                progressItems.first?.textColor = progressItemDefaultTextColor
                progressItems.first?.backgroundColor = progressItemDefaultBackgroundColor
                circle.textColor = progressItemSelectedTextColor
                circle.backgroundColor = progressItemSelectedBackgroundColor
            } else {
                circle.textColor = progressItemDefaultTextColor
                circle.backgroundColor = progressItemDefaultBackgroundColor
            }
            progressBar.insertArrangedSubview(generateBar(), at: 2 * index)
            progressBar.insertArrangedSubview(circle, at: 2 * index)
            progressItems.insert(circle, at: index)
            for i in 0..<progressItems.count {
                progressItems[i].text = String(i + 1)
            }
        }
        
        NSLayoutConstraint.activate([
            newView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            newView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            newView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            newView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10)
        ])
    }
// TODO: Make last progressItem display a checkmark instead of number
    private func initializeProgressBar() {
        let circle0 = generateCircle(1)
        circle0.backgroundColor = progressItemSelectedBackgroundColor
        circle0.textColor = progressItemSelectedTextColor
        let circle1 = generateCircle(2)
        progressBar.addArrangedSubview(circle0)
        progressBar.addArrangedSubview(generateBar())
        progressBar.addArrangedSubview(circle1)
        progressItems.append(contentsOf: [circle0, circle1])
    }
    
    private func generateBar() -> UIView {
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = progressItemDefaultBackgroundColor
        bar.widthAnchor.constraint(equalToConstant: barSize).isActive = true
        bar.heightAnchor.constraint(equalToConstant: barWidth).isActive = true
        return bar
    }
    
    private func generateCircle(_ count: Int) -> UILabel {
        let circle = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: circleSize, height: circleSize)))
        circle.textAlignment = .center
        circle.textColor = progressItemDefaultTextColor
        circle.backgroundColor = progressItemDefaultBackgroundColor
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = circleSize / 2
        circle.clipsToBounds = true
        circle.text = String(count)
        circle.widthAnchor.constraint(equalToConstant: circleSize).isActive = true
        circle.heightAnchor.constraint(equalToConstant: circleSize).isActive = true
        return circle
    }
    
    @objc private func exit() {
        dismiss(animated: true)
        if selectedView != 0 {
            views[selectedView].isHidden = true
            progressItems[selectedView].backgroundColor = progressItemDefaultBackgroundColor
            progressItems[selectedView].textColor = progressItemDefaultTextColor
            selectedView = 0
            views[selectedView].isHidden = false
            progressItems[selectedView].backgroundColor = progressItemSelectedBackgroundColor
            progressItems[selectedView].textColor = progressItemSelectedTextColor
            nextButton.setTitle("Next", for: .normal)
        }
    }
    
    @objc func nextHandler() {
        if selectedView < views.count - 1 {
            views[selectedView].isHidden = true
            progressItems[selectedView].backgroundColor = progressItemDefaultBackgroundColor
            progressItems[selectedView].textColor = progressItemDefaultTextColor
            views[selectedView].resignFirstResponder()
            views[selectedView].endEditing(true)
            selectedView += 1
            views[selectedView].isHidden = false
            progressItems[selectedView].backgroundColor = progressItemSelectedBackgroundColor
            progressItems[selectedView].textColor = progressItemSelectedTextColor
            if selectedView == views.count - 1 {
                nextButton.setTitle("Confirm", for: .normal)
            }
        } else {
            exit()
            confirmationHandler()
        }
    }
    
    @objc func progressBarTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: progressBar)
        for (index, item) in progressItems.enumerated() {
            if item.frame.contains(location) {
                views[selectedView].isHidden = true
                progressItems[selectedView].textColor = progressItemDefaultTextColor
                progressItems[selectedView].backgroundColor = progressItemDefaultBackgroundColor
                selectedView = index
                views[index].isHidden = false
                progressItems[index].textColor = progressItemSelectedTextColor
                progressItems[index].backgroundColor = progressItemSelectedBackgroundColor
            }
        }
    }
    
    func confirmationHandler() { }

}
