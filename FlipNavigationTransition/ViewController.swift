//
//  ViewController.swift
//  FlipNavigationTransition
//
//  Created by Giacomo Piva on 22/12/15.
//  Copyright © 2015 Giacomo Piva. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    var panGesture: UIPanGestureRecognizer?
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController!.delegate = self
        
        panGesture = UIPanGestureRecognizer(target: self, action: Selector("panHandler:"))
        self.view.addGestureRecognizer(panGesture!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == UINavigationControllerOperation.Push {
            return FlipPushTransitioningAnimator()
        }
        
        if operation == UINavigationControllerOperation.Pop {
            return FlipPopTransitioningAnimator()
        }
        
        return nil
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionController
    }
    
    // MARK: - Gesture recognizer
    
    func panHandler(gestureRecognizer:UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            self.interactionController = UIPercentDrivenInteractiveTransition()
            
            // direction < 0 -> UP
            // direction > 0 -> DOWN
            let direction = gestureRecognizer.velocityInView(self.view).y
            
            if gestureRecognizer.locationInView(self.view).y > self.view.bounds.height/2 && direction < 0 {
                // If the touch begin in the lower side of the screen and the direction is to the top,
                // I'll move to the next
                moveToNext()
            } else if gestureRecognizer.locationInView(self.view).y < self.view.bounds.height/2 && direction > 0 {
                // If the touch begin in the upper side of the screen and the direction is to the bottom,
                // I'll move to the prev
                moveToPrev()
            } else {
                // In all other cases the gesture is "not valid" e.g. if touch begin in the upper side of the
                // screen and the direction is to the top
            }
            
        case .Changed:
            let translation = gestureRecognizer.translationInView(self.view)
            let completionProgress = abs(translation.y/CGRectGetHeight(self.view.bounds))
            self.interactionController!.updateInteractiveTransition(completionProgress)
            
        case .Ended:
            let translation = gestureRecognizer.translationInView(self.view)
            let completionProgress = abs(translation.y/CGRectGetHeight(self.view.bounds))
            let speed = abs(gestureRecognizer.velocityInView(self.view).y)
            
            if completionProgress >= 0.3 || speed >= 400.0 {
                self.interactionController!.finishInteractiveTransition()
            } else {
                self.interactionController!.cancelInteractiveTransition()
            }
            
            self.interactionController = nil
            
        default:
            self.interactionController?.cancelInteractiveTransition()
            self.interactionController = nil
        }
    }
    
    func moveToNext() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destination = storyboard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        self.navigationController!.pushViewController(destination, animated: true)
    }
    
    func moveToPrev() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func nextButtonDidTap(sender: AnyObject) {
        moveToNext()
    }
    
}

