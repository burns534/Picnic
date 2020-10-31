//
//  FilterController.swift
//  Picnic
//
//  Created by Kyle Burns on 10/10/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//
// TODO: Add tags to reviews
import UIKit
/**
    Measured in Kilometers
 */
let kDefaultQueryRadius: Double = 100.0
let kDefaultQueryLimit: Int = 50

protocol FilterControllerDelegate: AnyObject {
    func filterChange()
}

class FilterController: UIViewController {
    let radiusSlider = UISlider()
    let interactiveRating = Rating(frame: .zero)
    let sliderValueLabel = UILabel()
    let navigationBar = NavigationBar()
    let tagView = TagView(tags: PicnicTag.allCases)
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
        radiusSlider.addTarget(self, action: #selector(radiusSet), for: .editingDidEnd)
        sliderValueLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderValueLabel.font = UIFont.systemFont(ofSize: 20, weight: .light)
        sliderValueLabel.text = String(format: "%d miles", Int(radiusSlider.value))
        
        interactiveRating.translatesAutoresizingMaskIntoConstraints = false
        interactiveRating.style = .fill
        interactiveRating.mode = .interactable
        interactiveRating.addTarget(self, action: #selector(ratingChange), for: .valueChanged)
        
        tagView.mode = .selection
        tagView.selectionDelegate = self
        tagView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(navigationBar)
        view.addSubview(sliderValueLabel)
        view.addSubview(radiusSlider)
        view.addSubview(interactiveRating)
        view.addSubview(tagView)
        
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
            interactiveRating.widthAnchor.constraint(equalTo: radiusSlider.widthAnchor, multiplier: 0.8),
            
            tagView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tagView.topAnchor.constraint(equalTo: interactiveRating.bottomAnchor, constant: 10),
            tagView.leadingAnchor.constraint(equalTo: radiusSlider.leadingAnchor),
            tagView.trailingAnchor.constraint(equalTo: radiusSlider.trailingAnchor)
        ])
    }
    
    private func roundToTens(_ x : Float) -> Double {
        Double(10 * (x / 10.0).rounded())
    }
    
    @objc func exit(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func reset(_ sender: UIButton) {
        radiusSlider.value = Float(kDefaultQueryRadius)
        sliderValueLabel.text = String(format: "%d miles", Int(radiusSlider.value))
        PicnicManager.default.picnicQuery("Picnics")?.reset()
        delegate?.filterChange()
    }

    @objc func radiusChange(_ sender: UISlider) {
        sliderValueLabel.text = String(format: "%.0f miles", roundToTens(sender.value))
    }
    
    @objc func radiusSet(_ sender: UISlider) {
        PicnicManager.default.picnicQuery("Picnics")?.setRadius(radius: Double(sender.value))
        delegate?.filterChange()
    }
    
    @objc func ratingChange(_ sender: Rating) {
        PicnicManager.default.picnicQuery("Picnics")?.setRating(rating: sender.rating)
        delegate?.filterChange()
    }
}

extension FilterController: TagViewSelectionDelegate {
    func didSelectTag(tags: [PicnicTag], at indexPath: IndexPath) {
        PicnicManager.default.picnicQuery("Picnics")?.setTags(tags: tags)
        delegate?.filterChange()
    }
    
    func didDeslectTag(tags: [PicnicTag], at indexPath: IndexPath) {
        PicnicManager.default.picnicQuery("Picnics")?.setTags(tags: tags)
        delegate?.filterChange()
    }
}
