//
//  PaddedTextField.swift
//  Picnic
//
//  Created by Kyle Burns on 8/6/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class PaddedTextField: UITextField {

    enum Padding: CGFloat {
        case standard = 10
        case extra = 20
        case thin = 5
        case none = 0
    }
    
    private var inset: Padding = .none
    
    func setPadding(_ amount: Padding) {
        inset = amount
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset.rawValue, dy: inset.rawValue)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset.rawValue, dy: inset.rawValue)
    }
}
