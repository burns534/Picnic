//
//  ProgressIndicator.swift
//  Picnic
//
//  Created by Kyle Burns on 8/5/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class ProgressIndicator: UIView {
    
    public enum State {
        case one, two, three, done
    }
    
    var barOne: UIView!
    var barTwo: UIView!
    var barThree: UIView!
    
    var circleOne: UIImageView!
    var circleTwo: UIImageView!
    var circleThree: UIImageView!
    var circleDone: UIImageView!
    
    var circles = [UIImageView]()
    var bars = [UIView]()
    
    var spacing: CGFloat = 1.0
    var circleToBarRatio: CGFloat = 1.2
    var width: CGFloat?
    
    var barWidth: CGFloat {
        guard let w = self.width else { return 0.0 }
        return (w - (8 * spacing)) / (4.0 * circleToBarRatio + 3.0)
    }
    
    var circleWidth: CGFloat {
        guard let w = self.width else { return 0.0 }
        return (w - (8 * spacing)) / (4 + 3 / circleToBarRatio)
    }
    
    private let circleWidthToPointSize: CGFloat = 1.15

    var pointSize: CGFloat {
        circleWidth / circleWidthToPointSize
    }
    
    func updateState(state: State) {
        switch state {
        case .one:
            reset()
            circleOne.tintColor = .olive
        case .two:
            reset()
            circleTwo.tintColor = .olive
        case .three:
            reset()
            circleThree.tintColor = .olive
        case .done:
            reset()
            circleDone.tintColor = .olive
        }
    }
    
    private func reset() {
        circles.forEach { $0.tintColor = .lightGray }
    }
    
    func configure(viewWidth: CGFloat) {
        width = viewWidth
        
        barOne = UIView()
        addSubview(barOne)
        
        barTwo = UIView()
        addSubview(barTwo)
        
        barThree = UIView()
        addSubview(barThree)
        
        let config = UIImage.SymbolConfiguration(pointSize: pointSize)
        
        let imageOne = UIImage(systemName: "1.circle.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        circleOne = UIImageView(image: imageOne)
        addSubview(circleOne)
        
        let imageTwo = UIImage(systemName: "2.circle.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        circleTwo = UIImageView(image: imageTwo)
        addSubview(circleTwo)
        
        let imageThree = UIImage(systemName: "3.circle.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        circleThree = UIImageView(image: imageThree)
        addSubview(circleThree)
        
        let imageDone = UIImage(systemName: "camera.circle.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        circleDone = UIImageView(image: imageDone)
        addSubview(circleDone)
        
        subviews.forEach {
            if let circle = $0 as? UIImageView {
                circles.append(circle)
                circle.tintColor = .lightGray
                circle.widthAnchor.constraint(equalToConstant: circleWidth).isActive = true
            } else {
                bars.append($0)
                $0.backgroundColor = .lightGray
                $0.widthAnchor.constraint(equalToConstant: barWidth).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 2).isActive = true
            }
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor).isActive = true
            $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
        
        circleOne.tintColor = .olive
        
        NSLayoutConstraint.activate([
            circleOne.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            circleOne.trailingAnchor.constraint(equalTo: barOne.leadingAnchor),
            barOne.trailingAnchor.constraint(equalTo: circleTwo.leadingAnchor, constant: -spacing),
            circleTwo.trailingAnchor.constraint(equalTo: barTwo.leadingAnchor, constant: -spacing),
            barTwo.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleThree.leadingAnchor.constraint(equalTo: barTwo.trailingAnchor, constant: spacing),
            barThree.leadingAnchor.constraint(equalTo: circleThree.trailingAnchor, constant: spacing),
            circleDone.leadingAnchor.constraint(equalTo: barThree.trailingAnchor, constant: spacing),
            circleDone.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }

}
