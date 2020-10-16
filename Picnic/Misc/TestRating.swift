//
//  TestRating.swift
//  Picnic
//
//  Created by Kyle Burns on 10/15/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

open class TestRating: UIControl {
    static let config = UIImage.SymbolConfiguration(weight: .thin)
    
    public enum RatingMode {
        case interactable, display, displayWithCount
    }
    
    open var highlightColor: UIColor = .systemYellow
    open var defaultColor: UIColor = .darkWhite
    
    open var rating: Double = 0.0 {
        didSet {
            
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
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.isUserInteractionEnabled = false
        stackView.spacing = 2
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
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
            starView.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
            starView.widthAnchor.constraint(equalTo: starView.heightAnchor).isActive = true
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
        }) {
            for i in 0..<stars.count {
                stars[i].tintColor = i <= index ? highlightColor : defaultColor
            }
        }
        return false
    }
}
