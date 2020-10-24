//
//  Helpers.swift
//  Picnic
//
//  Created by Kyle Burns on 5/30/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import MapKit
import FirebaseFirestore

extension UIImageView {
    func sizeForImageInImageViewAspectFit() -> CGSize
    {
        if let img = self.image {
            let imageRatio = img.size.width / img.size.height;

            let viewRatio = self.frame.size.width / self.frame.size.height;

            if (imageRatio < viewRatio) {
                let scale = self.frame.size.height / img.size.height

                let width = scale * img.size.width

                return CGSize(width: width, height: frame.size.height)
            } else {
                let scale = self.frame.size.width / img.size.width

                let height = scale * img.size.height

                return CGSize(width: frame.size.width, height: height);
            }
        }
        return .zero
    }
}

extension UIImage {
    func tint(color: UIColor) -> UIImage {
        let maskImage = cgImage
        let bounds = CGRect(origin: .zero, size: size)

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext
            cgContext.translateBy(x: 0, y: size.height)
            cgContext.scaleBy(x: 1.0, y: -1.0)
            cgContext.clip(to: bounds, mask: maskImage!)
            color.setFill()
            cgContext.fill(bounds)
        }
    }
}

extension Collection where Self.Iterator.Element: RandomAccessCollection {
    /**
     Returns tranposed collection
    - Author: Alexander - Reinstate Monica (stackoverflow)
    - Important:
     'self' must be rectangular, i.e. every row has equal size.
     */
    func transposed() -> [[Self.Iterator.Element.Iterator.Element]] {
        guard let firstRow = self.first else { return [] }
        return firstRow.indices.map { index in
            self.map{ $0[index] }
        }
    }
}

extension CALayer {
    func setShadow(radius: CGFloat, color: UIColor, opacity: Float = 1.0, offset: CGSize = .zero) {
        masksToBounds = false
        shadowRadius = radius
        shadowColor = color.cgColor
        shadowOffset = offset
        shadowOpacity = opacity
        shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    func prepareSublayersForShadow() {
        sublayers?.filter{ $0.frame.equalTo(self.bounds) }
            .forEach{ $0.cornerRadius = cornerRadius }
        if let contents = self.contents {
            self.contents = nil
            let contentLayer = CALayer()
            contentLayer.contents = contents
            contentLayer.frame = bounds
            contentLayer.cornerRadius = cornerRadius
            contentLayer.masksToBounds = true
            insertSublayer(contentLayer, at: 0)
        }
    }
}
extension UIView {
    
    func setShadow(radius: CGFloat, color: UIColor, opacity: Float = 1.0, xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        layer.shadowRadius = radius
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: xOffset, height: yOffset)
        layer.shadowOpacity = opacity
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    func setShadow(radius: CGFloat, color: UIColor, opacity: Float = 1.0, offset: CGSize = .zero) {
        layer.shadowRadius = radius
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    func setGradient(colors: [UIColor], bounds: CGRect? = nil) {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        if let bounds = bounds {
            gradient.frame = bounds
        } else {
            gradient.frame = self.bounds
        }
        layer.insertSublayer(gradient, at: 0)
    }
}
// from paul hudson
extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

extension CGSize {
    static func +(left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width + right.width, height: left.height + right.height)
    }
    
    static func + (lhs: CGSize, rhs: Int) -> CGSize {
        let r = CGFloat(rhs)
        return CGSize(width: lhs.width + r, height: lhs.height + r)
    }
    
    static func /(left: CGSize, right: Int) -> CGSize {
        let r = CGFloat(right)
        return CGSize(width: left.width / r, height: left.height / r)
    }
    
    static func -(left: CGSize, right: Int) -> CGSize {
        let r = CGFloat(right)
        return CGSize(width: left.width - r, height: left.height - r)
    }
    static func *(left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width: left.width * right, height: left.height * right)
    }
}

extension GeoPoint {
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// Not mine
extension UIColor {
  public convenience init(rgba: String) {
    var red:   CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue:  CGFloat = 0.0
    var alpha: CGFloat = 1.0
    
    if rgba.hasPrefix("#") {
        let index   = rgba.index(rgba.startIndex, offsetBy: 1)
        let hex     = rgba.suffix(from: index)
        let scanner = Scanner(string: String(hex))
      var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
        switch (hex.count) {
        case 3:
          red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
          green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
          blue  = CGFloat(hexValue & 0x00F)              / 15.0
        case 4:
          red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
          green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
          blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
          alpha = CGFloat(hexValue & 0x000F)             / 15.0
        case 6:
          red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
          green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
          blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
        case 8:
          red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
          green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
          blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
          alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
        default:
          print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
        }
      } else {
        print("Scan hex error")
      }
    } else {
      print("Invalid RGB string, missing '#' as prefix")
    }
    self.init(red:red, green:green, blue:blue, alpha:alpha)
  }
}

extension MKCoordinateRegion {
    var bounds: (minLat: Double, maxLat: Double, minLong: Double, maxLong: Double) {
        let minLat = center.latitude - 0.5 * span.latitudeDelta
        let maxLat = center.latitude + 0.5 * span.latitudeDelta
        let minLong = center.longitude - 0.5 * span.longitudeDelta
        let maxLong = center.longitude + 0.5 * span.longitudeDelta
        return (minLat, maxLat, minLong, maxLong)
    }
}

extension CGFloat {
    func isEqualTo(_ rhs: CGFloat) -> Bool {
        (rhs - self) < CGFloat.leastNonzeroMagnitude
    }
}
