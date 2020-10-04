//
//  StarView.swift
//  Picnic
//
//  Created by Kyle Burns on 6/10/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class StarButton: UIButton {
    
    enum Style {
        case grayFill, yellowFrame
    }
    
    static let defaultStarSize: CGFloat = 20
    
    var highlightcolor: UIColor = .systemYellow {
        didSet {
            full.tintColor = highlightcolor
        }
    }
    var defaultColor: UIColor = .darkWhite {
        didSet {
            empty.tintColor = defaultColor
        }
    }

    private var fullImage: UIImage? {
        didSet {
            full.image = fullImage
        }
    }
    private var emptyImage: UIImage? {
        didSet {
            empty.image = emptyImage
        }
    }
    
    var style: Style = .yellowFrame  {
        didSet {
            switch style {
            case .grayFill:
                highlightcolor = .systemYellow
                defaultColor = .darkWhite
                fullImage = UIImage(systemName: "star.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
                emptyImage = UIImage(systemName: "star.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
                
            case .yellowFrame:
                highlightcolor = .systemYellow
                defaultColor = .systemYellow
                fullImage = UIImage(systemName: "star.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
                emptyImage = UIImage(systemName: "star", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    var full: UIImageView!
    var empty: UIImageView!
    var starSize: CGFloat = defaultStarSize
    
    private var config: UIImage.SymbolConfiguration?
    private var pointSize: CGFloat {
        0.75 * starSize
    }
    
    func configure(color: UIColor, weight: UIImage.SymbolWeight = .light, size: CGFloat = defaultStarSize) {
        
        starSize = size
        
        empty = UIImageView()
        addSubview(empty)
        full = UIImageView()
        addSubview(full)
        
        config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        emptyImage = UIImage(systemName: "star", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        
        fullImage = UIImage(systemName: "star.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        
        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.tintColor = color
        }
        
        NSLayoutConstraint.activate([
            empty.centerXAnchor.constraint(equalTo: centerXAnchor),
            empty.centerYAnchor.constraint(equalTo: centerYAnchor),
            full.centerXAnchor.constraint(equalTo: centerXAnchor),
            full.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    func setMask(maskWidth: CGFloat) {
        self.full.isHidden = false
        self.empty.isHidden = false
        
        let maskLayer = CALayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: maskWidth, height: starSize)
        maskLayer.backgroundColor = UIColor.black.cgColor
        self.full.layer.mask = maskLayer
    }
    
    func fill() {
        self.full.isHidden = false
        self.full.layer.mask = nil
        self.empty.isHidden = true
    }

    func reset() {
        self.full.isHidden = true
        self.empty.isHidden = false
    }
}
