//
//  ShortPresentationController.swift
//  Picnic
//
//  Created by Kyle Burns on 8/5/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class ShortPresentationController: UIPresentationController {
    
    var offsetY: CGFloat
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        let height = container.bounds.height
        return CGRect(x: 0, y: offsetY, width: container.bounds.width, height: height - offsetY)
    }
    
    init(offsetY: CGFloat, presentedViewController: UIViewController, presenting: UIViewController?) {
        self.offsetY = offsetY
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }
    
    override func containerViewWillLayoutSubviews() {
      presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
