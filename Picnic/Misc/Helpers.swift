//
//  Helpers.swift
//  Picnic
//
//  Created by Kyle Burns on 5/30/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit
extension UIView {
    func setShadow(radius: CGFloat, color: CGColor?, opacity: Float = 1.0, offset: CGSize = .zero) {
         layer.shadowRadius = radius
         layer.shadowColor = color
         layer.shadowOffset = offset
         layer.shadowOpacity = opacity
    }
}

extension CGSize {
    static func +(left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width + right.width, height: left.height + right.height)
    }
    
    static func /(left: CGSize, right: Int) -> CGSize {
        let r = CGFloat(right)
        return CGSize(width: left.width / r, height: left.height / r)
    }
    
    static func -(left: CGSize, right: Int) -> CGSize {
        let r = CGFloat(right)
        return CGSize(width: left.width - r, height: left.height - r)
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
