//
//  ShortPresentationController.swift
//  Picnic
//
//  Created by Kyle Burns on 8/5/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class ShortPresentationController: UIPresentationController {
    
    var offset: CGFloat = 0.0
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let bounds = containerView?.bounds ?? .zero
        return CGRect(x: 0, y: offset, width: bounds.width, height: bounds.height - offset)
    }

    override func containerViewWillLayoutSubviews() {
      presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
