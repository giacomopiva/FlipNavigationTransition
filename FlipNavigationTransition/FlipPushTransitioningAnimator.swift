//
//  FlipPushTransitioningAnimator.swift
//  Gallerie Bennet
//
//  Created by Giacomo Piva on 30/10/15.
//  Copyright © 2015 Ideasfera. All rights reserved.
//

import UIKit

class FlipPushTransitioningAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: UIViewControllerAnimatedTransitioning
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView   = transitionContext.containerView
        let toView          = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view
        let fromView        = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view
        let duration        = transitionDuration(using: transitionContext)
        
        // Getting Screenshots
        let toViewSnapshot = createSnapshots(toView!, afterUpdate: true)
        let flippedSectionOfToView = toViewSnapshot[1] // Top of toView
        
        let fromViewSnapshot = createSnapshots(fromView!, afterUpdate: false)
        let flippedSectionOfFromView = fromViewSnapshot[0] // Bottom of fromView
        
        // Setting up shadows
        let toViewBottomShadowLayer = UIView(frame: toViewSnapshot[0].frame)
        let toViewTopShadowLayer    = UIView(frame: toViewSnapshot[1].frame)
        let fromViewTopShadowLayer  = UIView(frame: fromViewSnapshot[1].frame)
        
        var transform = CATransform3DIdentity
        transform.m34 = -0.003
        containerView.layer.sublayerTransform = transform
        
        updateAnchorPointAndOffset(CGPoint(x: 0.5, y: 0.0), view: flippedSectionOfFromView)
        updateAnchorPointAndOffset(CGPoint(x: 0.5, y: 1.0), view: flippedSectionOfToView)
        updateAnchorPointAndOffset(CGPoint(x: 0.5, y: 1.0), view: toViewTopShadowLayer)
        
        let animationView = UIView(frame: containerView.frame)
        animationView.addSubview(toView!)
        containerView.addSubview(animationView)
        containerView.addSubview(toView!)
        containerView.insertSubview(toView!, belowSubview: animationView)
        animationView.addSubview(toViewSnapshot[0])
        animationView.addSubview(toViewBottomShadowLayer)
        animationView.addSubview(flippedSectionOfFromView)
        animationView.addSubview(fromViewSnapshot[1])
        animationView.addSubview(flippedSectionOfToView)
        animationView.addSubview(toViewTopShadowLayer)
        animationView.addSubview(fromViewTopShadowLayer)

        let trans = CATransform3DIdentity
        flippedSectionOfToView.layer.transform = CATransform3DRotate(trans, CGFloat(-M_PI_2), 1, 0, 0)
        flippedSectionOfToView.alpha = 0
        toViewTopShadowLayer.layer.transform = CATransform3DRotate(trans, CGFloat(-M_PI_2), 1, 0, 0)

        // Configuring shadows
        toViewBottomShadowLayer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        toViewTopShadowLayer.backgroundColor    = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        fromViewTopShadowLayer.backgroundColor  = UIColor.black
        fromViewTopShadowLayer.alpha = 0.0

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: UIViewKeyframeAnimationOptions.layoutSubviews, animations: {

            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: duration/2, animations: {
                flippedSectionOfFromView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 1.0, 0.0, 0.0)
                toViewBottomShadowLayer.alpha = 0.0
             })
                
            UIView.addKeyframe(withRelativeStartTime: duration/2, relativeDuration: 0.0001, animations: {
                flippedSectionOfToView.alpha = 1.0
                flippedSectionOfToView.layer.zPosition = 5
                toViewTopShadowLayer.layer.zPosition = 5
            })
                
            UIView.addKeyframe(withRelativeStartTime: (duration/2)+0.0001, relativeDuration: (duration/2)-0.0001, animations: {
                flippedSectionOfToView.layer.transform = CATransform3DRotate(trans,CGFloat((M_PI_2/180)), 1, 0, 0)
                toViewTopShadowLayer.layer.transform = CATransform3DRotate(trans,CGFloat((M_PI_2/180)), 1, 0, 0)
                toViewTopShadowLayer.alpha = 0.0
                fromViewTopShadowLayer.alpha = 0.5
            })
            
            }, completion: { finished in
                if transitionContext.transitionWasCancelled {
                    transitionContext.completeTransition(false)
                } else {
                    transitionContext.completeTransition(true)
                }
                
                animationView.removeFromSuperview()
        })
    }
    
    func createSnapshots(_ view:UIView, afterUpdate:Bool) -> Array<UIView> {
        var snapshotRegion = CGRect.zero
        
        // Snapshot DOWN
        snapshotRegion = CGRect(x: 0, y: (view.frame.size.height/2) , width: view.frame.size.width, height: view.frame.size.height/2);
        let downHandView = view.resizableSnapshotView(from: snapshotRegion, afterScreenUpdates: afterUpdate, withCapInsets: UIEdgeInsets.zero)
        downHandView?.frame = snapshotRegion
        
        // Snapshot  UP
        let upSnapshotRegion = CGRect(x: 0, y: 64, width: view.frame.size.width, height: view.frame.size.height/2 - 64)
        let upHandView = view.resizableSnapshotView(from: upSnapshotRegion, afterScreenUpdates: afterUpdate, withCapInsets: UIEdgeInsets.zero)
        upHandView?.frame = upSnapshotRegion
        
        return[downHandView!, upHandView!]
    }
    
    func updateAnchorPointAndOffset(_ anchorPoint:CGPoint, view:UIView) {
        view.layer.anchorPoint = anchorPoint
        let yOffset = anchorPoint.y  - 0.5
        view.frame = view.frame.offsetBy(dx: 0, dy: yOffset * view.frame.size.height)
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.9
    }
}
