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
    func ratingDidUpdate(rating: CGFloat)
}
class Rating: UIView {
    
    enum Mode {
        case interactable, display, displayWithCount
    }

    var stars = [StarButton]()
    
    var starSize: CGFloat = StarButton.defaultStarSize
    var spacing: CGFloat = 1
    var rating: CGFloat = 0
    var width: CGFloat {
        5 * starSize + 4 * spacing
    }
    var picnic: Picnic!
    var ratingCountLabel: UILabel?
    var ratingCount: Int = 0
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
        self.rating = rating
        super.init(frame: .zero)
        setup()
        refresh()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func configure(picnic: Picnic) {
        self.picnic = picnic
        rating = CGFloat(picnic.rating)
        ratingCount = picnic.ratingCount
        if mode != .interactable { refresh() }
    }
    
    private func configureRatingCount() {
        guard let p = picnic else { return }
        if ratingCountLabel != nil {
            var ratingString: String
            if p.ratingCount > 1000 {
                let reduced: Float = Float(p.ratingCount) / 1000.0
                ratingString = String(format: "%.1fk", reduced)
            } else {
                ratingString = "\(p.ratingCount)"
            }
            ratingCountLabel!.text = "(" + ratingString + ")"
            return
        }
        
        ratingCountLabel = UILabel()
        var ratingString: String
        if p.ratingCount > 1000 {
            let reduced: Float = Float(p.ratingCount) / 1000.0
            ratingString = String(format: "%.1fk", reduced)
        } else {
            ratingString = "\(p.ratingCount)"
        }
        ratingCountLabel!.text = "(" + ratingString + ")"
        ratingCountLabel!.translatesAutoresizingMaskIntoConstraints = false
        ratingCountLabel!.textAlignment = .center
        ratingCountLabel!.textColor = .white
        addSubview(ratingCountLabel!)

        ratingCountLabel!.leadingAnchor.constraint(equalTo: stars.last!.trailingAnchor, constant: 5).isActive = true
        ratingCountLabel!.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func setup() {
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
        print(rating)
        stars[0..<Int(rating)].forEach { $0.fill() }
        stars[Int(rating)..<stars.count].forEach { $0.reset() }
        /* star symbol does not go edge to edge in the image. The image leaves a small amount on the left and right of the star. Additionally, the the very corners of the stars are imperceptible when applying a small mask. Accounting for these two things, approximately a translation of approximately 1/6 the image size is needed to create correct star behavior.*/
        if floor(rating) != rating {
            let mask = starSize * CGFloat(rating.truncatingRemainder(dividingBy: 1.0) * 0.62 + 0.15)
            stars[Int(rating)].setMask(maskWidth: mask)
        }
    }
    
    func update(rating: CGFloat) {
        self.rating = rating
        delegate?.ratingDidUpdate(rating: rating)
        refresh()
    }

    @objc func starPress(_ sender: StarButton) {
        let rating = Float(stars.firstIndex(of: sender)!) + 1
        update(rating: CGFloat(rating))
// MARK: need to verify here if user has rated this picnic already
        guard let p = picnic else { return }
        Shared.shared.user.isRated(post: p.id) { value in
            if value {
                Shared.shared.databaseManager.updateRating(picnic: p, rating: rating, increment: false)
            } else {
                Shared.shared.databaseManager.updateRating(picnic: p, rating: rating, increment: true) {
                    Shared.shared.user.ratePost(id: p.id) { err in
                        if let err = err {
                            print("Error: \(err.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
