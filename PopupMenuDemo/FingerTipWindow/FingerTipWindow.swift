//
//  FingerTipWindow.swift
//  ExpendTableViewCell
//
//  Created by lidongxi on 2017/10/14.
//  Copyright © 2017年 lidongxi. All rights reserved.
//  简书:http://www.jianshu.com/u/6f76b136c31e

import UIKit

/** A FingerTipWindow gives you automatic presentation mode in your iOS app. Note that currently, this is only designed for the iPad 2 and iPhone 4S (or later), which feature hardware video mirroring support. This library does not do the mirroring for you!
 *
 *   Use FingerTipWindow in place of UIWindow and your app will automatically determine when an external screen is available. It will show every touch on-screen with a nice partially-transparent graphic that automatically fades out when the touch ends.
 */
class FingerTipWindow: UIWindow {
    
    /** The alpha transparency value to use for the touch image. Defaults to 0.5. */
    var touchAlpha : CGFloat = 0.5
    
    /** The time over which to fade out touch images. Defaults to 0.3. */
    var fadeDuration : TimeInterval =  0.3
    
    /** If using the default touchImage, the color with which to stroke the shape. Defaults to black. */
    var strokeColor : UIColor = UIColor.black
    
    /** If using the default touchImage, the color with which to fill the shape. Defaults to white. */
    var fillColor : UIColor = UIColor.white
    
    /** A custom image to use to show touches on screen. If unset, defaults to a partially-transparent stroked circle. */
    lazy var touchImage: UIImage = {
        
        let clipPath = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        UIGraphicsBeginImageContextWithOptions(clipPath.bounds.size, false, 0)
        let drawPath = UIBezierPath.init(arcCenter: CGPoint.init(x: 25, y: 25), radius: 22.0, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true)
        drawPath.lineWidth = 2.0
        self.strokeColor.setStroke()
        self.fillColor.setFill()
        drawPath.stroke()
        drawPath.fill()
        clipPath.addClip()
        let touchImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return touchImage!
    }()
    
    /** Sets whether touches should always show regardless of whether the display is mirroring. Defaults to NO. */
    var alwaysShowTouches : Bool{
        didSet{
            updateFingertipsAreActive()
        }
    }
    
   // var overlayWindow : UIWindow!
    var active : Bool = true
    var fingerTipRemovalScheduled : Bool = false
    var fadingOut : Bool = false
    
    override init(frame: CGRect) {
        self.alwaysShowTouches = false
        super.init(frame: frame)
        
        fingerTipWindow_commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.alwaysShowTouches = false
        super.init(coder: aDecoder)
        
        fingerTipWindow_commonInit()
    }
    
