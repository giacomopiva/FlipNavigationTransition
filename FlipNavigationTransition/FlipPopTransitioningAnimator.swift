//
//  FlipPopTransitioningAnimator.swift
//  Gallerie Bennet
//
//  Created by Giacomo Piva on 30/10/15.
//  Copyright © 2015 Ideasfera. All rights reserved.
//

import UIKit

class FlipPopTransitioningAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
        let containerView   = transitionContext.containerView()!
        let toView          = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
        let fromView        = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view
        let duration        = transitionDuration(transitionContext)
        
        // Getting Screenshots
        let toViewSnapshot = createSnapshots(toView!, afterUpdate: true)
        let flippedSectionOfToView = toViewSnapshot[0] // Bottom of toView
        
        let fromViewSnapshot = createSnapshots(fromView!, afterUpdate: false)
        let flippedSectionOfFromView = fromViewSnapshot[1] // Top of fromView
        
        // Setting up shadows
        let toViewTopShadowLayer        = UIView(frame: toViewSnapshot[1].frame)
        let toViewBottomShadowLayer     = UIView(frame: toViewSnapshot[0].frame)
        let fromViewBottomShadowLayer   = UIView(frame: fromViewSnapshot[0].frame)

        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
        
        updateAnchorPointAndOffset(CGPointMake(0.5, 0.0), view: flippedSectionOfToView)
        updateAnchorPointAndOffset(CGPointMake(0.5, 1.0), view: flippedSectionOfFromView)
        updateAnchorPointAndOffset(CGPointMake(0.5, 0.0), view: toViewBottomShadowLayer)
        
        let animationView = UIView(frame: containerView.frame)
        animationView.addSubview(toView!)
        containerView.addSubview(animationView)
        containerView.addSubview(toView!)
        containerView.insertSubview(toView!, belowSubview: animationView)
        animationView.addSubview(toViewSnapshot[0])
        animationView.addSubview(toViewSnapshot[1])
        animationView.addSubview(toViewTopShadowLayer)
        animationView.addSubview(fromViewSnapshot[0])
        animationView.addSubview(fromViewBottomShadowLayer)
        animationView.addSubview(flippedSectionOfToView)
        animationView.addSubview(toViewBottomShadowLayer)
        animationView.addSubview(flippedSectionOfFromView)
        
        let trans = CATransform3DIdentity
        flippedSectionOfToView.layer.transform = CATransform3DRotate(trans, CGFloat(M_PI_2), 1, 0, 0)
        flippedSectionOfToView.alpha = 0
        toViewBottomShadowLayer.layer.transform = CATransform3DRotate(trans, CGFloat(M_PI_2), 1, 0, 0)
        
        // Configuring shadows
        toViewTopShadowLayer.backgroundColor        = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        toViewBottomShadowLayer.backgroundColor     = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        fromViewBottomShadowLayer.backgroundColor   = UIColor.blackColor()
        fromViewBottomShadowLayer.alpha = 0.0
        
        UIView.animateKeyframesWithDuration(duration, delay: 0, options: UIViewKeyframeAnimationOptions.LayoutSubviews, animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: duration/2, animations: {
                flippedSectionOfFromView.layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI_2), 1.0, 0.0, 0.0)
                toViewTopShadowLayer.alpha = 0.0
            })
                
            UIView.addKeyframeWithRelativeStartTime(duration/2, relativeDuration: 0.0001, animations: {
                flippedSectionOfToView.alpha = 1
                flippedSectionOfToView.layer.zPosition = 5
                toViewBottomShadowLayer.layer.zPosition = 5
            })
                
            UIView.addKeyframeWithRelativeStartTime((duration/2)+0.0001, relativeDuration: (duration/2)-0.0001, animations: {
                flippedSectionOfToView.layer.transform =  CATransform3DRotate(trans,CGFloat((-M_PI_2/180)), 1, 0, 0)
                toViewBottomShadowLayer.layer.transform = CATransform3DRotate(trans,CGFloat((-M_PI_2/180)), 1, 0, 0)
                toViewBottomShadowLayer.alpha = 0.0
                fromViewBottomShadowLayer.alpha = 0.5

            })

            }, completion: { finished in
                if transitionContext.transitionWasCancelled() {
                    transitionContext.completeTransition(false)
                } else {
                    transitionContext.completeTransition(true)
                }
                
                animationView.removeFromSuperview()
        })
    }
    
    func createSnapshots(view:UIView, afterUpdate:Bool) -> Array<UIView> {
        var snapshotRegion = CGRectZero

        // Snapshot DOWN
        snapshotRegion = CGRectMake(0, view.frame.size.height/2 , view.frame.size.width, view.frame.size.height/2);
        let downHandView = view.resizableSnapshotViewFromRect(snapshotRegion, afterScreenUpdates: afterUpdate, withCapInsets: UIEdgeInsetsZero)
        downHandView.frame = snapshotRegion
        
        // Snapshot  UP
        let upSnapshotRegion = CGRectMake(0, 64, view.frame.size.width, view.frame.size.height/2 - 64)
        let upHandView = view.resizableSnapshotViewFromRect(upSnapshotRegion, afterScreenUpdates: afterUpdate, withCapInsets: UIEdgeInsetsZero)
        upHandView.frame = upSnapshotRegion
        
        return[downHandView, upHandView]
    }
    
    func updateAnchorPointAndOffset(anchorPoint:CGPoint, view:UIView) {
        view.layer.anchorPoint = anchorPoint
        let yOffset = anchorPoint.y  - 0.5
        view.frame = CGRectOffset(view.frame, 0, yOffset * view.frame.size.height)
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.8
    }
}
