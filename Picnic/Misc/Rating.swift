//
//  Rating.swift
//  Picnic
//
//  Created by Kyle Burns on 10/15/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

fileprivate let heightToWidth: CGFloat = 0.17

open class Rating: UIControl {
    public static let config = UIImage.SymbolConfiguration(weight: .thin)
    static let starFill = UIImage(systemName: "star.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
    static let star = UIImage(systemName: "star", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
    
    public enum RatingMode {
        case interactable, display, displayWithCount
    }
    
    public enum Style: String {
        case wireframe = "star"
        case fill = "star.fill"
        var backImage: UIImage? {
            switch self {
            case .fill:
                return starFill
            case .wireframe:
                return star
            }
        }
        
        var frontImage: UIImage? {
            switch self {
            case .fill:
                return starFill
            case .wireframe:
                return starFill
            }
        }
    }
    
    open var highlightColor: UIColor = .systemYellow
    open var defaultColor: UIColor = .darkWhite
    open var rating: Double = 0.0 {
        didSet {
            refactorStars(rating: rating)
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
    
    open var style: Style = .fill {
        didSet {
            switch style {
            case .fill: defaultColor = .darkWhite
            case .wireframe: defaultColor = .systemYellow
            }
            refactorStars(rating: rating)
        }
    }
    
    private var stars = [StarImage]()
    private let ratingCountLabel = UILabel()
    private let stackView = UIStackView()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.isUserInteractionEnabled = false
        stackView.spacing = 2
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: widthAnchor, multiplier: heightToWidth),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        for _ in 0..<5 {
            let starView = StarImage(frame: CGRect(origin: .zero, size: bounds.size))
            starView.backgroundColor = .clear
            starView.tintColor = defaultColor
            starView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(starView)
            stars.append(starView)
            starView.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
            starView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
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
        if let index = stars.firstIndex(where: { $0.bounds.contains(touch.location(in: $0))
        }) { rating = Double(index + 1) }
        sendActions(for: .valueChanged)
        return false
    }

    private func refactorStars(rating: Double) {
        let intRating = Int(floor(rating))
        stars[0..<intRating].forEach {
            $0.tintColor = highlightColor
            $0.image = style.frontImage
            $0.removeOverlay()
        }
        stars[intRating..<stars.count].forEach {
            $0.tintColor = defaultColor
            $0.image = style.backImage
            $0.removeOverlay()
        }
        if mode != .interactable {
            if rating.rounded() != rating {
                let ratio = CGFloat(rating - floor(rating))
                stars[intRating].setOverlay(image: style.frontImage, ratio: ratio)
            }
        }
    }
}
