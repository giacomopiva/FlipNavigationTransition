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
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController!.delegate = self
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.panHandler(_:)))
        self.view.addGestureRecognizer(panGesture!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == UINavigationControllerOperation.push {
            return FlipPushTransitioningAnimator()
        }
        
        if operation == UINavigationControllerOperation.pop {
            return FlipPopTransitioningAnimator()
        }
        
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionController
    }
    
    // MARK: - Gesture recognizer
    
    func panHandler(_ gestureRecognizer:UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.interactionController = UIPercentDrivenInteractiveTransition()
            
            // direction < 0 -> UP
            // direction > 0 -> DOWN
            let direction = gestureRecognizer.velocity(in: self.view).y
            
            if gestureRecognizer.location(in: self.view).y > self.view.bounds.height/2 && direction < 0 {
                // If the touch begin in the lower side of the screen and the direction is to the top,
                // I'll move to the next
                moveToNext()
            } else if gestureRecognizer.location(in: self.view).y < self.view.bounds.height/2 && direction > 0 {
                // If the touch begin in the upper side of the screen and the direction is to the bottom,
                // I'll move to the prev
                moveToPrev()
            } else {
                // In all other cases the gesture is "not valid" e.g. if touch begin in the upper side of the
                // screen and the direction is to the top
            }
            
        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            let completionProgress = abs(translation.y/self.view.bounds.height)
            self.interactionController!.update(completionProgress)
            
        case .ended:
            let translation = gestureRecognizer.translation(in: self.view)
            let completionProgress = abs(translation.y/self.view.bounds.height)
            let speed = abs(gestureRecognizer.velocity(in: self.view).y)
            
            if completionProgress >= 0.3 || speed >= 400.0 {
                self.interactionController!.finish()
            } else {
                self.interactionController!.cancel()
            }
            
            self.interactionController = nil
            
        default:
            self.interactionController?.cancel()
            self.interactionController = nil
        }
    }
    
    func moveToNext() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destination = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController!.pushViewController(destination, animated: true)
    }
    
    func moveToPrev() {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func nextButtonDidTap(_ sender: AnyObject) {
        moveToNext()
    }
    
}

