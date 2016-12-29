//
//  SwipeInteractionController.swift
//  GuessThePet
//
//  Created by Tom Ranalli on 12/28/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    
    // MARK: - Properties
    var interactionInProgress = false
    
    fileprivate var shouldCompleteTransition = false
    fileprivate weak var viewController: UIViewController!
    
    // MARK: - Methods
    
    // Obtain a reference to the view controller and set up a gesture recognizer in its view
    func wireToViewController(viewController: UIViewController!) {
        self.viewController = viewController
        prepareGestureRecognizerInView(viewController.view)
    }
    
    // Declare a gesture recognizer, which will be triggered by a left edge swipe, and add it to the 
    // view.
    fileprivate func prepareGestureRecognizerInView(_ view: UIView) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        gesture.edges = UIRectEdge.left
        view.addGestureRecognizer(gesture)
    }
    
    func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        
        // You start by declaring local variables to track the progress. You’ll record the translation in 
        // the view and calculate the progress. A Swipe of 200 points will lead to 100% completion, so 
        // you use this number to measure the transition’s progress.
        
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.x / 200)
        
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch gestureRecognizer.state {
        
        // When the gesture starts, you adjust interactionInProgress accordingly and trigger the 
        // dismissal of the view controller
            
        case .began:
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
        
        // While the gesture is moving, you continuously call updateInteractiveTransition with the 
        // progress amount. This is a method on UIPercentDrivenInteractiveTransition which moves the 
        // transition along by the percentage amount you pass in.
            
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
            
        // If the gesture is cancelled, you update interactionInProgress and roll back the transition.
            
        case .cancelled:
            interactionInProgress = false
            cancel()
            
        // Once the gesture has ended, you use the current progress of the transition to decide whether 
        // to cancel it or finish it for the user.
            
        case .ended:
            interactionInProgress = false
            
            if !shouldCompleteTransition {
                cancel()
            } else {
                finish()
            }
            
        default:
            print("Unsupported")
        }
    }
    

}
