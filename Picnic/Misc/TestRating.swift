//
//  TestRating.swift
//  Picnic
//
//  Created by Kyle Burns on 10/15/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

open class Rating: UIControl {
    static let config = UIImage.SymbolConfiguration(weight: .thin)
    
    public enum RatingMode {
        case interactable, display, displayWithCount
    }
    
    open var highlightColor: UIColor = .systemYellow
    open var defaultColor: UIColor = .darkWhite
    
    open var rating: Double = 0.0 {
        didSet {
            let intRating = Int(rating)
            stars.forEach { $0.layer.mask = nil }
            stars[0..<intRating].forEach { $0.tintColor = .systemYellow }
            stars[intRating..<stars.count].forEach { $0.tintColor = .darkWhite }
            if mode != .interactable {
                if rating.rounded() != rating {
                    let percent = CGFloat(rating - rating.rounded())
                    let starFrame = stars[intRating].frame
                    let mask = CALayer()
                    mask.backgroundColor = UIColor.black.cgColor
                    mask.frame = CGRect(x: starFrame.width * percent, y: 0, width: starFrame.width * (1 - percent), height: starFrame.height)
                    stars[intRating].layer.mask = mask
                }
            }
        }
    }
    
    open var ratingCount: Int = 0 {
        didSet {
            ratingCountLabel.text = ratingCount > 1000 ? String(format: "(%.1fk)", Float(ratingCount) / 1000.0) : String(format: "(%d)", ratingCount)
        }
    }
    
    open var mode: RatingMode = .display {
        didSet {
            isUserInteractionEnabled = mode == .interactable
            if mode == .displayWithCount {
                stackView.addArrangedSubview(ratingCountLabel)
            } else {
                stackView.removeArrangedSubview(ratingCountLabel)
            }
        }
    }
    
    private var stars = [UIImageView]()
    private let starImage = UIImage(systemName: "star.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
    private let ratingCountLabel = UILabel()
    private let stackView = UIStackView()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSubviews() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.isUserInteractionEnabled = false
        stackView.spacing = 2
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.18),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        for _ in 0..<5 {
            let starView = UIImageView(image: starImage)
            starView.tintColor = defaultColor
            starView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(starView)
            stars.append(starView)
        }
        
        ratingCountLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingCountLabel.adjustsFontSizeToFitWidth = true
        ratingCountLabel.minimumScaleFactor = 0.3
        ratingCountLabel.textAlignment = .center
        ratingCountLabel.textColor = .white
        stackView.addArrangedSubview(ratingCountLabel)
    }
    
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        sendActions(for: .valueChanged)
        
        if let index = stars.firstIndex(where: { $0.bounds.contains(touch.location(in: $0))
        }) { rating = Double(index + 1) }
        return false
    }
}
