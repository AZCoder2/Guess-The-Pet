//
//  FlipDismissAnimationController.swift
//  GuessThePet
//
//  Created by Tom Ranalli on 12/27/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class FlipDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // Variable to hold starting frame
    var destinationFrame = CGRect.zero
    
    // Set transition duration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    // Implement transition animation
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        
        // Since this animation shrinks the view, you’ll need to flip the initial and final frames
        let containerView = transitionContext.containerView
        let finalFrame = destinationFrame
        
        // This time you’re manipulating the “from” view so you take a snapshot of that
        let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false)
        snapshot?.layer.cornerRadius = 25
        snapshot?.layer.masksToBounds = true
        
        // Add the “to” view and the snapshot to the container view, then hide the “from” view, so that
        // it doesn’t conflict with the snapshot
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot!)
        fromVC.view.isHidden = true
        
        AnimationHelper.perspectiveTransformForContainerView(containerView)
        
        // hide the “to” view via the same rotation technique
        toVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                
                // Scale the view first
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: {
                    snapshot?.frame = finalFrame
                })
                
                // Hide the snapshot with the rotation
                UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                    snapshot!.layer.transform = AnimationHelper.yRotation(M_PI_2)
                })
                
                // Next you reveal the “to” view by rotating it halfway around the y-axis but in the 
                // opposite direction
                UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                    toVC.view.layer.transform = AnimationHelper.yRotation(0.0)
                })
        },
            completion: { _ in
                // You remove the snapshot and inform the context that the transition is complete. This 
                // allows UIKit to update the view controller hierarchy and tidy up the views it created 
                // to run the transition
                fromVC.view.isHidden = false
                snapshot?.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
    
}
