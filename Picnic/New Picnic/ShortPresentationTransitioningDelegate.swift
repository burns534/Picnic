//
//  ShortPresentationTransitioningDelegate.swift
//  Picnic
//
//  Created by Kyle Burns on 8/5/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

final class ShortPresentationTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var presentationController: ShortPresentationController
    
    init(from presented: UIViewController, to presenting: UIViewController, offsetY: CGFloat) {
        presentationController = ShortPresentationController(offsetY: offsetY, presentedViewController: presented, presenting: presenting)
        super.init()
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return presentationController
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
