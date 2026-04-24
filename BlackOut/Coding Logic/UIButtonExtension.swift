//
//  UIButtonExtension.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 12/3/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable extension UIButton
{
    @IBInspectable var borderWidth1: CGFloat
    {
    set {
            layer.borderWidth = newValue
            setNeedsLayout()
        }
    get
        {
         return layer.borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor
    {
        set{
            layer.borderColor = newValue.cgColor
            setNeedsLayout()
        }
        get{
            return UIColor(cgColor: layer.borderColor!)
        }
    }
    
    @IBInspectable var shadowRadius : CGFloat
    {
        set {layer.shadowRadius = newValue}
        get {return layer.shadowRadius}
    }
    
    @IBInspectable var shadowOpacity : Float
    {
        set{layer.shadowOpacity = newValue}
        get{return layer.shadowOpacity}
    }
	
	func preventRepeatedPresses(inNext seconds: Double = 1) {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            self.isUserInteractionEnabled = true
        }
    }
}