    func fingerTipWindow_commonInit() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(screenConnect), name: NSNotification.Name.UIScreenDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenDisconnect), name: NSNotification.Name.UIScreenDidDisconnect, object: nil)
        updateFingertipsAreActive()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIScreenDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIScreenDidDisconnect, object: nil)
    }
   
     // MARK: Screen notifications
    @objc fileprivate func screenConnect(notification : Notification) {
        updateFingertipsAreActive()
    }
    @objc fileprivate func screenDisconnect(notification : Notification) {
        updateFingertipsAreActive()
    }
    
  
    // Set up active now, in case the screen was present before the window was created (or application launched).
    fileprivate func updateFingertipsAreActive() {
        
        if let flag = ProcessInfo.processInfo.environment["DEBUG_FINGERTIP_WINDOW"] {
            if Bool(flag) == true{
                self.active = true
            }
        }else if alwaysShowTouches == true {
            self.active = true
        }else{
            active = anyScreenIsMirrored()
        }
    }
    
    fileprivate func anyScreenIsMirrored() -> Bool {
        
        if UIScreen.instancesRespond(to: #selector(getter: UIScreen.init().mirrored)) {
            return false
        }
        for screen in UIScreen.screens{
            if screen.mirrored != nil {
                return true
            }
        }
        return false
    }
    
    
    lazy var overlayWindow: UIWindow = {
        let overlayWindow = UIWindow.init(frame: self.frame)
        overlayWindow.isUserInteractionEnabled = false
        overlayWindow.windowLevel = UIWindowLevelStatusBar
        overlayWindow.backgroundColor = UIColor.clear
        overlayWindow.isHidden = false
        return overlayWindow
    }()

    
    
    // MARK: UIWindow overrides
    override func sendEvent(_ event: UIEvent) {
        if active == true {
            let allTouches = event.allTouches
            for touch in allTouches!{
                switch touch.phase {
                
                case .began,.moved,.stationary:
                    var touchView = overlayWindow.viewWithTag(touch.hash) as? FingerTipImageView
                    
                    if let touchV = touchView {
                        if touchV.fadingOut == true,touch.phase != .stationary {
                            touchV.removeFromSuperview()
                           // touchV = nil
                        }
                    }
                    if touchView == nil && touch.phase != .stationary{
                        touchView = FingerTipImageView.init(image: touchImage)
                        overlayWindow.addSubview(touchView!)
                        if touchView?.fadingOut == false {
                            touchView?.alpha = touchAlpha
                            touchView?.center = touch.location(in: overlayWindow)
                            touchView?.tag = touch.hash
                            touchView?.timestamp = touch.timestamp
                            let flag = shouldAutomaticallyRemoveFingerTipForTouch(touch: touch)
                            touchView?.shouldAutomaticallyRemoveAfterTimeout = flag
                        }
                    }
           
                case .ended,.cancelled:
                    removeFingerTipWithHash(hash: touch.hash, animated: true)
                }
            }
        }
        super.sendEvent(event)
        scheduleFingerTipRemoval()
    }
    

   // MARK: Private
    private func scheduleFingerTipRemoval() {
        if fingerTipRemovalScheduled == true {
            return
        }
        fingerTipRemovalScheduled = true
        perform(#selector(removeInactiveFingerTips), with: nil, afterDelay: 0.1)
    }

    private func cancelScheduledFingerTipRemoval() {
        fingerTipRemovalScheduled = true
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(removeInactiveFingerTips), object: nil)
    }
    
    @objc func removeInactiveFingerTips() {
        fingerTipRemovalScheduled = false
        let now = ProcessInfo.processInfo.systemUptime
        let REMOVAL_DELAY : Double = 0.2
        for touchView in overlayWindow.subviews {
            if touchView.isKind(of: FingerTipImageView.classForCoder()) == false {
                continue
            }
            if (touchView as! FingerTipImageView).shouldAutomaticallyRemoveAfterTimeout && now > ((touchView as! FingerTipImageView).timestamp + REMOVAL_DELAY){
                removeFingerTipWithHash(hash: touchView.tag, animated: true)
            }
        }
        if overlayWindow.subviews.count > 0{
            scheduleFingerTipRemoval()
        }
    }
    
    private func removeFingerTipWithHash(hash:Int,animated : Bool ) {
        let touchView = overlayWindow.viewWithTag(hash)
        if touchView?.isKind(of: FingerTipImageView.classForCoder()) == false {
            return
        }
        if (touchView as! FingerTipImageView).fadingOut == true {
            return
        }
        let animationsWereEnabled = UIView.areAnimationsEnabled
        if animated {
            UIView.setAnimationsEnabled(true)
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(fadeDuration)
        }
        touchView?.frame = CGRect.init(x: touchView!.center.x - touchView!.frame.size.width, y: touchView!.center.y - touchView!.frame.size.height, width: touchView!.frame.size.width * 2, height: touchView!.frame.size.height * 2)
        touchView?.alpha = 0.0
        if animated == true {
            UIView.commitAnimations()
            UIView.setAnimationsEnabled(animationsWereEnabled)
        }
        (touchView as! FingerTipImageView).fadingOut = true
        touchView?.perform(#selector(removeFromSuperview), with: nil, afterDelay: fadeDuration)
    }
    
    
    // We don't reliably get UITouchPhaseEnded or UITouchPhaseCancelled
    // events via -sendEvent: for certain touch events. Known cases
    // include swipe-to-delete on a table view row, and tap-to-cancel
    // swipe to delete. We automatically remove their associated
    // fingertips after a suitable timeout.
    //
    // It would be much nicer if we could remove all touch events after
    // a suitable time out, but then we'll prematurely remove touch and
    // hold events that are picked up by gesture recognizers (since we
    // don't use UITouchPhaseStationary touches for those. *sigh*). So we
    // end up with this more complicated setup.
    func shouldAutomaticallyRemoveFingerTipForTouch(touch : UITouch)-> Bool {
        var view = touch.view
        view = view?.hitTest(touch.location(in: view), with: nil)
        while view != nil
        {
            if view!.isKind(of: UITableViewCell.classForCoder()){
                for recognizer in touch.gestureRecognizers! {
                    if recognizer.isKind(of: UISwipeGestureRecognizer.classForCoder()){
                        return true
                    }
                }
            }
            if view!.isKind(of: UITableView.classForCoder()){
                if touch.gestureRecognizers?.count == 0 {
                    return true
                }
            }
            view = view?.superview
        }
        return false
    }
}


class FingerTipImageView: UIImageView {
    
    var timestamp : TimeInterval = 0
    var shouldAutomaticallyRemoveAfterTimeout : Bool = true
    var fadingOut : Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
    }
}
