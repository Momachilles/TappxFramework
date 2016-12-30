//
//  TappxCloseButton.swift
//  TappxFramework
//
//  Created by David Alarcon on 19/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import UIKit

@IBDesignable class TappxCloseButton: UIButton {
    
    
    // IBInspectable properties for rounded corners and border color / width
    @IBInspectable var borderSize: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var innerBackgroundColor: UIColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var borderAlpha: CGFloat = 1.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var number:UInt = 10 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var radius: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    //TODO: It's hardcored, should be proportional
    override func drawRect(rect: CGRect) {

        self.backgroundColor = UIColor.clearColor()
        let str = (self.number == 0) ? "X" : String(self.number)
        self.enabled = (self.number == 0) ? true : false
        self.setTitle(str, forState: .Normal)
        self.setTitleColor(self.borderColor, forState: .Normal)
        self.setTitleColor(UIColor.orangeColor(), forState: .Disabled)
        self.titleLabel?.font = UIFont.systemFontOfSize(20)

        //Delete shapelayer
        self.layer.sublayers?.forEach { layer in
            if layer is CAShapeLayer { layer.removeFromSuperlayer() }
        }
        
        //Draw the circle
        let x = CGFloat(self.layer.bounds.width/2)
        let y = CGFloat(self.layer.bounds.height/2)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: 15.0, startAngle: 0, endAngle:CGFloat(M_PI * 2), clockwise: true)
        let layer = CAShapeLayer()
        layer.path = circlePath.CGPath
        layer.fillColor = self.innerBackgroundColor.CGColor
        layer.strokeColor = self.borderColor.CGColor
        //you can change the line width
        layer.lineWidth = self.borderSize
        self.layer.insertSublayer(layer, atIndex: 0)
        
        super.drawRect(rect)
        
    }

}
