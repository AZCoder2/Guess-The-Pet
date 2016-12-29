//
//  FlipPresentAnimationController.swift
//  GuessThePet
//
//  Created by Tom Ranalli on 12/26/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class FlipPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Properties
    
    // Variable to hold starting frame
    var originFrame = CGRect.zero
    
    // MARK: - Methods
    
    // Set transition duration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    // Implement transition animation
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        /* The transitioning context will provide the view controllers and
        views participating in the transition. You use the appropriate keys to obtain them
        */
        guard
            let fromVC = transitionContext.viewController(forKey:
            UITransitionContextViewControllerKey.from),
            
            let toVC = transitionContext.viewController(forKey:
                UITransitionContextViewControllerKey.to)
        else {
            return
        }
        
        /* You next specify the starting and final frames for the “to” view. 
           In this case, the transition starts from the card’s frame and scales 
           to fill the whole screen.
         
           Also, define the container view. Removed from "guard" above since UIView is
           NOT an optional, so the guard is unnecessary
        */
        let containerView = transitionContext.containerView
        let initialFrame = originFrame
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        /* UIView snapshotting captures the “to” view and renders it into a lightweight view; 
           this lets you animate the view together with its hierarchy. The snapshot’s frame 
           starts off as the card’s frame. You also modify the corner radius to match the card.
        */
        let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
        
        snapshot?.frame = initialFrame
        snapshot?.layer.cornerRadius = 25
        snapshot?.layer.masksToBounds = true
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot!)
        toVC.view.isHidden = true
        
        AnimationHelper.perspectiveTransformForContainerView(containerView)
        snapshot?.layer.transform = AnimationHelper.yRotation(M_PI_2)
        
        /* First, you specify the duration of the animation. Notice the use of the transitionDuration(_:) method, implemented at the top of this class. You need the duration of your animations to match up with the duration you’ve declared for the whole transition so UIKit can keep things in sync.
        */
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                
                // You start by rotating the “from” view halfway around its y-axis to hide it from view.
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: {
                    fromVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
                })
                
                // Next, you reveal the snapshot using the same technique.
                UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                    snapshot?.layer.transform = AnimationHelper.yRotation(0.0)
                })
                
                // Then you set the frame of the snapshot to fill the screen.
                UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                    snapshot?.frame = finalFrame
                })
        },
            completion: { _ in
                /*  Finally, it’s safe to reveal the real “to” view. You remove the snapshot since it’s no longer useful. Then you rotate the “from” view back in place; otherwise, it would hidden when transitioning back. Calling completeTransition informs the transitioning context that the animation is complete. UIKit will ensure the final state is consistent and remove the “from” view from the container.
                */
                toVC.view.isHidden = false
                fromVC.view.layer.transform = AnimationHelper.yRotation(0.0)
                snapshot?.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }


}
