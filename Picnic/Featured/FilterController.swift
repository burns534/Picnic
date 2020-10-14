//
//  FilterController.swift
//  Picnic
//
//  Created by Kyle Burns on 10/10/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
/**
    Measured in Kilometers
 */
let kDefaultQueryRadius: Double = 20.0
let kDefaultQueryLimit: Int = 50

protocol FilterControllerDelegate: AnyObject {
    func refreshDataSource(picnics: [Picnic])
}

class FilterController: UIViewController {
    let radiusSlider = UISlider()
    let interactiveRating = Rating(starSize: 60)
    let sliderValueLabel = UILabel()
    let navigationBar = NavigationBar()
    weak var delegate: FilterControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        isModalInPresentation = true
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.setTitle(text: "Filter")
        let exitButton = UIButton()
        exitButton.addTarget(self, action: #selector(exit), for: .touchUpInside)
        exitButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .thin))?.withRenderingMode(.alwaysTemplate), for: .normal)
        exitButton.tintColor = .black
        let resetButton = UIButton()
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        resetButton.setTitle("reset", for: .normal)
        resetButton.setTitleColor(.black, for: .normal)
        navigationBar.setLeftBarButton(button: exitButton)
        navigationBar.setRightBarButton(button: resetButton)
        
        radiusSlider.translatesAutoresizingMaskIntoConstraints = false
        radiusSlider.minimumTrackTintColor = .olive
        radiusSlider.minimumValue = 0.0
        radiusSlider.maximumValue = 200.0
        radiusSlider.value = Float(kDefaultQueryRadius)
        radiusSlider.addTarget(self, action: #selector(radiusChange), for: .valueChanged)
        sliderValueLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderValueLabel.font = UIFont.systemFont(ofSize: 20, weight: .light)
        sliderValueLabel.text = String(Int(radiusSlider.value))
        
        interactiveRating.translatesAutoresizingMaskIntoConstraints = false
        interactiveRating.mode = .interactable
        interactiveRating.style = .grayFill

        view.addSubview(navigationBar)
        view.addSubview(sliderValueLabel)
        view.addSubview(radiusSlider)
        view.addSubview(interactiveRating)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 60),
            
            sliderValueLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 100),
            sliderValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            radiusSlider.topAnchor.constraint(equalTo: sliderValueLabel.bottomAnchor),
            radiusSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            radiusSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            radiusSlider.heightAnchor.constraint(equalToConstant: 50),
            
            interactiveRating.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            interactiveRating.topAnchor.constraint(equalTo: radiusSlider.bottomAnchor, constant: 10),
            interactiveRating.widthAnchor.constraint(equalToConstant: interactiveRating.width),
            interactiveRating.heightAnchor.constraint(equalToConstant: interactiveRating.starSize)
        ])
    }
    
    private func roundToTens(_ x : Double) -> Double {
        10 * (x / 10.0).rounded()
    }
    
    @objc func exit(_ sender: UIButton) {
        guard let location = Managers.shared.locationManager.location else { return }
        Managers.shared.databaseManager.removeQuery("Picnics")
        Managers.shared.databaseManager.addPicnicQuery(location: location, limit: kDefaultQueryLimit, radius: roundToTens(Double(radiusSlider.value * 1.609)), key: "Picnics")
        Managers.shared.databaseManager.nextPage(forPicnicQueryKey: "Picnics") { picnics in
            self.delegate?.refreshDataSource(picnics: picnics)
            self.dismiss(animated: true)
        }
    }
    
    @objc func reset(_ sender: UIButton) {
        radiusSlider.value = Float(kDefaultQueryRadius)
    }

    @objc func radiusChange(_ sender: UISlider) {
        sliderValueLabel.text = String(format: "%.0f", roundToTens(Double(sender.value)))
    }

}
