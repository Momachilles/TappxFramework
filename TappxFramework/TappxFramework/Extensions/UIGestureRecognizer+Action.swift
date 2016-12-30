//
//  UIGestureRecognizer+Action.swift
//  TappxFramework
//
//  Created by David Alarcon on 19/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation
import UIKit


extension UIGestureRecognizer {
    private class GestureAction {
        var action: (UIGestureRecognizer) -> Void
        
        init(action: (UIGestureRecognizer) -> Void) {
            self.action = action
        }
    }
    
    private struct AssociatedKeys {
        static var ActionName = "action"
    }
    
    private var gestureAction: GestureAction? {
        set { objc_setAssociatedObject(self, &AssociatedKeys.ActionName, newValue, .OBJC_ASSOCIATION_RETAIN) }
        get { return objc_getAssociatedObject(self, &AssociatedKeys.ActionName) as? GestureAction }
    }
    
    /**
     Convenience initializer, associating an action closure with the gesture recognizer (instead of the more traditional target/action).
     
     - parameter action: The closure for the recognizer to execute. There is no pre-logic to conditionally invoke the closure or not (e.g. only invoke the closure if the gesture recognizer is in a particular state). The closure is merely invoked directly; all handler logic is up to the closure.
     
     - returns: The UIGestureRecognizer.
     */
    public convenience init(action: (UIGestureRecognizer) -> Void) {
        self.init()
        gestureAction = GestureAction(action: action)
        addTarget(self, action: #selector(handleAction(_:)))
    }
    
    dynamic private func handleAction(recognizer: UIGestureRecognizer) {
        gestureAction?.action(recognizer)
    }
}
