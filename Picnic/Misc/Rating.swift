//
//  Rating.swift
//  Picnic
//
//  Created by Kyle Burns on 6/2/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

// will display rating and number of ratings with stars
protocol RatingDelegate: AnyObject {
    /**
     Notifies delegate of attempted rating change by the user. Delegate is responsible for validating this change
     - Parameters:
        - rating: The attempted new rating
     */
    func updateRating(value: Float)
}

// MARK: This really needs to be rewritten to capture the touch with a gesture recognizer and calculate the rating based on the position in the view
class Rating: UIView {
    
    enum Mode {
        case interactable, display, displayWithCount
    }

    var stars = [StarButton]()
    
    var starSize: CGFloat = StarButton.defaultStarSize
    var spacing: CGFloat = 1
    var rating: Float { Float(cgRating) }
    var width: CGFloat {
        5 * starSize + 4 * spacing
    }
    var ratingCountLabel: UILabel?
    var ratingCount: Int = 0
    private var cgRating: CGFloat = 0
    var style: StarButton.Style = .yellowFrame {
        didSet {
            switch style {
            case .grayFill:
                defaultColor = .darkWhite
                highlightcolor = .systemYellow
                stars.forEach { $0.style = .grayFill }
            case .yellowFrame:
                defaultColor = .systemYellow
                highlightcolor = .systemYellow
                stars.forEach { $0.style = .yellowFrame }
            }
        }
    }
    
    var mode: Mode = .displayWithCount {
        didSet {
            switch mode {
            case .interactable:
                isUserInteractionEnabled = true
                ratingCountLabel?.isHidden = true
            case .display:
                isUserInteractionEnabled = false
                ratingCountLabel?.isHidden = true
            case .displayWithCount:
                configureRatingCount()
                isUserInteractionEnabled = false
                ratingCountLabel?.isHidden = false
            }
        }
    }

    var highlightcolor: UIColor = .systemYellow {
        didSet {
            stars.forEach { $0.highlightcolor = highlightcolor }
        }
    }
    var defaultColor: UIColor = .darkWhite {
        didSet {
            stars.forEach { $0.defaultColor = defaultColor }
        }
    }
    
    weak var delegate: RatingDelegate?
    
// MARK: For rating
    init(rating: CGFloat = 0, starSize: CGFloat = StarButton.defaultStarSize, spacing: CGFloat = 1) {
        self.starSize = starSize
        self.spacing = spacing
        self.cgRating = rating
        super.init(frame: .zero)
        setup()
        refresh()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(picnic: Picnic) {
        cgRating = CGFloat(picnic.totalRating / Double(picnic.ratingCount))
        ratingCount = picnic.ratingCount
        if mode != .interactable { refresh() }
    }
    
// MARK: I don't like this
    private func configureRatingCount() {
        if ratingCountLabel != nil {
            let ratingString = ratingCount > 1000 ? String(format: "%.1fk", Float(ratingCount) / 1000.0) : String(ratingCount)
            ratingCountLabel!.text = "(" + ratingString + ")"
            return
        }
        
        ratingCountLabel = UILabel()
        var ratingString: String
        if ratingCount > 1000 {
            let reduced: Float = Float(ratingCount) / 1000.0
            ratingString = String(format: "%.1fk", reduced)
        } else {
            ratingString = "\(ratingCount)"
        }
        ratingCountLabel!.text = "(" + ratingString + ")"
        ratingCountLabel!.translatesAutoresizingMaskIntoConstraints = false
        ratingCountLabel!.textAlignment = .center
        ratingCountLabel!.textColor = .white
        addSubview(ratingCountLabel!)

        ratingCountLabel!.leadingAnchor.constraint(equalTo: stars.last!.trailingAnchor, constant: 5).isActive = true
        ratingCountLabel!.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func setup() {
        isUserInteractionEnabled = false
        for i in 0..<5 {
            let star = StarButton()
            star.configure(color: .systemYellow, size: starSize)
            star.translatesAutoresizingMaskIntoConstraints = false
            star.addTarget(self, action: #selector(starPress), for: .touchUpInside)
            addSubview(star)
            
            NSLayoutConstraint.activate([
                star.centerYAnchor.constraint(equalTo: centerYAnchor),
                star.leadingAnchor.constraint(equalTo: i == 0 ? leadingAnchor : stars.last!.trailingAnchor, constant: spacing),
                star.widthAnchor.constraint(equalToConstant: starSize),
                star.heightAnchor.constraint(equalToConstant: starSize)
            ])
            stars.append(star)
        }
    }
    
    private func refresh() {
        stars[0..<Int(cgRating)].forEach { $0.fill() }
        stars[Int(cgRating)..<stars.count].forEach { $0.reset() }
/*
         star symbol does not go edge to edge in the image. The image leaves a small amount on the left and right of the star. Additionally, the the very corners of the stars are imperceptible when applying a small mask. Accounting for these two things, approximately a translation of approximately 1/6 the image size is needed to create correct star behavior.
*/
        if floor(cgRating) != cgRating {
            let mask = starSize * CGFloat(cgRating.truncatingRemainder(dividingBy: 1.0) * 0.62 + 0.15)
            stars[Int(cgRating)].setMask(maskWidth: mask)
        }
    }
    
    func setRating(value: Float, incrementRatingCount: Bool = false) {
        cgRating = CGFloat(value)
        refresh()
        if incrementRatingCount { ratingCount += 1 }
    }

    @objc func starPress(_ sender: StarButton) {
        let rating = Float(stars.firstIndex(of: sender)!) + 1
        delegate?.updateRating(value: rating)
    }
}
