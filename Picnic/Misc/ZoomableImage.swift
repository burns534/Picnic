//
//  ZoomableImage.swift
//  Picnic
//
//  Created by Kyle Burns on 7/18/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class ZoomableImage: UIView {
    
    let pinchGestureRecognizer = UIPinchGestureRecognizer()
    let panGestureRecognizer = UIPanGestureRecognizer()
    var initialCenter = CGPoint()
    var previousCenter = CGPoint()
    var zoomView = UIImageView()
    var initialImageSize = CGSize()
    var actualCenter = CGPoint()
    var kLayer: CAShapeLayer!
    var image: UIImage! {
        didSet {
            zoomView.transform = .identity
            zoomView.center = initialCenter
            zoomView.image = image
            // this is messy
            initialImageSize = zoomView.sizeForImageInImageViewAspectFit()
            print("initialImageSize: \(initialImageSize)")
        }
    }
    var actualScale: CGFloat = 1.0
    
    init(image: UIImage) {
        super.init(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        self.image = image
        zoomView.image = image
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        zoomView.frame = frame
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setup() {
        initialCenter = center
        actualCenter = initialCenter
        
        clipsToBounds = true
        isUserInteractionEnabled = true
        backgroundColor = .clear
        zoomView.isUserInteractionEnabled = true
        zoomView.contentMode = .scaleAspectFill
        
        let dotPath = UIBezierPath(ovalIn: CGRect(x: 204, y: 197, width: 6, height: 6))
        self.kLayer = CAShapeLayer()
        kLayer.path = dotPath.cgPath
        kLayer.strokeColor = UIColor.black.cgColor
        kLayer.zPosition = 1
        zoomView.layer.addSublayer(kLayer)
        
        // this was a stupid idea
        let circle = UIBezierPath(arcCenter: self.center, radius: 4, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circle.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.zPosition = 1
        self.layer.addSublayer(shapeLayer)
        addSubview(zoomView)
        
        pinchGestureRecognizer.addTarget(self, action: #selector(zoom))
        pinchGestureRecognizer.delegate = self
        addGestureRecognizer(pinchGestureRecognizer)
        
        panGestureRecognizer.addTarget(self, action: #selector(pan))
        panGestureRecognizer.maximumNumberOfTouches = 2
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func zoom(_ gesture: UIPinchGestureRecognizer) {
        // zoom range limits
        // since transform is always applied equally to x and y, using the a (1,1) component of the matrix is fine
        let scale = zoomView.transform.a
//        print("a: \(zoomView.transform.a), b: \(zoomView.transform.b), c: \(zoomView.transform.c), d: \(zoomView.transform.d)")
        switch gesture.state {
        case .began, .changed:
            
            let locX = gesture.location(in: zoomView).x - actualCenter.x
            let locY = gesture.location(in: zoomView).y - actualCenter.y
// This is the problem... not sure why
            print("before: zoomView.center: \(zoomView.center.x), \(zoomView.center.y)")
            print("actualCenter before: \(actualCenter.x), \(actualCenter.y)")
//            var transform = zoomView.layer.transform
//            transform = CATransform3DTranslate(transform, locX, locY, 0)
//            transform = CATransform3DScale(transform, gesture.scale, gesture.scale, 1.0)
//            transform = CATransform3DTranslate(transform, -locX, -locY, 0)
//            zoomView.layer.transform = transform
            
            // works but zoom is weird.. it's too much
            zoomView.transform = zoomView.transform.translatedBy(x: locX, y: locY).scaledBy(x: gesture.scale, y: gesture.scale).translatedBy(x: -locX, y: -locY)
            // fuck this
            actualCenter.x -= locX * (1 - gesture.scale)
            actualCenter.y -= locY * (1 - gesture.scale)
            print("actualCenter after: \(actualCenter.x), \(actualCenter.y)")
            print("after: zoomView.center: \(zoomView.center.x), \(zoomView.center.y)")
//            zoomView.center = actualCenter
            
            gesture.scale = 1.0
        case .ended:
            if scale < 1.0 {
                UIView.animate(withDuration: 0.2) {
                    self.zoomView.transform = .identity
                    
                    self.actualCenter = self.initialCenter // here
                    
                    self.zoomView.center = self.initialCenter
                    self.actualScale = 1.0
                }
            } else if scale > 10 {
                self.zoomView.transform = CGAffineTransform.identity.scaledBy(x: 10, y: 10)
            } else {
                self.actualScale = scale
            }
        default:
            return
        }
    }
    
    @objc private func pan(_ gesture: UIPanGestureRecognizer) {
        // must be in superview coordinates
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            previousCenter = zoomView.center
        case .changed:
            zoomView.center = CGPoint(x: previousCenter.x + translation.x, y: previousCenter.y + translation.y)
        case .cancelled, .ended:
            let left = translation.x + previousCenter.x - actualScale * initialImageSize.width / 2
            let right = translation.x + previousCenter.x + actualScale * initialImageSize.width / 2
            let top = translation.y + previousCenter.y - actualScale * initialImageSize.height / 2
            let bottom = translation.y + previousCenter.y + actualScale * initialImageSize.height / 2
            
            print("translation.x: \(translation.x), previousCenter.x: \(previousCenter.x), actualScale: \(actualScale), initialImageSize.width / 2: \(initialImageSize.width / 2)")
            
            print("top: \(top), bottom: \(bottom), left: \(left), right: \(right)")
            // disallow panning on zoomed out or size 1 image
            if actualScale <= 1.0  {
                UIView.animate(withDuration: 0.2) {
                    self.zoomView.center = self.initialCenter
                }
        // prevent zoomed image from panning out of the view
            } else if left > 0.0 || right < frame.width || top > 0.0 || bottom < safeAreaLayoutGuide.layoutFrame.height {
                UIView.animate(withDuration: 0.2) {
                    self.zoomView.center = self.previousCenter
                }
            } else {
                zoomView.center = CGPoint(x: previousCenter.x + translation.x, y: previousCenter.y + translation.y)
            }
        default:
            return
        }
    }
}

extension ZoomableImage: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
