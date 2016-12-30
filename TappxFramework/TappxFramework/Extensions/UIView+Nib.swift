//
//  UIView+Nib.swift
//  Roawds2
//
//  Created by David Alarcon on 30/10/15.
//  Copyright © 2015 IOTLabs. All rights reserved.
//

import UIKit

extension UIView {
    
    class func fromNib<T : UIView>(nibNameOrNil: String? = nil) -> T {
        guard let v: T = fromNib(nibNameOrNil) else {
            return T()
        }
        
        return v
    }
    
    class func fromNib<T : UIView>(nibNameOrNil: String? = nil) -> T? {
        var view: T?
        let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = "\(T.self)".componentsSeparatedByString(".").last!
        }
        
        let bundle = NSBundle(forClass: T.self)
        guard let nibViews = bundle.loadNibNamed(name, owner: nil, options: nil) else {
            return .None
        }
        
        for v in nibViews {
            if let tog = v as? T {
                view = tog
            }
        }
        
        return view
    }
 
}
